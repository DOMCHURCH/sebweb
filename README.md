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
img/                           Card photos (referenced by the CARDS array in index.html)
Sebastien-Church-CV.pdf        Served by the "Download CV" button
og.jpg / favicon.svg           Link-preview image and site icon
```

In each tier, frames are numbered globally 0–509 (clip 1 = 0–209, clip 2 = 210–509).
index.html picks the tier by viewport aspect ratio.

Scrub speed is `PPF` in index.html — pixels of scroll per frame. It is 9 for
pointer devices and 15 for coarse pointers, because a touch flick covers far
more distance than a wheel notch and the sequence otherwise raced past in two
swipes. Raise it to slow the scrub down further; the page height follows.

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

## Contact form

The form posts to [Web3Forms](https://web3forms.com) — no backend. The routing
address is fixed to whatever the `access_key` hidden input in `index.html` was
issued for, so a fork needs its own free key swapped in there. Submissions are
sent with `fetch` (12s timeout) and fall back to a native POST without JS.

## Debug overlay

Append `?debug` to the URL for a live panel showing GPU / hardware-acceleration
status, FPS, DPR and the canvas backing size — the fastest way to tell whether a
"laggy" report is actually software rendering.

## Deploy

Static — deploy the repo as-is (e.g. Vercel: no build command, output = repo root).
`frames/desktop` (~20 MB) + `frames/portrait` (~28 MB) are committed so no build
step is required at deploy time.

## Accessibility & performance

- Full text version of every section is present for screen readers / no-JS / SEO.
- `prefers-reduced-motion` snaps frames instead of easing.
- Aspect-based tiers: 16:9 for landscape, 9:16 for portrait phones (no title crop).
- Touch targets ≥ 44px; card is a focus-trapped `dialog` (Esc / arrow keys).
