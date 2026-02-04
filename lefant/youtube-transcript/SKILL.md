---
name: youtube-transcript
description: Fetch YouTube video transcripts using uvx and youtube-transcript-api
invocationPattern: when user provides a YouTube URL or asks to get/fetch a YouTube transcript
---

# YouTube Transcript Skill

## Purpose

Fetch transcripts from YouTube videos for analysis, note-taking, research, or content extraction. Uses `uvx` to run `youtube-transcript-api` without requiring installation.

## When to Use

Call this skill when:
- User provides a YouTube URL (e.g., `https://www.youtube.com/watch?v=VIDEO_ID`)
- User asks to "get the transcript", "fetch YouTube transcript", or "transcribe this video"
- User wants to analyze, summarize, or extract content from a YouTube video
- User needs video content for research or documentation purposes

## Quick Reference

**Basic usage:**
```bash
# From full URL
uvx --from youtube-transcript-api youtube_transcript_api VIDEO_ID --format text

# Extract video ID from URL
# https://www.youtube.com/watch?v=LvLdNkgO-N0 → LvLdNkgO-N0
```

**Output formats:**
- `--format text` - Plain text (recommended for reading/analysis)
- `--format json` - JSON with timestamps
- `--format srt` - SubRip subtitle format
- `--format vtt` - WebVTT subtitle format

**Language selection:**
```bash
# Specific language
uvx --from youtube-transcript-api youtube_transcript_api VIDEO_ID --languages en --format text

# Multiple language preferences
uvx --from youtube-transcript-api youtube_transcript_api VIDEO_ID --languages en,es,fr --format text
```

## Video ID Extraction

YouTube URLs come in various formats:

| Format | Example | Video ID |
|--------|---------|----------|
| Standard | `https://www.youtube.com/watch?v=LvLdNkgO-N0` | `LvLdNkgO-N0` |
| Short | `https://youtu.be/LvLdNkgO-N0` | `LvLdNkgO-N0` |
| Embed | `https://www.youtube.com/embed/LvLdNkgO-N0` | `LvLdNkgO-N0` |
| Mobile | `https://m.youtube.com/watch?v=LvLdNkgO-N0` | `LvLdNkgO-N0` |

**Extract video ID with bash:**
```bash
# From standard URL
echo "https://www.youtube.com/watch?v=LvLdNkgO-N0" | grep -oP '(?<=v=)[^&]*'

# From short URL
echo "https://youtu.be/LvLdNkgO-N0" | grep -oP '(?<=youtu.be/)[^?]*'

# Universal (works for most formats)
echo "URL" | sed -E 's/.*[?&v=|youtu.be\/]([a-zA-Z0-9_-]{11}).*/\1/'
```

## Saving Transcripts

Transcripts can be saved to appropriate vault locations based on use case:

| Use Case | Location | Example |
|----------|----------|---------|
| Research material | `3-resources/transcripts/` | `3-resources/transcripts/youtube-VIDEOID-title.md` |
| Project reference | `1-projects/PROJECT/references/` | `1-projects/my-project/references/video-transcript.md` |
| Area knowledge | `2-areas/AREA/references/` | `2-areas/development/references/claude-code-tutorial.md` |
| Archived content | `4-archives/transcripts/` | `4-archives/transcripts/2026-01-old-tutorial.md` |

**Naming convention:**
```
youtube-[video-id]-brief-description.md
```

Examples:
- `youtube-LvLdNkgO-N0-claude-code-advanced-techniques.md`
- `youtube-dQw4w9WgXcQ-rickroll.md`

## Skill Behavior

When invoked:

### 1. Extract Video ID
Parse the provided URL to extract the 11-character video ID:
```bash
VIDEO_ID=$(echo "$URL" | sed -E 's/.*[?&v=|youtu.be\/]([a-zA-Z0-9_-]{11}).*/\1/')
```

### 2. Fetch Transcript
Use uvx to fetch the transcript without installation:
```bash
uvx --from youtube-transcript-api youtube_transcript_api "$VIDEO_ID" --format text
```

### 3. Handle Output
The output may be large (>50KB). Common approaches:

**Option A: Display excerpt**
Show first ~2000 characters and ask if user wants it saved

**Option B: Save directly**
If user asked to "save" or "create note", save to appropriate location

**Option C: Summarize**
If user asked for summary, use the transcript as context for analysis

### 4. Save to Vault (if requested)
```bash
# Save with proper naming
OUTPUT_FILE="3-resources/transcripts/youtube-${VIDEO_ID}-${BRIEF_TITLE}.md"

# Add frontmatter
cat > "$OUTPUT_FILE" <<EOF
---
source: https://www.youtube.com/watch?v=${VIDEO_ID}
fetched: $(date +%Y-%m-%d)
type: youtube-transcript
---

# ${VIDEO_TITLE}

${TRANSCRIPT_CONTENT}
EOF
```

### 5. Error Handling

Common errors and solutions:

| Error | Cause | Solution |
|-------|-------|----------|
| "Subtitles are disabled" | Video has no transcript | Inform user, suggest alternatives |
| "Video unavailable" | Invalid ID or region lock | Verify URL/ID |
| "Could not retrieve transcript" | Language mismatch | Try `--languages en,auto` |

## Example Workflow

```bash
# 1. User provides URL
URL="https://www.youtube.com/watch?v=LvLdNkgO-N0"

# 2. Extract video ID
VIDEO_ID=$(echo "$URL" | sed -E 's/.*[?&v=|youtu.be\/]([a-zA-Z0-9_-]{11}).*/\1/')

# 3. Fetch transcript
TRANSCRIPT=$(uvx --from youtube-transcript-api youtube_transcript_api "$VIDEO_ID" --format text)

# 4. Save to vault
cat > "3-resources/transcripts/youtube-${VIDEO_ID}-how-i-ai-claude-code.md" <<EOF
---
source: https://www.youtube.com/watch?v=${VIDEO_ID}
fetched: $(date +%Y-%m-%d)
type: youtube-transcript
title: "How I AI - Advanced Claude Code Techniques"
---

# How I AI - Advanced Claude Code Techniques with John Lindquist

${TRANSCRIPT}
EOF
```

## Advanced Usage

### Timestamp Preservation
Use JSON format to preserve timestamps for detailed analysis:
```bash
uvx --from youtube-transcript-api youtube_transcript_api VIDEO_ID --format json | jq -r '.[] | "[\(.start | floor)]s: \(.text)"'
```

### Batch Processing
Process multiple videos:
```bash
for video_id in VIDEO_ID1 VIDEO_ID2 VIDEO_ID3; do
  uvx --from youtube-transcript-api youtube_transcript_api "$video_id" --format text > "transcript-${video_id}.txt"
done
```

### Language Detection
List available languages:
```bash
uvx --from youtube-transcript-api youtube_transcript_api VIDEO_ID --list-transcripts
```

## Related Tools

- **yt-dlp**: Alternative tool for downloading videos and subtitles (can run via `uvx yt-dlp`)
- **youtube-dl**: Older alternative (less maintained)
- **WebFetch**: For general web content (doesn't work well for YouTube)

## Related Skills

This skill complements other research and documentation workflows:
- **Web clipping skills**: For capturing written content
- **Note-taking skills**: For processing and summarizing transcripts
- **Research skills**: For building knowledge bases from video content

## Common Use Cases

1. **Research Documentation**: Capture talks, tutorials, interviews for reference
2. **Content Analysis**: Extract key points from educational videos
3. **Meeting/Talk Notes**: Convert recorded presentations to searchable text
4. **Accessibility**: Create text versions of video content
5. **Quote Extraction**: Find specific statements or explanations

## Tips

- First fetch downloads Python 3.14, subsequent runs are instant
- Large transcripts (>50KB) should be saved to files rather than displayed
- Auto-generated transcripts may have typos/errors
- Manual transcripts (when available) are more accurate
- Consider asking user where to save before creating files
- Add metadata (title, date, source) to saved transcripts

## Skill Activation

This skill activates when:
- User provides a YouTube URL in their message
- User explicitly requests a transcript: "get transcript from..."
- User asks to analyze/summarize a YouTube video
- User asks about YouTube transcript capabilities
