#!/usr/bin/env bash
# gta6-clipper-01 — render the 30-second vertical Short.
#
# What it makes: a 720x1280, 30fps Short built from Rockstar's official
# GTA VI Trailer 2 (https://www.youtube.com/watch?v=VQRLujxTm3c).
# The trailer itself was fetched earlier with yt-dlp; this script only
# cuts and dresses footage that is already on disk. No other creator's
# edit is used, and the trailer's own end card ("MAY 26, 2026") is left
# out on purpose — the game actually launched 2026-11-19, so that date
# would mislead anyone watching.
#
# The clip has two parts:
#   1. The escape (18s): the trailer's climax run, 138-156s in — helicopter
#      over the swamp, Lucia & Jason on the jet ski, Jason's bike under the
#      seaplane, night ride, red car, sunset over Vice City. One continuous
#      arc, not a montage. A hook, "GTA 6 IS OUT NOW", lands in the first
#      two seconds, and title cards roll over the action. Trailer audio
#      plays underneath and fades out in the last two seconds.
#   2. The pitch (12s): two silent 6s cards on a dark background telling
#      viewers they can make clips like this with AI and earn money on
#      make.fun, with the bounty page on screen.
#
# Why the blurred background: the copy of the trailer YouTube served this
# session is 640x360 (format 18, the only format available without a
# login). Instead of cropping the 16:9 frame and upscaling it five times,
# the frame is shown at 720px wide — near its native width — over a
# darkened, blurred, full-bleed copy of itself. Standard Shorts layout.
#
# Needs: ffmpeg on PATH, and gta6-trailer2-720.mp4 beside this script.
# Run it from anywhere; it works in its own directory.
# Output: gta6-clipper-01-short.mp4 (30.0s, 720x1280, H.264 + AAC).

set -euo pipefail
cd "$(dirname "$0")"

# --- inputs, outputs, and the clip's fixed numbers -----------------------
TRAILER="gta6-trailer2-720.mp4"
CLIP="gta6-clipper-01-short.mp4"
ACTION="action.mp4"
CARD_A="pitch-a.mp4"
CARD_B="pitch-b.mp4"
LIST="concat.txt"

BOLD="/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
PLAIN="/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"

W=720
H=1280
FPS=30

ESCAPE_START=138   # seconds into the trailer
ESCAPE_LEN=18      # seconds of action
PITCH_LEN=6        # seconds per pitch card
TOTAL_LEN=30

# Where the 16:9 frame sits on the 720x1280 canvas: 720x405, centered
# horizontally, with the blurred background filling the rest.
FG_W=720
FG_H=405
FG_Y=437

# --- 1. the escape run ----------------------------------------------------
# The video chain: split the trimmed frame into a blurred full-bleed
# background (darkened a little, saturation lifted) and a sharp foreground,
# then layer the foreground over the background and stamp the title cards
# on top, one at a time, each visible only in its own time window.
ffmpeg -y -v error -ss "$ESCAPE_START" -i "$TRAILER" -t "$ESCAPE_LEN" -filter_complex \
"[0:v]trim=0:${ESCAPE_LEN},setpts=PTS-STARTPTS,split[a][b]; \
 [a]scale=${W}:${H}:force_original_aspect_ratio=increase,crop=${W}:${H},gblur=sigma=28,eq=brightness=-0.30:saturation=1.1[bg]; \
 [b]scale=${FG_W}:${FG_H}[fg]; \
 [bg][fg]overlay=(W-w)/2:${FG_Y}[v0]; \
 [v0]drawtext=fontfile=${BOLD}:text='GTA 6 IS OUT NOW':fontsize=62:fontcolor=white:borderw=3:bordercolor=black:x=(w-text_w)/2:y=110:enable='between(t,0,3.2)'[v1]; \
 [v1]drawtext=fontfile=${BOLD}:text='LUCIA & JASON':fontsize=56:fontcolor=white:borderw=3:bordercolor=black:x=(w-text_w)/2:y=110:enable='between(t,3.6,8)'[v2]; \
 [v2]drawtext=fontfile=${BOLD}:text='VICE CITY, USA':fontsize=56:fontcolor=white:borderw=3:bordercolor=black:x=(w-text_w)/2:y=110:enable='between(t,8.4,13)'[v3]; \
 [v3]drawtext=fontfile=${BOLD}:text='THE WAIT IS OVER':fontsize=56:fontcolor=#ffd94d:borderw=3:bordercolor=black:x=(w-text_w)/2:y=110:enable='between(t,13.4,18)'[v4]; \
 [v4]drawtext=fontfile=${PLAIN}:text='Footage\: Rockstar Games - GTA VI Trailer 2':fontsize=22:fontcolor=white:borderw=2:bordercolor=black:x=(w-text_w)/2:y=1230[v5]" \
-map "[v5]" -map 0:a -af "atrim=0:${ESCAPE_LEN},asetpts=PTS-STARTPTS,afade=t=out:st=16:d=2" \
-c:v libx264 -preset medium -crf 20 -pix_fmt yuv420p -r "$FPS" -c:a aac -b:a 128k -shortest "$ACTION"

# --- 2. pitch card A (6s): the offer ---------------------------------------
ffmpeg -y -v error -f lavfi -i "color=c=0x0b0b18:s=${W}x${H}:d=${PITCH_LEN}:r=${FPS}" -filter_complex \
"[0:v]drawtext=fontfile=${BOLD}:text='MAKE CLIPS':fontsize=72:fontcolor=white:x=(w-text_w)/2:y=380, \
 drawtext=fontfile=${BOLD}:text='LIKE THIS':fontsize=72:fontcolor=white:x=(w-text_w)/2:y=470, \
 drawtext=fontfile=${BOLD}:text='WITH AI':fontsize=72:fontcolor=#ff2e88:x=(w-text_w)/2:y=560, \
 drawtext=fontfile=${BOLD}:text='AND EARN MONEY':fontsize=58:fontcolor=#ffd94d:x=(w-text_w)/2:y=700" \
-c:v libx264 -preset medium -crf 20 -pix_fmt yuv420p -r "$FPS" -an "$CARD_A"

# --- 3. pitch card B (6s): where to go --------------------------------------
ffmpeg -y -v error -f lavfi -i "color=c=0x0b0b18:s=${W}x${H}:d=${PITCH_LEN}:r=${FPS}" -filter_complex \
"[0:v]drawtext=fontfile=${BOLD}:text='ON':fontsize=72:fontcolor=white:x=(w-text_w)/2:y=330, \
 drawtext=fontfile=${BOLD}:text='MAKE.FUN':fontsize=110:fontcolor=#ff2e88:x=(w-text_w)/2:y=430, \
 drawtext=fontfile=${PLAIN}:text='make.fun/bounty/gta6-clipper-01':fontsize=34:fontcolor=white:x=(w-text_w)/2:y=640, \
 drawtext=fontfile=${PLAIN}:text='AI agents build. AI agents earn.':fontsize=30:fontcolor=#bbbbbb:x=(w-text_w)/2:y=720" \
-c:v libx264 -preset medium -crf 20 -pix_fmt yuv420p -r "$FPS" -an "$CARD_B"

# --- 4. join the three pieces ----------------------------------------------
# Video: action, then the two cards. Audio: the action's 18s, then silence
# for the remaining 12s (the cards are silent by design).
printf "file '%s'\nfile '%s'\nfile '%s'\n" "$ACTION" "$CARD_A" "$CARD_B" > "$LIST"
ffmpeg -y -v error -f concat -safe 0 -i "$LIST" -i "$ACTION" \
-filter_complex "[0:v]setpts=PTS-STARTPTS[v];[1:a]atrim=0:${ESCAPE_LEN},asetpts=PTS-STARTPTS[a1];anullsrc=r=44100:cl=stereo[a2];[a1][a2]concat=n=2:v=0:a=1[aout]" \
-map "[v]" -map "[aout]" -c:v libx264 -preset medium -crf 20 -pix_fmt yuv420p -r "$FPS" \
-c:a aac -b:a 128k -movflags +faststart -t "$TOTAL_LEN" "$CLIP"

# --- 5. prove it ------------------------------------------------------------
ffprobe -v error -show_entries format=duration,size -show_entries stream=codec_name,width,height,r_frame_rate -of default=noprint_wrappers=1 "$CLIP"
sha256sum "$CLIP"
ls -la "$CLIP"
