import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/shield_providers.dart';
import '../../providers/vault_provider.dart';
import '../live_shield/live_feed_provider.dart';

class ApiKeyLeakOffer {
  const ApiKeyLeakOffer({
    required this.detectedKey,
    required this.providerHint,
  });

  final String detectedKey;
  final String providerHint;
}

class ApiKeyLeakShieldState {
  const ApiKeyLeakShieldState({this.pendingOffer});

  final ApiKeyLeakOffer? pendingOffer;

  ApiKeyLeakShieldState copyWith({ApiKeyLeakOffer? pendingOffer, bool clear = false}) {
    return ApiKeyLeakShieldState(
      pendingOffer: clear ? null : (pendingOffer ?? this.pendingOffer),
    );
  }
}

final _apiKeyPatterns = [
  RegExp(r'sk-[a-zA-Z0-9]{20,}'),
  RegExp(r'AIza[0-9A-Za-z\-_]{35}'),
  RegExp(r'claude-[a-zA-Z0-9\-_]{20,}'),
  RegExp(r'hf_[a-zA-Z0-9]{20,}'),
];

class ApiKeyLeakShieldController extends Notifier<ApiKeyLeakShieldState> {
  Timer? _poll;

  @override
  ApiKeyLeakShieldState build() {
    ref.onDispose(() => _poll?.cancel());
    ref.listen(shieldStatusProvider, (_, next) {
      if (next) {
        _poll ??= Timer.periodic(const Duration(seconds: 3), (_) => _scanClipboard());
      } else {
        _poll?.cancel();
        _poll = null;
      }
    });
    return const ApiKeyLeakShieldState();
  }

  Future<void> _scanClipboard() async {
    if (!ref.read(shieldStatusProvider)) return;
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text?.trim();
      if (text == null || text.isEmpty) return;
      for (final pattern in _apiKeyPatterns) {
        final match = pattern.firstMatch(text);
        if (match != null) {
          final key = match.group(0)!;
          state = ApiKeyLeakShieldState(
            pendingOffer: ApiKeyLeakOffer(
              detectedKey: key,
              providerHint: _hintFor(key),
            ),
          );
          ref.read(liveFeedProvider.notifier).push(
                'Açıkta AI API anahtarı tespit edildi — Vault taşıma önerildi',
              );
          return;
        }
      }
    } catch (_) {}
  }

  String _hintFor(String key) {
    if (key.startsWith('sk-')) return 'openai';
    if (key.startsWith('AIza')) return 'gemini';
    if (key.startsWith('claude-')) return 'anthropic';
    return 'custom';
  }

  Future<void> vaultAndClearClipboard() async {
    final offer = state.pendingOffer;
    if (offer == null) return;
    final vault = ref.read(vaultServiceProvider);
    try {
      await vault.saveApiKey(offer.providerHint, offer.detectedKey);
      await Clipboard.setData(const ClipboardData(text: ''));
      ref.read(liveFeedProvider.notifier).push(
            'API anahtarı Vault\'a taşındı — pano temizlendi',
          );
      state = const ApiKeyLeakShieldState();
    } catch (e) {
      ref.read(liveFeedProvider.notifier).push('Vault kaydı başarısız: $e');
    }
  }

  void dismiss() => state = const ApiKeyLeakShieldState();
}

final apiKeyLeakShieldProvider =
    NotifierProvider<ApiKeyLeakShieldController, ApiKeyLeakShieldState>(
  ApiKeyLeakShieldController.new,
);
