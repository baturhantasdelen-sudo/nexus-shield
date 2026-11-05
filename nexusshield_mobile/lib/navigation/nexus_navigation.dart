import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/nexus_minimal_tech_logo.dart';
import '../widgets/nexus_vector_back_button.dart';

/// Home shell — karargah üst bar (geri yok).
class NexusAppShell extends StatelessWidget {
  const NexusAppShell({
    super.key,
    required this.title,
    required this.body,
    required this.shieldActive,
    this.actions,
  });

  final String title;
  final Widget body;
  final bool shieldActive;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexusBrand.deepSlate,
      appBar: AppBar(
        title: Text(title),
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: NexusMinimalTechLogo(
            size: 36,
            active: shieldActive,
            pulseWhenActive: true,
          ),
        ),
        leadingWidth: 52,
        actions: actions,
      ),
      body: body,
    );
  }
}

/// Alt ekranlar — geri dönüş garantili.
class NexusSubScreenScaffold extends StatelessWidget {
  const NexusSubScreenScaffold({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.floatingActionButton,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: NexusBrand.deepSlate,
        appBar: AppBar(
          leading: NexusVectorBackButton(onPressed: () => popNexusRoute(context)),
          leadingWidth: 56,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 17)),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: const TextStyle(fontSize: 11, color: NexusBrand.muted),
                ),
            ],
          ),
        ),
        floatingActionButton: floatingActionButton,
        body: body,
      ),
    );
  }
}

void popNexusRoute(BuildContext context) {
  if (Navigator.of(context).canPop()) {
    Navigator.of(context).pop();
  }
}

Future<T?> pushNexusSubRoute<T>(BuildContext context, Widget page) {
  final route = Platform.isIOS
      ? CupertinoPageRoute<T>(builder: (_) => page)
      : MaterialPageRoute<T>(builder: (_) => page);
  return Navigator.of(context).push(route);
}
