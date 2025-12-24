# 🎵 Audio Production Pipeline - Part 1, 2, 3, 4 Merge

Complete solution for generating 4-part song audio and merging them into a single file.

## 📋 Project Overview

This project provides an automated pipeline to:

1. **Generate 4 Audio Parts** (~60 seconds each):
   - **Part 1**: Intro + Verse + Chorus (60s)
   - **Part 2**: Verse 2 + Chorus (60s)
   - **Part 3**: Bridge + Chorus (60s)
   - **Part 4**: Outro (60s)

2. **Merge all audio files** seamlessly with crossfading

3. **Normalize audio** levels for consistent loudness

4. **Output final mixed track** (~4 minutes total)

---

## 📁 File Structure

```
n8n-toolkit/
├── final.json                 # Complete configuration for all 4 parts
├── audio_merger.py            # Python script to generate & merge audio
├── audio_output/              # Generated audio files (created automatically)
│   ├── part1_*.mp3           # Part 1 segment files
│   ├── part2_*.mp3           # Part 2 segment files
│   ├── part3_*.mp3           # Part 3 segment files
│   ├── part4_*.mp3           # Part 4 segment files
│   ├── part1_intro_verse_chorus.mp3
│   ├── part2_verse2_chorus.mp3
│   ├── part3_bridge_chorus.mp3
│   ├── part4_outro.mp3
│   └── final_song_complete.mp3    # Final merged output
└── README.md                  # This file
```

---

## 🎯 Configuration Details

### Part 1: Intro + Verse + Chorus (60s)
- **Intro** (15s): Cheerful greeting narration
- **Verse 1** (25s): Main lyrical content with neutral emotion
- **Chorus 1** (20s): Uplifting chorus with excited emotion

### Part 2: Verse 2 + Chorus (60s)
- **Verse 2** (30s): Second verse with sad/contemplative emotion
- **Chorus** (30s): Repetition of chorus with excited delivery

### Part 3: Bridge + Chorus (60s)
- **Bridge** (35s): Climactic building section with excited emotion
- **Chorus** (25s): Final chorus at accelerated pace (+25% speed)

### Part 4: Outro (60s)
- **Outro Verse** (30s): Closing lyrical content with cheerful emotion
- **Outro Message** (20s): Narrative closing with neutral emotion
- **Outro Ending** (10s): Final message at slower pace (-25% speed)

---

## 🚀 Quick Start

### Prerequisites

1. **Python 3.8+**
   ```bash
   python3 --version
   ```

2. **FFmpeg** (required for audio merging)
   ```bash
   # macOS
   brew install ffmpeg
   
   # Ubuntu/Debian
   sudo apt-get install ffmpeg
   
   # Verify
   ffmpeg -version
   ```

3. **Python Dependencies**
   ```bash
   pip3 install pydub requests
   ```

4. **TTS Service Running**
   - Edge-TTS service on `http://localhost:8880` (primary)
   - OR Orpheus-TTS service on `http://localhost:5005` (fallback)

### Running the Pipeline

```bash
# Navigate to project directory
cd /Users/alvinabhinav/Documents/Projects/n8n-toolkit

# Run the audio production pipeline
python3 audio_merger.py
```

### Expected Output

```
============================================================
🎬 SONG PRODUCTION PIPELINE
============================================================
Project: Song Audio Production - 4 Parts Merge
Total Duration: ~240 seconds (4 minutes)
Output Format: mp3
============================================================

============================================================
🎵 Part 1 – Intro + Verse + Chorus
   Opening section with introduction, first verse, and first chorus
   Target duration: 60s

   📝 Generating: intro (15s)
   🔄 Attempt 1/3... ✅ Success
   ✅ Audio saved to audio_output/part1_intro.mp3
   
   ... [more segments] ...

============================================================
📦 Merging 4 audio files...
   ✅ Loaded audio_output/part1_intro_verse_chorus.mp3 (60000ms)
   ✅ Added audio_output/part2_verse2_chorus.mp3 with 0.5s crossfade (60000ms)
   ... [more merges] ...

💾 Exporting to audio_output/final_song_complete.mp3...
   ✅ Merged audio saved (240.0s total)

🔊 Normalizing audio to -20 LUFS...
   ✅ Audio normalized

============================================================
✅ PRODUCTION COMPLETE!
============================================================
📁 Output Directory: /Users/alvinabhinav/Documents/Projects/n8n-toolkit/audio_output
🎵 Final File: /Users/alvinabhinav/Documents/Projects/n8n-toolkit/audio_output/final_song_complete.mp3
📊 Parts Generated: 4
============================================================
```

---

## 📊 Configuration File (final.json)

The `final.json` file contains:

### Metadata
- Total duration: ~240 seconds
- Output format: MP3
- Bitrate: 192kbps
- Sample rate: 44.1kHz
- Channels: Stereo

### Parts Array
Each part contains:
- **id**: Unique identifier
- **name**: Part display name
- **duration**: Target duration in seconds
- **segments**: Array of audio segments
  - **id**: Segment identifier
  - **type**: "narration" or "lyrics"
  - **text**: Content to convert to speech
  - **duration**: Segment duration
  - **voice**: Voice identifier (e.g., "en-US-AriaNeural")
  - **emotion**: Emotional style (neutral, cheerful, sad, angry, excited)
  - **rate**: Speech rate (slow_50, slow_25, normal, fast_25, fast_50)

### Merge Configuration
- **outputFile**: Final output filename
- **mergeOrder**: Order to concatenate parts
- **transitions**: Crossfade settings
- **audioNormalization**: Loudness normalization (target -20 LUFS)

### TTS API Configuration
- **endpoint**: Primary TTS service URL (port 8880)
- **fallbackEndpoint**: Secondary service URL (port 5005)
- **timeout**: Request timeout in seconds
- **maxRetries**: Retry attempts for failed requests

---

## 🔧 Advanced Usage

### Custom Configuration

Edit `final.json` to customize:

```json
{
  "parts": [
    {
      "segments": [
        {
          "text": "Your custom text here",
          "emotion": "excited",
          "rate": "normal"
        }
      ]
    }
  ]
}
```

### Running with Custom Config

```bash
# Modify final.json then run
python3 audio_merger.py
```

### Troubleshooting

#### TTS Service Not Responding
```bash
# Check if service is running
curl http://localhost:8880/health

# Or start the service
docker compose up -d  # If using Docker
```

#### FFmpeg Not Found
```bash
# Install FFmpeg
brew install ffmpeg  # macOS
# or
sudo apt-get install ffmpeg  # Linux
```

#### Audio Merging Fails
```bash
# Verify pydub is installed
pip3 list | grep pydub

# Reinstall if needed
pip3 install --upgrade pydub
```

#### Out of Memory
- Process one part at a time
- Use shorter text segments
- Reduce bitrate in configuration

---

## 📈 Audio Generation Pipeline

```
[Text Input]
      ↓
[TTS Service - Primary]
      ↓ (fallback if fails)
[TTS Service - Secondary]
      ↓
[MP3 Audio File]
      ↓
[Merge Segments within Part]
      ↓
[Part Audio File (60s)]
      ↓ (repeat for all 4 parts)
      ↓
[Merge All Parts]
      ↓
[Normalize Audio]
      ↓
[Final Song: final_song_complete.mp3 (~4 minutes)]
```

---

## 🎵 Audio Specifications

| Property | Value |
|----------|-------|
| Format | MP3 |
| Bitrate | 192 kbps |
| Sample Rate | 44.1 kHz |
| Channels | 2 (Stereo) |
| Total Duration | ~240 seconds (4 minutes) |
| Crossfade | 0.5 seconds between parts |
| Normalization | -20 LUFS (loudness unit) |

---

## 📝 Customization Guide

### Change Voice
```json
{
  "voice": "en-GB-SoniaNeural"  // British accent
}
```

### Change Emotion
```json
{
  "emotion": "sad"  // or: neutral, cheerful, angry, excited
}
```

### Change Speech Rate
```json
{
  "rate": "fast_50"  // or: slow_50, slow_25, normal, fast_25
}
```

### Add Silence Between Parts
```json
{
  "transitions": {
    "silenceBetweenParts": 2  // 2 seconds silence
  }
}
```

---

## 🐳 Docker Integration

If running TTS service in Docker:

```bash
# Start services
docker compose up -d

# Check service health
curl http://localhost:8880/health

# Run audio pipeline
python3 audio_merger.py

# Stop services
docker compose down
```

---

## 📚 API Reference

### TTS Service - Edge TTS (Port 8880)

```bash
curl -X POST http://localhost:8880/tts \
  -H "Content-Type: application/json" \
  -d '{
    "text": "Hello world",
    "lang": "en-US",
    "emotion": "cheerful",
    "rate": "normal"
  }'
```

### TTS Service - Orpheus (Port 5005)

```bash
curl -X POST http://localhost:5005/v1/audio/speech \
  -H "Content-Type: application/json" \
  -d '{
    "input": "Hello world",
    "voice": "en-US-AriaNeural",
    "model": "orpheus",
    "speed": 1.0
  }'
```

---

## 🎬 Production Steps

The script follows these steps:

1. ✅ Load configuration from `final.json`
2. ✅ Create output directory (`audio_output/`)
3. ✅ For each part (1-4):
   - Generate each segment using TTS
   - Merge segments into part file
4. ✅ Merge all 4 parts into final file
5. ✅ Normalize audio loudness
6. ✅ Output final song

---

## 📊 Performance

Expected processing time:

- **Per segment**: 5-10 seconds (depends on text length & TTS service)
- **Part 1**: ~90 seconds (3 segments)
- **Part 2**: ~60 seconds (2 segments)
- **Part 3**: ~65 seconds (2 segments)
- **Part 4**: ~85 seconds (3 segments)
- **Merging**: ~30 seconds
- **Total**: ~8-10 minutes

---

## 🔐 Important Notes

- **First run** may be slower due to audio processing
- **TTS Service** must be running before execution
- **Disk space** needed: ~500MB for all files
- **Network**: Requires connection to TTS API
- **Audio files** are cached in `audio_output/` directory

---

## 🆘 Support

### Check Logs
```bash
# See detailed output during generation
python3 audio_merger.py  # Already shows detailed progress

# Check TTS service logs (if Docker)
docker compose logs -f tts-service
```

### Validate Configuration
```bash
# Verify JSON syntax
python3 -m json.tool final.json
```

### Reset and Retry
```bash
# Remove old files
rm -rf audio_output/

# Run again
python3 audio_merger.py
```

---

## 📄 License

See main project README for licensing information.

---

## 📞 Next Steps

1. ✅ Review `final.json` for configuration
2. ✅ Ensure TTS services are running
3. ✅ Run `python3 audio_merger.py`
4. ✅ Find final merged audio in `audio_output/final_song_complete.mp3`
5. ✅ Use in n8n workflows or other applications

---

**Happy audio production! 🎵**
