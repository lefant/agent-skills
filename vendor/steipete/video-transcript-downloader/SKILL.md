---
name: video-transcript-downloader
description: Download videos, audio, subtitles, and clean paragraph-style transcripts from YouTube and any other yt-dlp supported site. Use when asked to “download this video”, “save this clip”, “rip audio”, “get subtitles”, “get transcript”, or to troubleshoot yt-dlp/ffmpeg and formats/playlists.
---

# Video Transcript Downloader

`node {baseDir}/scripts/vtd.js` can:
- Print a transcript as a clean paragraph (timestamps optional).
- Download video/audio/subtitles.

Transcript behavior:
- YouTube: fetch via `youtube-transcript-plus` when possible.
- Otherwise: pull subtitles via `yt-dlp`, then clean into a paragraph.

## Setup

```bash
cd {baseDir} && npm ci  # Requires Node.js 20+
```

CLI syntax:

```bash
node {baseDir}/scripts/vtd.js --help
node {baseDir}/scripts/vtd.js transcript --help
```

Subcommands support focused help without requiring `--url`.

## Transcript (default: clean paragraph)

```bash
node {baseDir}/scripts/vtd.js transcript --url 'https://…'
node {baseDir}/scripts/vtd.js transcript --url 'https://…' --lang en
node {baseDir}/scripts/vtd.js transcript --url 'https://…' --timestamps
node {baseDir}/scripts/vtd.js transcript --url 'https://…' --keep-brackets
```

## Download video / audio / subtitles

```bash
node {baseDir}/scripts/vtd.js download --url 'https://…' --output-dir ~/Downloads
node {baseDir}/scripts/vtd.js audio --url 'https://…' --output-dir ~/Downloads
node {baseDir}/scripts/vtd.js subs --url 'https://…' --output-dir ~/Downloads --lang en
```

## Formats (list + choose)

List available formats (format ids, resolution, container, audio-only, etc):

```bash
node {baseDir}/scripts/vtd.js formats --url 'https://…'
```

Download a specific format id (example):

```bash
node {baseDir}/scripts/vtd.js download --url 'https://…' --output-dir ~/Downloads -- --format 137+140
```

Prefer MP4 container without re-encoding (remux when possible):

```bash
node {baseDir}/scripts/vtd.js download --url 'https://…' --output-dir ~/Downloads -- --remux-video mp4
```

## Notes

- Default transcript output is a single paragraph. Use `--timestamps` only when asked.
- Bracketed cues like `[Music]` are stripped by default; keep them via `--keep-brackets`.
- Pass extra `yt-dlp` args after `--` for `transcript` fallback, `download`, `audio`, `subs`, `formats`.

```bash
node {baseDir}/scripts/vtd.js formats --url 'https://…' -- -v
```

## Troubleshooting (only when needed)

- Missing `yt-dlp` / `ffmpeg`:

```bash
brew install yt-dlp ffmpeg
```

- Verify:

```bash
yt-dlp --version
ffmpeg -version | head -n 1
```
