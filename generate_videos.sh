#!/bin/bash

# Define folders
OUTPUT_DIR="videos/generated"
WATERMARK="assets/logo.png"

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Generate AI-driven script
SCRIPT_TEXT="AI is revolutionizing the way we think about automation and business growth."

# Generate voiceover using TTS
VOICEOVER_FILE="$OUTPUT_DIR/voiceover.wav"
echo "$SCRIPT_TEXT" | espeak-ng --stdout > "$VOICEOVER_FILE"

# Define output video file
OUTPUT_VIDEO="$OUTPUT_DIR/generated_video.mp4"

# Create a dynamic animated background using FFmpeg (animated gradient effect)
ffmpeg -f lavfi -i color=c=blue:s=1280x720:d=10 -vf "format=yuv420p,fade=t=in:st=0:d=1,fade=t=out:st=9:d=1" -t 10 "$OUTPUT_DIR/background.mp4"

# Overlay voiceover on the generated background
ffmpeg -i "$OUTPUT_DIR/background.mp4" -i "$VOICEOVER_FILE" -c:v libx264 -crf 23 -preset veryfast -c:a aac -strict experimental "$OUTPUT_VIDEO"

# Generate subtitles file
SUBTITLE_FILE="$OUTPUT_DIR/subtitles.srt"
echo "1
00:00:00,000 --> 00:00:05,000
$SCRIPT_TEXT" > "$SUBTITLE_FILE"

# Add subtitles to the video
ffmpeg -i "$OUTPUT_VIDEO" -vf "subtitles=$SUBTITLE_FILE:force_style='FontSize=24,PrimaryColour=&HFFFFFF&'" -c:a copy "${OUTPUT_VIDEO}_subtitled.mp4"
mv "${OUTPUT_VIDEO}_subtitled.mp4" "$OUTPUT_VIDEO"

# Add watermark if available
if [ -f "$WATERMARK" ]; then
    ffmpeg -i "$OUTPUT_VIDEO" -i "$WATERMARK" -filter_complex "overlay=W-w-10:H-h-10" -codec:a copy "${OUTPUT_VIDEO}_watermarked.mp4"
    mv "${OUTPUT_VIDEO}_watermarked.mp4" "$OUTPUT_VIDEO"
fi

echo "✅ Generated: $OUTPUT_VIDEO"
