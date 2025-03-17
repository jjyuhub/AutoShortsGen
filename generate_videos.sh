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

# ✅ Fix: Create an animated moving background
ffmpeg -f lavfi -i "color=c=black:s=1080x1920:d=15" -vf "format=yuv420p,geq=r='255*sin(PI*t/5)':g='255*sin(PI*t/7)':b='255*sin(PI*t/3)'" -t 15 "$OUTPUT_DIR/animated_bg.mp4"

# ✅ Fix: Add animated text (fade in/out + move effect)
ffmpeg -i "$OUTPUT_DIR/animated_bg.mp4" -vf "
drawtext=text='$SCRIPT_TEXT':fontcolor=white:fontsize=48:x=(w-text_w)/2:y=h/3:enable='between(t,0,5)':alpha='if(lt(t,1),0,if(lt(t,2),(t-1),if(lt(t,4),1,1-(t-4))))',
drawtext=text='Embrace automation now!':fontcolor=yellow:fontsize=42:x=(w-text_w)/2:y=h/1.5:enable='between(t,5,10)':alpha='if(lt(t,6),0,if(lt(t,7),(t-6),if(lt(t,9),1,1-(t-9))))'
" -c:a copy "$OUTPUT_DIR/animated_text.mp4"

# ✅ Overlay voiceover on the animated text + motion background
ffmpeg -i "$OUTPUT_DIR/animated_text.mp4" -i "$VOICEOVER_FILE" -c:v libx264 -crf 23 -preset veryfast -c:a aac -strict experimental "$OUTPUT_VIDEO"

# ✅ Fix: Ensure animated subtitles for vertical format
SUBTITLE_FILE="$OUTPUT_DIR/subtitles.srt"
echo "1
00:00:00,000 --> 00:00:05,000
$SCRIPT_TEXT

2
00:00:05,000 --> 00:00:10,000
Embrace automation now!" > "$SUBTITLE_FILE"

ffmpeg -i "$OUTPUT_VIDEO" -vf "subtitles=$SUBTITLE_FILE:force_style='FontSize=42,PrimaryColour=&HFFFFFF&,Alignment=2,MarginV=100'" -c:a copy "${OUTPUT_VIDEO}_subtitled.mp4"
mv "${OUTPUT_VIDEO}_subtitled.mp4" "$OUTPUT_VIDEO"

# ✅ Fix: Add watermark with smooth fade-in effect
if [ -f "$WATERMARK" ]; then
    ffmpeg -i "$OUTPUT_VIDEO" -i "$WATERMARK" -filter_complex "[1:v]format=rgba,fade=t=in:st=1:d=1:alpha=1[wm];[0:v][wm]overlay=W-w-50:H-h-50" -codec:a copy "${OUTPUT_VIDEO}_watermarked.mp4"
    mv "${OUTPUT_VIDEO}_watermarked.mp4" "$OUTPUT_VIDEO"
fi

echo "✅ Successfully generated: $OUTPUT_VIDEO"
