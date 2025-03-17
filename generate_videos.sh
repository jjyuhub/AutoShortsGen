#!/bin/bash

# Define folders
OUTPUT_DIR="videos/generated"
mkdir -p "$OUTPUT_DIR"

WATERMARK="assets/logo.png"

# Generate AI-driven script (can be AI-generated later)
SCRIPT_TEXT="AI is transforming business. Automate or be left behind."

# Generate voiceover using TTS
VOICEOVER_FILE="$OUTPUT_DIR/voiceover.wav"
echo "$SCRIPT_TEXT" | espeak-ng --stdout > "$VOICEOVER_FILE"

# Define output video file
OUTPUT_VIDEO="$OUTPUT_DIR/generated_video.mp4"

# ✅ Fix: Use a solid color background (1080x1920 vertical format)
BACKGROUND_COLOR="black"
ffmpeg -f lavfi -i color=c=$BACKGROUND_COLOR:s=1080x1920:d=15 -t 15 "$OUTPUT_DIR/background.mp4"

# ✅ Fix: Add animated text overlay instead of gradient
ffmpeg -i "$OUTPUT_DIR/background.mp4" -vf "drawtext=text='$SCRIPT_TEXT':fontcolor=white:fontsize=48:x=(w-text_w)/2:y=(h-text_h)/2:enable='between(t,0,10)'" -c:a copy "$OUTPUT_DIR/text_background.mp4"

# Overlay voiceover on the background with text
ffmpeg -i "$OUTPUT_DIR/text_background.mp4" -i "$VOICEOVER_FILE" -c:v libx264 -crf 23 -preset veryfast -c:a aac -strict experimental "$OUTPUT_VIDEO"

# ✅ Fix: Ensure subtitles work properly for vertical format
SUBTITLE_FILE="$OUTPUT_DIR/subtitles.srt"
echo "1
00:00:00,000 --> 00:00:05,000
$SCRIPT_TEXT" > "$SUBTITLE_FILE"

ffmpeg -i "$OUTPUT_VIDEO" -vf "subtitles=$SUBTITLE_FILE:force_style='FontSize=32,PrimaryColour=&HFFFFFF&,Alignment=2'" -c:a copy "${OUTPUT_VIDEO}_subtitled.mp4"
mv "${OUTPUT_VIDEO}_subtitled.mp4" "$OUTPUT_VIDEO"

# ✅ Fix: Add watermark if available
if [ -f "$WATERMARK" ]; then
    ffmpeg -i "$OUTPUT_VIDEO" -i "$WATERMARK" -filter_complex "overlay=W-w-50:H-h-50" -codec:a copy "${OUTPUT_VIDEO}_watermarked.mp4"
    mv "${OUTPUT_VIDEO}_watermarked.mp4" "$OUTPUT_VIDEO"
fi

echo "✅ Successfully generated: $OUTPUT_VIDEO"
