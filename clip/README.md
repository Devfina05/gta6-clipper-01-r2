# The clip — shot by shot

Source: Rockstar Games' official **Grand Theft Auto VI Trailer 2**
(https://www.youtube.com/watch?v=VQRLujxTm3c), downloaded in-session with
yt-dlp. No other creator's edit is used. The trailer's own end card
("MAY 26, 2026") is deliberately NOT in the clip: the game actually
launched 2026-11-19, so that date would mislead viewers.

## The escape (one arc, 0:00–0:18)

The trailer's climax escape run, 138–156s of the trailer, one continuous
sequence: helicopter over the swamp → Lucia & Jason on the jet ski →
Jason's bike under the seaplane → night ride → red car → sunset over Vice
City. It was chosen because it is the trailer's most kinetic stretch and
every shot still reads at phone size.

On-screen text (DejaVu Sans Bold, white with a black border):

- 0.0–3.2s — **GTA 6 IS OUT NOW** (the hook, inside the first 2 seconds)
- 3.6–8.0s — **LUCIA & JASON**
- 8.4–13.0s — **VICE CITY, USA**
- 13.4–18.0s — **THE WAIT IS OVER** (yellow, over the sunset skyline)
- throughout — small credit: "Footage: Rockstar Games – GTA VI Trailer 2"

Trailer audio runs under the action and fades out in the last 2 seconds.

## The pitch (0:18–0:30, two 6s cards, dark background)

Card A: **MAKE CLIPS LIKE THIS WITH AI / AND EARN MONEY**
Card B: **ON MAKE.FUN** + `make.fun/bounty/gta6-clipper-01` +
"AI agents build. AI agents earn."

That is the make.fun pitch the bounty requires: viewers are told they can
make money on make.fun by making clips with AI, and make.fun is named on
screen together with the bounty page.

## Technical notes

- 720x1280, 30fps, H.264 + AAC, 30.0s, ~4.4 MB, faststart for upload.
- The copy of the trailer YouTube served this session was 640x360
  (format 18 — the only format available without a login under YouTube's
  SABR experiment), so the Short uses a blurred-background vertical
  layout: the 16:9 frame is shown at 720px wide (near-native) over a
  darkened, blurred full-bleed version of itself, instead of a center
  crop upscaled five times.
- Build: `bash clip/build_clip.sh` (needs the trailer file
  `gta6-trailer2-720.mp4` beside it and ffmpeg on PATH). The rendered
  file `gta6-clipper-01-short.mp4` is intentionally NOT committed to the
  repo: the entry is the YouTube video, and the repo stays small.
