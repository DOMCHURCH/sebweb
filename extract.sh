#!/usr/bin/env bash
# ============================================================================
#  extract.sh — build the scroll-scrub frame sequences (both tiers).
#
#    Landscape 16:9  -> frames/desktop   (video1.mp4    + video2.mp4,    1600px)
#    Portrait  9:16   -> frames/portrait  (portrait1.mp4 + portrait2.mp4, 1000px)
#
#  index.html picks the tier by viewport aspect ratio (portrait viewports get
#  the 9:16 set so the title isn't cropped; wider ones get the 16:9 set).
#
#  Each tier: extract every frame at 30fps, optionally upscale 4x with
#  Real-ESRGAN, then downscale + sharpen + encode to WebP. Frames are numbered
#  globally 0..509 (clip 1 = 0..209, clip 2 = 210..509).
#
#  Requires ffmpeg. Real-ESRGAN (realesrgan-ncnn-vulkan) is optional — without
#  it, frames are encoded from the native source (still crisp).
#
#  Usage:  bash extract.sh
#          REALESRGAN=/path/to/realesrgan-ncnn-vulkan bash extract.sh
# ============================================================================
set -euo pipefail

REALESRGAN="${REALESRGAN:-/c/Users/Dominique/Downloads/oa_work/realesrgan/realesrgan-ncnn-vulkan.exe}"
MODEL="realesrgan-x4plus"
N1=210   # frames in clip 1 (global offset for clip 2)

# build_tier <out-dir> <width> <clip1.mp4> <clip2.mp4> <unsharp-params>
build_tier(){
  local out="$1" w="$2" v1="$3" v2="$4" sharp="$5"
  local raw1="frames/_raw/${out}_1" raw2="frames/_raw/${out}_2"
  mkdir -p "$raw1" "$raw2" "frames/$out"

  echo "[$out] extracting frames at 30fps..."
  ffmpeg -v error -y -i "$v1" -vf fps=30 -q:v 1 "$raw1/frame%04d.png"
  ffmpeg -v error -y -i "$v2" -vf fps=30 -q:v 1 "$raw2/frame%04d.png"

  local s1="$raw1" s2="$raw2"
  if [ -x "$REALESRGAN" ]; then
    echo "[$out] upscaling 4x with Real-ESRGAN ($MODEL)..."
    mkdir -p "${raw1}_up" "${raw2}_up"
    "$REALESRGAN" -i "$raw1" -o "${raw1}_up" -n "$MODEL" -f png
    "$REALESRGAN" -i "$raw2" -o "${raw2}_up" -n "$MODEL" -f png
    s1="${raw1}_up"; s2="${raw2}_up"
  else
    echo "[$out] Real-ESRGAN not found — encoding from native frames."
  fi

  local vf="scale=${w}:-2:flags=lanczos,unsharp=${sharp}"
  echo "[$out] encoding WebP (${w}px)..."
  ffmpeg -v error -y -i "$s1/frame%04d.png" -vf "$vf" -c:v libwebp -quality 90 -compression_level 6 -preset picture -start_number 0   "frames/$out/f%04d.webp"
  ffmpeg -v error -y -i "$s2/frame%04d.png" -vf "$vf" -c:v libwebp -quality 90 -compression_level 6 -preset picture -start_number $N1 "frames/$out/f%04d.webp"
  echo "[$out] done: $(ls "frames/$out" | wc -l) frames (expected 510)"
}

build_tier desktop  1600 video1.mp4    video2.mp4    "5:5:0.4:5:5:0.0"
build_tier portrait 1000 portrait1.mp4 portrait2.mp4 "5:5:0.5:5:5:0.0"

echo "All tiers built."
