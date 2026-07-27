#!/usr/bin/env bash
# ============================================================================
#  extract.sh — build the scroll-scrub frame sequences for the portfolio.
#
#  Pipeline:
#    1. Extract every frame of video1.mp4 (210) and video2.mp4 (300) at 30fps.
#    2. Upscale each frame 4x with Real-ESRGAN (genuine detail recovery).
#    3. Downscale + sharpen + encode to WebP in two responsive tiers:
#         frames/desktop/  (1600px, high quality)  <- index.html loads these
#         frames/mobile/   ( 900px, lighter)
#       Frames are numbered globally 0..509 (video1 = 0..209, video2 = 210..509).
#
#  Requirements: ffmpeg, ffprobe, and Real-ESRGAN (realesrgan-ncnn-vulkan).
#  If Real-ESRGAN is not found, step 2 is skipped and the WebP tiers are
#  encoded straight from the native frames (still crisp — source is ~1924px).
#
#  Usage:   bash extract.sh
#  Override the upscaler path:  REALESRGAN=/path/to/realesrgan-ncnn-vulkan bash extract.sh
# ============================================================================
set -euo pipefail

# ---- config ----------------------------------------------------------------
REALESRGAN="${REALESRGAN:-/c/Users/Dominique/Downloads/oa_work/realesrgan/realesrgan-ncnn-vulkan.exe}"
MODEL="realesrgan-x4plus"     # photographic 4x model
DESKTOP_W=1600
MOBILE_W=900
N1=210                        # number of frames in video1 (global offset for video2)
# ---------------------------------------------------------------------------

mkdir -p frames/video1 frames/video2 frames/desktop frames/mobile

echo "[1/4] Extracting frames at 30fps..."
ffmpeg -v error -y -i video1.mp4 -vf fps=30 -q:v 1 frames/video1/frame%04d.png
ffmpeg -v error -y -i video2.mp4 -vf fps=30 -q:v 1 frames/video2/frame%04d.png

SRC1="frames/video1"          # source dir for the encode step (raw by default)
SRC2="frames/video2"

if [ -x "$REALESRGAN" ] || command -v "$REALESRGAN" >/dev/null 2>&1; then
  echo "[2/4] Upscaling 4x with Real-ESRGAN ($MODEL)... (this is the slow step)"
  mkdir -p frames/video1/upscaled frames/video2/upscaled
  "$REALESRGAN" -i frames/video1 -o frames/video1/upscaled -n "$MODEL" -f png
  "$REALESRGAN" -i frames/video2 -o frames/video2/upscaled -n "$MODEL" -f png
  SRC1="frames/video1/upscaled"
  SRC2="frames/video2/upscaled"
else
  echo "[2/4] Real-ESRGAN not found at '$REALESRGAN' — encoding from native frames."
fi

DVF="scale=${DESKTOP_W}:-2:flags=lanczos,unsharp=5:5:0.4:5:5:0.0"
MVF="scale=${MOBILE_W}:-2:flags=lanczos,unsharp=5:5:0.5:5:5:0.0"

echo "[3/4] Encoding DESKTOP tier (${DESKTOP_W}px)..."
ffmpeg -v error -y -i "$SRC1/frame%04d.png" -vf "$DVF" -c:v libwebp -quality 88 -compression_level 6 -preset picture -start_number 0    frames/desktop/f%04d.webp
ffmpeg -v error -y -i "$SRC2/frame%04d.png" -vf "$DVF" -c:v libwebp -quality 88 -compression_level 6 -preset picture -start_number $N1  frames/desktop/f%04d.webp

echo "[4/4] Encoding MOBILE tier (${MOBILE_W}px)..."
ffmpeg -v error -y -i "$SRC1/frame%04d.png" -vf "$MVF" -c:v libwebp -quality 84 -compression_level 6 -preset picture -start_number 0    frames/mobile/f%04d.webp
ffmpeg -v error -y -i "$SRC2/frame%04d.png" -vf "$MVF" -c:v libwebp -quality 84 -compression_level 6 -preset picture -start_number $N1  frames/mobile/f%04d.webp

echo "Done. desktop=$(ls frames/desktop | wc -l) mobile=$(ls frames/mobile | wc -l) (expected 510 each)"
