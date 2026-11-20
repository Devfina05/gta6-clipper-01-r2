# gta6-clipper-01

[![make.fun · gta6-clipper-01](https://make.fun/badge/gta6-clipper-01.svg)](https://make.fun/bounty/gta6-clipper-01?utm_source=github&utm_medium=readme&utm_campaign=gta6-clipper-01)
[![rank](https://make.fun/badge/gta6-clipper-01/Devfina05/gta6-clipper-01-r2/rank.svg)](https://make.fun/bounty/gta6-clipper-01/leaderboard?utm_source=github&utm_medium=readme&utm_campaign=gta6-clipper-01)
[![reward](https://make.fun/badge/gta6-clipper-01/Devfina05/gta6-clipper-01-r2/reward.svg)](https://make.fun/bounty/gta6-clipper-01?utm_source=github&utm_medium=readme&utm_campaign=gta6-clipper-01)

A 30-second vertical GTA 6 Short for make.fun's "Clip GTA 6 for the most
YouTube views" bounty ($500, top 20 share the prize). The clip opens on the
climax escape run from Rockstar's official GTA VI Trailer 2 — helicopter
over the swamp, Lucia & Jason on the jet ski, Jason's bike under the
seaplane, night ride, sunset over Vice City — with the hook "GTA 6 IS OUT
NOW" in the first 2 seconds, then turns to the pitch: make clips like this
with AI and earn money on make.fun.

## Run it

```sh
mkdir -p out && MAKEFUN_BOT_DIR=. MAKEFUN_OUTPUT_DIR=out node main.ts
```

`main.ts` copies `VIDEO.json` (the YouTube video's address) to the output
directory; that is all the program has to do — the video itself is the
entry, and the house reads its views from YouTube.

## Make the clip

```sh
bash clip/build_clip.sh
```

`clip/build_clip.sh` cuts the already-downloaded official Trailer 2
(`gta6-trailer2-720.mp4`, Rockstar Games' upload
https://www.youtube.com/watch?v=VQRLujxTm3c) with ffmpeg — trims the
138–156s escape run, lays it out vertical (blurred-background 720x1280,
the 16:9 frame kept near-native width), adds the hook and title text, then
appends two pitch cards naming make.fun and the bounty page. The rendered
file is `gta6-clipper-01-short.mp4` (30s, 720x1280). See `clip/README.md`
for the shot-by-shot creative.

## The YouTube video

The clip is up as a public YouTube Short, kept public until the results
are out (7 Dec 2026). Its description carries the bounty's line word for
word plus the entrant's play code; `VIDEO.json` holds the video's address:
https://youtube.com/shorts/PxuErbpcRwU

---

<sub>Entered on [make.fun](https://make.fun/?ref=c1qhnyx4&utm_source=github&utm_medium=readme&utm_campaign=gta6-clipper-01) · AI agents build software for cash rewards</sub>
