// gta6-clipper-01 entrypoint (Node 22, standard library only).
//
// The entry is the YouTube video itself: this program's only job is to hand
// the video's address to the gate. It reads VIDEO.json from the repository
// and writes it byte-for-byte to /output/VIDEO.json, where the gate reads it.
// Nothing this program writes is judged; the house reads the video from
// YouTube (its public totals, its description) and ranks it on views.
//
// Output-dir rule: /output is a mount point inside the grading container,
// so this program NEVER removes the output directory itself. It only
// creates it (mkdirSync, recursive) and writes VIDEO.json inside it.
// Removing a mount point throws "Device or resource busy" and fails.
//
// Outside the grader, MAKEFUN_BOT_DIR and MAKEFUN_OUTPUT_DIR stand in
// for /bot and /output:
//   mkdir -p out && MAKEFUN_BOT_DIR=. MAKEFUN_OUTPUT_DIR=out node main.ts

import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';

const BOT_DIR = process.env.MAKEFUN_BOT_DIR ?? '/bot';
const OUTPUT_DIR = process.env.MAKEFUN_OUTPUT_DIR ?? '/output';

const SOURCE = join(BOT_DIR, 'VIDEO.json');
const TARGET = join(OUTPUT_DIR, 'VIDEO.json');

if (!existsSync(SOURCE)) {
  console.error(`main.ts: ${SOURCE} is missing; the repo must hold VIDEO.json`);
  process.exit(1);
}

// Parse first so a malformed VIDEO.json fails here with a clear error
// instead of handing the gate a file it cannot read.
let parsed: unknown;
let raw: Buffer;
try {
  raw = readFileSync(SOURCE);
  parsed = JSON.parse(raw.toString('utf-8'));
} catch (err) {
  console.error(`main.ts: VIDEO.json could not be parsed: ${(err as Error).message}`);
  process.exit(1);
}
if (typeof parsed !== 'object' || parsed === null || Array.isArray(parsed)) {
  console.error('main.ts: VIDEO.json must be a JSON object like {"url": "..."}');
  process.exit(1);
}
if (typeof (parsed as Record<string, unknown>).url !== 'string') {
  console.error('main.ts: VIDEO.json must hold a string "url" field');
  process.exit(1);
}
const videoUrl = (parsed as Record<string, unknown>).url as string;
// Warn (do not fail) when the url is not a YouTube video address yet: a
// pasted address with a typo should be caught at a glance in the run log.
// The gate needs one of /shorts/<id>, /watch?v=<id> or youtu.be/<id> with
// an 11-character video id, so a matching shape with a short id warns too.
const idMatch = videoUrl.match(
  /(?:shorts\/|watch\?v=|youtu\.be\/)([A-Za-z0-9_-]+)/,
);
if (!/^https:\/\/(www\.|m\.)?(youtube\.com\/(shorts\/|watch\?v=)|youtu\.be\/)/.test(videoUrl)) {
  console.error(
    `main.ts: warning: url does not look like a YouTube video address: ${videoUrl}`,
  );
} else if (!idMatch || idMatch[1].length !== 11) {
  console.error(
    `main.ts: warning: url has no 11-character YouTube video id: ${videoUrl}`,
  );
}

// Create the output directory; never delete it (see the header note).
mkdirSync(OUTPUT_DIR, { recursive: true });

// Copy the file byte-for-byte so what the gate reads is exactly what
// the repository holds.
writeFileSync(TARGET, raw);

console.log(`wrote ${TARGET} (${raw.length} bytes)`);
console.log(`video url: ${videoUrl}`);
if (idMatch) {
  console.log(`video id: ${idMatch[1]}`);
}
