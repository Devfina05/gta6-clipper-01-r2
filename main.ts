// gta6-clipper-01 — entrypoint.
//
// The entry itself is a YouTube Short; this program only delivers its
// address to the grader. It reads VIDEO.json from the repo, checks that it
// really points at a YouTube Short, and copies it byte-for-byte into the
// output directory, where the grader picks it up.
//
// It runs on Node with the standard library only — no dependencies.
//
// The output directory is a mount point inside the grading container, so
// it is only ever created, never removed: deleting a mount throws
// "Device or resource busy" and fails the run. (That exact mistake broke
// an earlier entry.) Locally you can point the two directories anywhere:
//
//   mkdir -p out && MAKEFUN_BOT_DIR=. MAKEFUN_OUTPUT_DIR=out node main.ts

import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";

// Where the repo (and VIDEO.json) lives, and where the grader reads from.
// Both can be overridden for local runs; the defaults are the grader's.
const repoDir = process.env.MAKEFUN_BOT_DIR ?? "/bot";
const outDir = process.env.MAKEFUN_OUTPUT_DIR ?? "/output";

const videoFileIn = join(repoDir, "VIDEO.json");
const videoFileOut = join(outDir, "VIDEO.json");

// A Shorts address looks like https://youtube.com/shorts/<11-char id>.
// (www. and m. hosts are fine too.) The id is the only capture group.
const SHORTS_URL = /^https:\/\/(?:www\.|m\.)?youtube\.com\/shorts\/([A-Za-z0-9_-]{11})$/;

function die(message: string): never {
  console.error(`main.ts: ${message}`);
  process.exit(1);
}

if (!existsSync(videoFileIn)) {
  die(`${videoFileIn} is missing — the repo must contain VIDEO.json`);
}

let raw: Buffer;
try {
  raw = readFileSync(videoFileIn);
} catch (err) {
  die(`could not read VIDEO.json: ${(err as Error).message}`);
}

let doc: unknown;
try {
  doc = JSON.parse(raw.toString("utf-8"));
} catch (err) {
  die(`VIDEO.json is not valid JSON: ${(err as Error).message}`);
}

if (typeof doc !== "object" || doc === null || Array.isArray(doc)) {
  die('VIDEO.json must be a JSON object, e.g. {"url": "https://youtube.com/shorts/..."}');
}

const url = (doc as Record<string, unknown>).url;
if (typeof url !== "string" || url.length === 0) {
  die('VIDEO.json must hold a "url" string field');
}

const match = SHORTS_URL.exec(url);
if (!match) {
  die(`"url" must be a youtube.com/shorts address with an 11-character video id, got: ${url}`);
}

// Create the output directory. Never delete it — see the header note.
mkdirSync(outDir, { recursive: true });

// Copy byte-for-byte so the grader sees exactly what the repo holds.
writeFileSync(videoFileOut, raw);

console.log(`wrote ${videoFileOut} (${raw.length} bytes)`);
console.log(`video url: ${url}`);
console.log(`video id: ${match[1]}`);
