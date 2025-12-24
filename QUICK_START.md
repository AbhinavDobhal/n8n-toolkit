# 🎵 Quick Start Guide - Audio Production Pipeline

**Generated**: December 22, 2025  
**Project**: Song Audio Production - 4 Parts Merge  
**Total Duration**: ~240 seconds (4 minutes)

---

## ⚡ 5-Minute Quick Start

### 1. Install Dependencies (First Time Only)

```bash
# Make setup script executable
chmod +x setup.sh

# Run setup
./setup.sh
```

### 2. Start TTS Services

```bash
# From n8n-toolkit directory
docker compose up -d
```

### 3. Generate Audio

```bash
# Run the audio pipeline
python3 audio_merger.py
```

### 4. Find Your Audio

Your final merged song will be at:
```
audio_output/final_song_complete.mp3
```

---

## 📊 Project Structure

```
4 Parts × ~60 seconds each = ~4 minutes total

Part 1 (60s)          Part 2 (60s)          Part 3 (60s)          Part 4 (60s)
├─ Intro (15s)       ├─ Verse 2 (30s)      ├─ Bridge (35s)       ├─ Outro Verse (30s)
├─ Verse 1 (25s)     └─ Chorus (30s)       └─ Chorus (25s)       ├─ Outro Msg (20s)
└─ Chorus 1 (20s)                                                  └─ Outro End (10s)
```

---

## 📝 Configuration (final.json)

Current settings:
- **Voice**: en-US-AriaNeural
- **Format**: MP3 @ 192kbps
- **Sample Rate**: 44.1kHz
- **Normalization**: -20 LUFS

Edit `final.json` to customize:
```json
{
  "parts": [{
    "segments": [{
      "text": "Your text here",
      "emotion": "cheerful",  // neutral, cheerful, sad, angry, excited
      "rate": "normal"        // slow_50, slow_25, normal, fast_25, fast_50
    }]
  }]
}
```

---

## 🎯 Audio Files Generated

### Individual Parts
- `part1_intro_verse_chorus.mp3` (60s)
- `part2_verse2_chorus.mp3` (60s)
- `part3_bridge_chorus.mp3` (60s)
- `part4_outro.mp3` (60s)

### Segment Files
- `part1_intro.mp3`
- `part1_verse1.mp3`
- `part1_chorus1.mp3`
- ... (and so on for all segments)

### Final Output
- `final_song_complete.mp3` (240s) ← **THIS IS YOUR FINAL FILE**

---

## 🔧 Customization Examples

### Change Voice
```json
{
  "voice": "en-GB-SoniaNeural"  // British English
  // or "en-AU-NatashaNeural" for Australian
}
```

### Change Text
Edit the `text` field in any segment in `final.json`

### Change Emotion
```json
{
  "emotion": "sad"  // Changes vocal delivery
}
```

### Change Speech Rate
```json
{
  "rate": "fast_50"  // Speeds up delivery by 50%
}
```

---

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| "TTS Service not responding" | Run `docker compose up -d` to start services |
| "FFmpeg not found" | Run `brew install ffmpeg` (macOS) or `sudo apt-get install ffmpeg` (Linux) |
| "pydub import error" | Run `pip3 install pydub` |
| "Audio quality issues" | Increase bitrate in `final.json` (e.g., 320k) |
| "Takes too long" | Reduce text length in segments |

---

## 📊 Performance Metrics

- **Segment generation**: ~5-10 seconds per 100 words
- **Part merging**: ~10-20 seconds
- **Full pipeline**: ~10-12 minutes
- **Final file size**: ~30-40 MB

---

## 🚀 Commands Reference

```bash
# Setup (first time)
chmod +x setup.sh && ./setup.sh

# Start services
docker compose up -d

# Generate audio
python3 audio_merger.py

# Stop services
docker compose down

# View logs
docker compose logs -f

# Clean up old files
rm -rf audio_output/*
```

---

## 📁 File Summary

| File | Purpose |
|------|---------|
| `final.json` | Complete configuration for all 4 parts |
| `audio_merger.py` | Python script to generate & merge audio |
| `setup.sh` | Automatic setup script |
| `AUDIO_PRODUCTION_README.md` | Detailed documentation |
| `QUICK_START.md` | This file |
| `audio_output/` | Generated audio files |

---

## ✅ Verification Checklist

Before running:
- [ ] Python 3 installed (`python3 --version`)
- [ ] FFmpeg installed (`ffmpeg -version`)
- [ ] Dependencies installed (`pip3 list | grep pydub`)
- [ ] Docker services running (`docker compose ps`)
- [ ] final.json exists and is valid JSON

---

## 🎬 Step-by-Step Execution

```bash
# 1. Navigate to project
cd /Users/alvinabhinav/Documents/Projects/n8n-toolkit

# 2. Setup (first time only)
./setup.sh

# 3. Start services
docker compose up -d && sleep 10

# 4. Run pipeline
python3 audio_merger.py

# 5. Check output
ls -lh audio_output/

# 6. Play final audio
# Use any media player to play:
# audio_output/final_song_complete.mp3
```

---

## 📞 Quick Links

- **Full Documentation**: [AUDIO_PRODUCTION_README.md](AUDIO_PRODUCTION_README.md)
- **Main Project**: [README.md](README.md)
- **Configuration**: [final.json](final.json)
- **Script**: [audio_merger.py](audio_merger.py)

---

## 💡 Pro Tips

1. **Test with small text first** - Use short segments to verify setup
2. **Keep backup of final.json** - Before making large edits
3. **Check service health** - Run `curl http://localhost:8880/health`
4. **Monitor disk space** - Each segment needs ~1-2 MB
5. **Use consistent voice/emotion** - For smooth transitions

---

**🎵 Ready to create your audio production! Good luck!**

---

*Last Updated: December 22, 2025*  
*For support, see AUDIO_PRODUCTION_README.md*
