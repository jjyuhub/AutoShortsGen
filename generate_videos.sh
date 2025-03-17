#!/bin/bash

# Define output folders
OUTPUT_DIR="videos/generated"
WATERMARK="assets/logo.png"

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Generate AI-driven script (can be AI-generated in future)
SCRIPT_TEXT="AI is transforming the world. The question is, are you adapting fast enough?"

# Generate voiceover using TTS
VOICEOVER_FILE="$OUTPUT_DIR/voiceover.wav"
echo "$SCRIPT_TEXT" | espeak-ng --stdout > "$VOICEOVER_FILE"

# Define output video file
OUTPUT_VIDEO="$OUTPUT_DIR/generated_video.mp4"

# Generate a dynamic animated vertical background (9:16 format)
ffmpeg -f lavfi -i gradient=red:blue -filter_complex "[0:v]scale=1080:1920,format=yuv420p[v]" -map "[v]" -t 15 "$OUTPUT_DIR/background.mp4"

# Overlay voiceover on the animated background
ffmpeg -i "$OUTPUT_DIR/background.mp4" -i "$VOICEOVER_FILE" -c:v libx264 -crf 23 -preset veryfast -c:a aac -strict experimental "$OUTPUT_VIDEO"

# Generate subtitles file
SUBTITLE_FILE="$OUTPUT_DIR/subtitles.srt"
echo "1
00:00:00,000 --> 00:00:05,000
$SCRIPT_TEXT" > "$SUBTITLE_FILE"

# Add subtitles with better positioning for vertical format
ffmpeg -i "$OUTPUT_VIDEO" -vf "subtitles=$SUBTITLE_FILE:force_style='FontSize=32,PrimaryColour=&HFFFFFF&,Alignment=2'" -c:a copy "${OUTPUT_VIDEO}_subtitled.mp4"
mv "${OUTPUT_VIDEO}_subtitled.mp4" "$OUTPUT_VIDEO"

# Add watermark if available (placed in bottom-right)
if [ -f "$WATERMARK" ]; then
    ffmpeg -i "$OUTPUT_VIDEO" -i "$WATERMARK" -filter_complex "overlay=W-w-50:H-h-50" -codec:a copy "${OUTPUT_VIDEO}_watermarked.mp4"
    mv "${OUTPUT_VIDEO}_watermarked.mp4" "$OUTPUT_VIDEO"
fi

echo "✅ Generated YouTube Shorts video: $OUTPUT_VIDEO"
