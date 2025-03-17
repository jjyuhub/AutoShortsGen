#!/bin/bash

# Define folders
OUTPUT_DIR="videos/generated"
mkdir -p "$OUTPUT_DIR"

WATERMARK="assets/logo.png"

# Generate AI-driven script (split into multiple lines)
TEXT1="AI is transforming"
TEXT2="business. Automate"
TEXT3="or be left behind."

# Generate voiceover using TTS
VOICEOVER_FILE="$OUTPUT_DIR/voiceover.wav"
echo "$TEXT1 $TEXT2 $TEXT3" | espeak-ng --stdout > "$VOICEOVER_FILE"

# Define output video file
OUTPUT_VIDEO="$OUTPUT_DIR/generated_video.mp4"

# ✅ Fix: Use a solid black background
ffmpeg -f lavfi -i "color=c=black:s=1080x1920:d=15" -t 15 -y "$OUTPUT_DIR/animated_bg.mp4"

# ✅ Fix: Animate text scrolling from bottom to top smoothly
ffmpeg -i "$OUTPUT_DIR/animated_bg.mp4" -vf "
drawtext=text='$TEXT1':fontcolor=white:fontsize=60:x=(w-text_w)/2:y=h-200*t:enable='between(t,0,5)',
drawtext=text='$TEXT2':fontcolor=yellow:fontsize=60:x=(w-text_w)/2:y=h-200*t+100:enable='between(t,2,7)',
drawtext=text='$TEXT3':fontcolor=white:fontsize=60:x=(w-text_w)/2:y=h-200*t+200:enable='between(t,4,10)'" -c:a copy "$OUTPUT_DIR/animated_text.mp4"

# ✅ Overlay voiceover on the animated background
ffmpeg -i "$OUTPUT_DIR/animated_text.mp4" -i "$VOICEOVER_FILE" -c:v libx264 -crf 23 -preset veryfast -c:a aac -strict experimental "$OUTPUT_VIDEO"

# ✅ Fix: Ensure readable subtitles for vertical format
SUBTITLE_FILE="$OUTPUT_DIR/subtitles.srt"
echo "1
00:00:00,000 --> 00:00:05,000
AI is transforming

2
00:00:05,000 --> 00:00:10,000
business. Automate

3
00:00:10,000 --> 00:00:15,000
or be left behind." > "$SUBTITLE_FILE"

ffmpeg -i "$OUTPUT_VIDEO" -vf "subtitles=$SUBTITLE_FILE:force_style='FontSize=42,PrimaryColour=&HFFFFFF&,Alignment=2,MarginV=100'" -c:a copy "${OUTPUT_VIDEO}_subtitled.mp4"
mv "${OUTPUT_VIDEO}_subtitled.mp4" "$OUTPUT_VIDEO"

# ✅ Fix: Add watermark with smooth fade-in effect
if [ -f "$WATERMARK" ]; then
    ffmpeg -i "$OUTPUT_VIDEO" -i "$WATERMARK" -filter_complex "[1:v]format=rgba,fade=t=in:st=1:d=1:alpha=1[wm];[0:v][wm]overlay=W-w-50:H-h-50" -codec:a copy "${OUTPUT_VIDEO}_watermarked.mp4"
    mv "${OUTPUT_VIDEO}_watermarked.mp4" "$OUTPUT_VIDEO"
fi

echo "✅ Successfully generated: $OUTPUT_VIDEO"
