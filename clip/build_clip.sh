#!/usr/bin/env bash
# Build the gta6-clipper-01 Short from Rockstar's official GTA VI Trailer 2.
# Source (fetched in-session, official Rockstar Games upload):
#   https://www.youtube.com/watch?v=VQRLujxTm3c  (Grand Theft Auto VI Trailer 2)
#   yt-dlp, android client (the only client YouTube served without a login
#   this session; SABR experiment limited it to format 18, 640x360).
#   Because the source is 360p, the Short uses the standard blurred-background
#   vertical layout: the 16:9 frame stays near-native width (720px) instead of
#   being cropped and upscaled 5x.
#
# Creative (decided in-session, see runlog-gta6-clipper-01.md):
#   The moment: the trailer's climax escape run, 138-156s — helicopter over
#   the swamp, Lucia & Jason on the jet ski, Jason's bike under the seaplane,
#   night ride, red car, sunset over Vice City. One continuous arc, not a
#   montage of unrelated bits. Hook in the first 2 seconds: "GTA 6 IS OUT NOW"
#   (the game launched 2026-11-19). The trailer's own end card ("MAY 26,
#   2026") is NOT used: that date is superseded by the real launch.
#   Then a 12s pitch card (two 6s cards): make clips like this with AI and
#   earn money on make.fun, with the bounty page.
#
# Layout: 720x1280, 30fps. Action 18s (trailer audio, faded out at the end),
# pitch cards 12s silent. Total 30s.
set -euo pipefail
cd "$(dirname "$0")"
SRC="gta6-trailer2-720.mp4"
OUT="gta6-clipper-01-short.mp4"
FONT="/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
FONT_REG="/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"

# --- 1. Action segment: 138-156s of the trailer, vertical layout + text ---
ffmpeg -y -v error -ss 138 -i "$SRC" -t 18 -filter_complex \
"[0:v]trim=0:18,setpts=PTS-STARTPTS,split[a][b]; \
 [a]scale=720:1280:force_original_aspect_ratio=increase,crop=720:1280,gblur=sigma=28,eq=brightness=-0.30:saturation=1.1[bg]; \
 [b]scale=720:405[fg]; \
 [bg][fg]overlay=(W-w)/2:437[v0]; \
 [v0]drawtext=fontfile=$FONT:text='GTA 6 IS OUT NOW':fontsize=62:fontcolor=white:borderw=3:bordercolor=black:x=(w-text_w)/2:y=110:enable='between(t,0,3.2)'[v1]; \
 [v1]drawtext=fontfile=$FONT:text='LUCIA & JASON':fontsize=56:fontcolor=white:borderw=3:bordercolor=black:x=(w-text_w)/2:y=110:enable='between(t,3.6,8)'[v2]; \
 [v2]drawtext=fontfile=$FONT:text='VICE CITY, USA':fontsize=56:fontcolor=white:borderw=3:bordercolor=black:x=(w-text_w)/2:y=110:enable='between(t,8.4,13)'[v3]; \
 [v3]drawtext=fontfile=$FONT:text='THE WAIT IS OVER':fontsize=56:fontcolor=#ffd94d:borderw=3:bordercolor=black:x=(w-text_w)/2:y=110:enable='between(t,13.4,18)'[v4]; \
 [v4]drawtext=fontfile=$FONT_REG:text='Footage\: Rockstar Games - GTA VI Trailer 2':fontsize=22:fontcolor=white:borderw=2:bordercolor=black:x=(w-text_w)/2:y=1230[v5]" \
-map "[v5]" -map 0:a -af "atrim=0:18,asetpts=PTS-STARTPTS,afade=t=out:st=16:d=2" \
-c:v libx264 -preset medium -crf 20 -pix_fmt yuv420p -r 30 -c:a aac -b:a 128k -shortest action.mp4

# --- 2. Pitch card A (6s): the offer ---
ffmpeg -y -v error -f lavfi -i "color=c=0x0b0b18:s=720x1280:d=6:r=30" -filter_complex \
"[0:v]drawtext=fontfile=$FONT:text='MAKE CLIPS':fontsize=72:fontcolor=white:x=(w-text_w)/2:y=380, \
 drawtext=fontfile=$FONT:text='LIKE THIS':fontsize=72:fontcolor=white:x=(w-text_w)/2:y=470, \
 drawtext=fontfile=$FONT:text='WITH AI':fontsize=72:fontcolor=#ff2e88:x=(w-text_w)/2:y=560, \
 drawtext=fontfile=$FONT:text='AND EARN MONEY':fontsize=58:fontcolor=#ffd94d:x=(w-text_w)/2:y=700" \
-c:v libx264 -preset medium -crf 20 -pix_fmt yuv420p -r 30 -an pitch-a.mp4

# --- 3. Pitch card B (6s): the call to action ---
ffmpeg -y -v error -f lavfi -i "color=c=0x0b0b18:s=720x1280:d=6:r=30" -filter_complex \
"[0:v]drawtext=fontfile=$FONT:text='ON':fontsize=72:fontcolor=white:x=(w-text_w)/2:y=330, \
 drawtext=fontfile=$FONT:text='MAKE.FUN':fontsize=110:fontcolor=#ff2e88:x=(w-text_w)/2:y=430, \
 drawtext=fontfile=$FONT_REG:text='make.fun/bounty/gta6-clipper-01':fontsize=34:fontcolor=white:x=(w-text_w)/2:y=640, \
 drawtext=fontfile=$FONT_REG:text='AI agents build. AI agents earn.':fontsize=30:fontcolor=#bbbbbb:x=(w-text_w)/2:y=720" \
-c:v libx264 -preset medium -crf 20 -pix_fmt yuv420p -r 30 -an pitch-b.mp4

# --- 4. Concat: action (with audio) + pitch A + pitch B (silent) ---
printf "file 'action.mp4'\nfile 'pitch-a.mp4'\nfile 'pitch-b.mp4'\n" > concat.txt
ffmpeg -y -v error -f concat -safe 0 -i concat.txt -i action.mp4 \
-filter_complex "[0:v]setpts=PTS-STARTPTS[v];[1:a]atrim=0:18,asetpts=PTS-STARTPTS[a1];anullsrc=r=44100:cl=stereo[a2];[a1][a2]concat=n=2:v=0:a=1[aout]" \
-map "[v]" -map "[aout]" -c:v libx264 -preset medium -crf 20 -pix_fmt yuv420p -r 30 \
-c:a aac -b:a 128k -movflags +faststart -t 30 "$OUT"

ffprobe -v error -show_entries format=duration,size -show_entries stream=codec_name,width,height,r_frame_rate -of default=noprint_wrappers=1 "$OUT"
ls -la "$OUT"
