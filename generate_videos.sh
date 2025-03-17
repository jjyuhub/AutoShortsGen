#!/bin/bash

# Define folders
OUTPUT_DIR="videos/generated"
mkdir -p "$OUTPUT_DIR"

WATERMARK="assets/logo.png"

# Generate AI-driven script
SCRIPT_TEXT="AI is transforming business. Automate or be left behind."

# Generate voiceover using TTS
VOICEOVER_FILE="$OUTPUT_DIR/voiceover.wav"
echo "$SCRIPT_TEXT" | espeak-ng --stdout > "$VOICEOVER_FILE"

# Define output video file
OUTPUT_VIDEO="$OUTPUT_DIR/generated_video.mp4"

# ✅ Fix: Use a solid black background
ffmpeg -f lavfi -i "color=c=black:s=1080x1920:d=15" -t 15 -y "$OUTPUT_DIR/animated_bg.mp4"

# ✅ Fix: Properly scale and animate text to scroll smoothly from bottom to top
ffmpeg -i "$OUTPUT_DIR/animated_bg.mp4" -vf "
drawtext=text='$SCRIPT_TEXT':fontcolor=white:fontsize=64:x=(w-text_w)/2:y=h-100*t:enable='between(t,0,10)'" -c:a copy "$OUTPUT_DIR/animated_text.mp4"

# ✅ Overlay voiceover on the animated background
ffmpeg -i "$OUTPUT_DIR/animated_text.mp4" -i "$VOICEOVER_FILE" -c:v libx264 -crf 23 -preset veryfast -c:a aac -strict experimental "$OUTPUT_VIDEO"

# ✅ Fix: Ensure readable subtitles for vertical format
SUBTITLE_FILE="$OUTPUT_DIR/subtitles.srt"
echo "1
00:00:00,000 --> 00:00:05,000
AI is transforming business.

2
00:00:05,000 --> 00:00:10,000
Automate or be left behind!" > "$SUBTITLE_FILE"

ffmpeg -i "$OUTPUT_VIDEO" -vf "subtitles=$SUBTITLE_FILE:force_style='FontSize=42,PrimaryColour=&HFFFFFF&,Alignment=2,MarginV=100'" -c:a copy "${OUTPUT_VIDEO}_subtitled.mp4"
mv "${OUTPUT_VIDEO}_subtitled.mp4" "$OUTPUT_VIDEO"

# ✅ Fix: Add watermark with smooth fade-in effect
if [ -f "$WATERMARK" ]; then
    ffmpeg -i "$OUTPUT_VIDEO" -i "$WATERMARK" -filter_complex "[1:v]format=rgba,fade=t=in:st=1:d=1:alpha=1[wm];[0:v][wm]overlay=W-w-50:H-h-50" -codec:a copy "${OUTPUT_VIDEO}_watermarked.mp4"
    mv "${OUTPUT_VIDEO}_watermarked.mp4" "$OUTPUT_VIDEO"
fi

echo "✅ Successfully generated: $OUTPUT_VIDEO"
