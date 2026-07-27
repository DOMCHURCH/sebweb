# Sebastien Church — Portfolio

A cinematic, scroll-scrubbed portfolio for Sebastien Church (B.Sc. Neuroscience &
Mental Health, Carleton University). Scrolling drives a fixed fullscreen canvas
frame-by-frame: the **SEBASTIEN** title card pushes through the microscope, then
through the eyepiece, and lands on a slide of five specimens. Each specimen is an
interactive hotspot that opens a glassmorphic card — Research, Field Experience,
Education, Volunteering, and Certifications.

Single file (`index.html`). Smooth scroll + animation via **Lenis + GSAP** (CDN,
with a native-scroll fallback); type is Google Fonts (Playfair Display + Jost).

## Structure

```
index.html                     The entire site (HTML + CSS + JS, scroll engine, overlay, cards)
extract.sh                     Rebuilds both frame tiers from the source videos
video1.mp4 / video2.mp4        landscape 16:9 source (title → microscope → slide)
portrait1.mp4 / portrait2.mp4  portrait 9:16 source (same beats, framed for phones)
frames/desktop/                f0000.webp … f0509.webp  (1600px 16:9 — landscape viewports)
frames/portrait/               f0000.webp … f0509.webp  (1000px 9:16 — portrait viewports)
```

In each tier, frames are numbered globally 0–509 (clip 1 = 0–209, clip 2 = 210–509)
at 8 px of scroll per frame. index.html picks the tier by viewport aspect ratio.

## Develop / preview locally

Frames must be served over HTTP (not `file://`):

```bash
python -m http.server 8099
# open http://localhost:8099
```

## Rebuild the frames

Requires `ffmpeg` and, optionally, [Real-ESRGAN](https://github.com/xinntao/Real-ESRGAN)
(`realesrgan-ncnn-vulkan`) for the 4× detail-recovery pass. Without it, the WebP
tiers are encoded straight from the native ~1924px frames.

```bash
bash extract.sh
# or point at your upscaler:
REALESRGAN=/path/to/realesrgan-ncnn-vulkan bash extract.sh
```

## Deploy

Static — deploy the repo as-is (e.g. Vercel: no build command, output = repo root).
`frames/desktop` (~19 MB) + `frames/portrait` (~22 MB) are committed so no build
step is required at deploy time.

## Accessibility & performance

- Full text version of every section is present for screen readers / no-JS / SEO.
- `prefers-reduced-motion` snaps frames instead of easing.
- Aspect-based tiers: 16:9 for landscape, 9:16 for portrait phones (no title crop).
- Touch targets ≥ 44px; card is a focus-trapped `dialog` (Esc / arrow keys).
