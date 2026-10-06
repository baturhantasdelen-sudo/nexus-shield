"""Build transparent lockup PNG from exported logo art (checkerboard or solid bg)."""

from __future__ import annotations

import os
from collections import deque
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SRC = Path(
    os.environ.get(
        "NEXUS_LOGO_SRC",
        "",
    )
)
if not str(DEFAULT_SRC):
    DEFAULT_SRC = ROOT / "tool" / "source" / "nexus_logo_source.jpg"

OUT_LOCKUP = ROOT / "assets" / "icon" / "nexus_logo.png"
OUT_EMBLEM = ROOT / "assets" / "icon" / "nexus_emblem.png"
LOCKUP_MIN_WIDTH = 1024


def _checker_colors(rgb: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
    h, w, _ = rgb.shape
    corners = np.stack(
        [rgb[0, 0], rgb[0, w - 1], rgb[h - 1, 0], rgb[h - 1, w - 1]],
        axis=0,
    ).astype(np.float32)
    # K-means with k=2 on corners (and a few edge samples) for checker tones.
    samples = corners
    for x in range(0, w, max(1, w // 8)):
        samples = np.vstack([samples, rgb[0, x], rgb[h - 1, x]])
    for y in range(0, h, max(1, h // 8)):
        samples = np.vstack([samples, rgb[y, 0], rgb[y, w - 1]])
    c1 = samples[0].copy()
    c2 = samples[1].copy()
    for _ in range(12):
        d1 = np.linalg.norm(samples - c1, axis=1)
        d2 = np.linalg.norm(samples - c2, axis=1)
        c1 = samples[d1 <= d2].mean(axis=0)
        c2 = samples[d2 < d1].mean(axis=0)
    return c1, c2


def _bg_distance(rgb: np.ndarray, c1: np.ndarray, c2: np.ndarray) -> np.ndarray:
    f = rgb.astype(np.float32)
    d1 = np.linalg.norm(f - c1, axis=2)
    d2 = np.linalg.norm(f - c2, axis=2)
    return np.minimum(d1, d2)


def _flood_alpha(rgb: np.ndarray) -> np.ndarray:
    h, w, _ = rgb.shape
    c1, c2 = _checker_colors(rgb)
    dist = _bg_distance(rgb, c1, c2)

    # Neutral, low-saturation fringe (watermark lines on checkerboard).
    f = rgb.astype(np.float32)
    sat = f.max(axis=2) - f.min(axis=2)
    neutral = sat < 28.0
    dist = np.where(neutral, dist, dist + 40.0)

    seed_thresh = 20.0
    flood_thresh = 34.0
    is_seed = dist < seed_thresh

    visited = np.zeros((h, w), dtype=bool)
    q: deque[tuple[int, int]] = deque()
    for x in range(w):
        for y in (0, h - 1):
            if is_seed[y, x]:
                visited[y, x] = True
                q.append((y, x))
    for y in range(h):
        for x in (0, w - 1):
            if is_seed[y, x] and not visited[y, x]:
                visited[y, x] = True
                q.append((y, x))

    while q:
        y, x = q.popleft()
        for ny, nx in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1)):
            if 0 <= ny < h and 0 <= nx < w and not visited[ny, nx]:
                if dist[ny, nx] < flood_thresh:
                    visited[ny, nx] = True
                    q.append((ny, nx))

    alpha = np.where(visited, 0.0, 255.0)
    fringe = (~visited) & (dist < 52.0) & neutral
    alpha[fringe] = np.clip((dist[fringe] - 16.0) * 10.0, 0, 255)
    return alpha.astype(np.uint8)


def _drop_speckle_alpha(alpha: np.ndarray, min_area: int = 350) -> np.ndarray:
    """Remove watermark/checker fringe islands; keep lockup strokes."""
    from scipy import ndimage

    mask = alpha > 48
    labeled, n = ndimage.label(mask)
    if n == 0:
        return alpha
    keep = np.zeros_like(mask, dtype=bool)
    for i in range(1, n + 1):
        comp = labeled == i
        if comp.sum() >= min_area:
            keep |= comp
    cleaned = np.where(keep, alpha, 0).astype(np.uint8)
    return cleaned


def _crop_rgba(rgba: np.ndarray, pad: int = 4) -> np.ndarray:
    alpha = rgba[:, :, 3]
    ys, xs = np.where(alpha > 48)
    if ys.size == 0:
        return rgba
    top, bottom = int(ys.min()), int(ys.max())
    left, right = int(xs.min()), int(xs.max())
    h, w = rgba.shape[:2]
    top = max(0, top - pad)
    left = max(0, left - pad)
    bottom = min(h - 1, bottom + pad)
    right = min(w - 1, right + pad)
    return rgba[top : bottom + 1, left : right + 1]


def _upscale_lockup(img: Image.Image, min_width: int = LOCKUP_MIN_WIDTH) -> Image.Image:
    w, h = img.size
    if w >= min_width:
        return img
    scale = min_width / w
    nw, nh = int(round(w * scale)), int(round(h * scale))
    return img.resize((nw, nh), Image.Resampling.LANCZOS)


def _finalize_lockup(rgba: np.ndarray) -> Image.Image:
    cropped = _crop_rgba(rgba)
    out = Image.fromarray(cropped, "RGBA")
    return _upscale_lockup(out)


def build_lockup(src: Path, dest: Path = OUT_LOCKUP) -> tuple[int, int]:
    im = Image.open(src)
    if im.mode == "RGBA":
        rgba = np.array(im)
        if rgba[:, :, 3].min() < 255:
            out = _finalize_lockup(rgba)
        else:
            rgb = rgba[:, :, :3]
            alpha = _drop_speckle_alpha(_flood_alpha(rgb))
            out = _finalize_lockup(np.dstack([rgb, alpha]))
    else:
        rgb = np.array(im.convert("RGB"))
        alpha = _drop_speckle_alpha(_flood_alpha(rgb))
        out = _finalize_lockup(np.dstack([rgb, alpha]))

    dest.parent.mkdir(parents=True, exist_ok=True)
    out.save(dest, "PNG", compress_level=1)
    _write_emblem(out, OUT_EMBLEM)
    return out.size


def _write_emblem(lockup: Image.Image, dest: Path) -> None:
    w, h = lockup.size
    top = lockup.crop((0, 0, w, int(h * 0.47)))
    side = 1024
    canvas = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    tw, th = top.size
    scale = (side * 0.88) / max(tw, th)
    nw, nh = int(tw * scale), int(th * scale)
    resized = top.resize((nw, nh), Image.Resampling.LANCZOS)
    canvas.paste(resized, ((side - nw) // 2, (side - nh) // 2), resized)
    dest.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(dest, "PNG", compress_level=1)


def main() -> None:
    src = DEFAULT_SRC
    if not src.is_file():
        raise SystemExit(f"Source logo not found: {src}")
    size = build_lockup(src)
    print(f"wrote {OUT_LOCKUP} size={size} bytes={OUT_LOCKUP.stat().st_size}")


if __name__ == "__main__":
    main()
