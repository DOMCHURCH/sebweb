# Sebastien Church — Portfolio

A cinematic, scroll-scrubbed portfolio for Sebastien Church (B.Sc. Neuroscience &
Mental Health, Carleton University). Scrolling drives a fixed fullscreen canvas
frame-by-frame: the **SEBASTIEN** title card pushes through the microscope, then
through the eyepiece, and lands on a slide of five specimens. Each specimen is an
interactive hotspot that opens a glassmorphic card — Research, Field Experience,
Education, Volunteering, and Certifications.

Single file, no frameworks, no runtime dependencies (`index.html`). The only
external resource is Google Fonts (Playfair Display + Jost).

## Structure

```
index.html            The entire site (HTML + CSS + JS, scroll engine, overlay, cards)
extract.sh            Rebuilds the frame sequences from the source videos
video1.mp4            210 frames — title card → microscope
video2.mp4            300 frames — eyepiece → specimen slide
frames/desktop/       f0000.webp … f0509.webp  (1600px, loaded on desktop/tablet)
frames/mobile/        f0000.webp … f0509.webp  ( 900px, loaded on phones)
```

Frames are numbered globally 0–509 (video1 = 0–209, video2 = 210–509) at 8 px of
scroll per frame.

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
`frames/desktop` + `frames/mobile` total ~24 MB and are committed so no build step
is required at deploy time.

## Accessibility & performance

- Full text version of every section is present for screen readers / no-JS / SEO.
- `prefers-reduced-motion` snaps frames instead of easing.
- Responsive frame tiers keep the payload light and scrubbing smooth on phones.
- Touch targets ≥ 44px; card is a focus-trapped `dialog` (Esc / arrow keys).
