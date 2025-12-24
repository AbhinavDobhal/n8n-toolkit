#!/usr/bin/env python3
"""
Audio Merger & TTS Generator
Generates audio from text segments and merges them into a complete song.

Requirements:
- pydub: pip install pydub
- FFmpeg: brew install ffmpeg (macOS) or apt-get install ffmpeg (Linux)
- requests: pip install requests

Usage:
    python audio_merger.py
"""

import json
import os
import sys
import requests
import subprocess
from pathlib import Path
from typing import List, Dict, Optional
from pydub import AudioSegment
import time


class AudioGenerator:
    """Generate audio from text using TTS services."""
    
    def __init__(self, primary_url: str = "http://localhost:8880/tts",
                 fallback_url: str = "http://localhost:5005/v1/audio/speech",
                 timeout: int = 60,
                 max_retries: int = 3):
        self.primary_url = primary_url
        self.fallback_url = fallback_url
        self.timeout = timeout
        self.max_retries = max_retries
    
    def generate_audio(self, text: str, voice: str = "en-US-AriaNeural",
                      emotion: str = "neutral", rate: str = "normal",
                      output_path: str = None) -> Optional[str]:
        """
        Generate audio from text using TTS service.
        
        Args:
            text: Text to convert to speech
            voice: Voice identifier
            emotion: Emotional style
            rate: Speech rate
            output_path: Optional path to save audio file
            
        Returns:
            Path to generated audio file or None if failed
        """
        
        # Try primary service first
        audio_data = self._try_service(
            self.primary_url,
            text, voice, emotion, rate
        )
        
        # Fallback to secondary service if primary fails
        if audio_data is None:
            print(f"  ⚠️  Primary service failed, trying fallback...")
            audio_data = self._try_service(
                self.fallback_url,
                text, voice, emotion, rate
            )
        
        if audio_data is None:
            print(f"  ❌ Failed to generate audio after {self.max_retries} retries")
            return None
        
        # Save audio to file
        if output_path is None:
            output_path = f"output_{int(time.time())}.mp3"
        
        try:
            with open(output_path, 'wb') as f:
                f.write(audio_data)
            print(f"  ✅ Audio saved to {output_path}")
            return output_path
        except Exception as e:
            print(f"  ❌ Failed to save audio: {e}")
            return None
    
    def _try_service(self, url: str, text: str, voice: str,
                     emotion: str, rate: str) -> Optional[bytes]:
        """Try to generate audio from a specific service."""
        
        for attempt in range(self.max_retries):
            try:
                print(f"  🔄 Attempt {attempt + 1}/{self.max_retries}...", end=" ")
                
                if "edge-tts" in url or "localhost:8880" in url:
                    # Edge TTS API format
                    payload = {
                        "text": text,
                        "lang": "en-US",
                        "emotion": emotion,
                        "rate": rate
                    }
                else:
                    # Orpheus TTS API format
                    payload = {
                        "input": text,
                        "model": "orpheus",
                        "voice": voice,
                        "response_format": "wav",
                        "speed": 1.0
                    }
                
                response = requests.post(
                    url,
                    json=payload,
                    timeout=self.timeout
                )
                
                if response.status_code == 200:
                    print("✅ Success")
                    return response.content
                else:
                    print(f"❌ Status {response.status_code}")
                    
            except requests.exceptions.Timeout:
                print("❌ Timeout")
            except requests.exceptions.ConnectionError:
                print("❌ Connection Error")
            except Exception as e:
                print(f"❌ Error: {str(e)}")
            
            if attempt < self.max_retries - 1:
                wait_time = 2 ** attempt  # Exponential backoff
                time.sleep(wait_time)
        
        return None


class AudioMerger:
    """Merge multiple audio files into a single output."""
    
    def __init__(self, output_format: str = "mp3",
                 bitrate: str = "192k",
                 sample_rate: int = 44100):
        self.output_format = output_format
        self.bitrate = bitrate
        self.sample_rate = sample_rate
    
    def merge_audio_files(self, audio_files: List[str],
                         output_path: str = "final_merged.mp3",
                         crossfade: float = 0.5) -> Optional[str]:
        """
        Merge multiple audio files into one.
        
        Args:
            audio_files: List of paths to audio files to merge
            output_path: Path for the output merged file
            crossfade: Crossfade duration in seconds (0 for no crossfade)
            
        Returns:
            Path to merged audio file or None if failed
        """
        
        print(f"\n📦 Merging {len(audio_files)} audio files...")
        
        # Verify all files exist
        missing_files = [f for f in audio_files if not os.path.exists(f)]
        if missing_files:
            print(f"❌ Missing files: {missing_files}")
            return None
        
        try:
            # Load the first audio file
            combined = AudioSegment.from_file(audio_files[0])
            print(f"  ✅ Loaded {audio_files[0]} ({len(combined)}ms)")
            
            # Append remaining files
            for audio_file in audio_files[1:]:
                segment = AudioSegment.from_file(audio_file)
                
                if crossfade > 0:
                    # Apply crossfade
                    crossfade_ms = int(crossfade * 1000)
                    combined = combined.append(
                        segment,
                        crossfade=crossfade_ms
                    )
                    print(f"  ✅ Added {audio_file} with {crossfade}s crossfade ({len(segment)}ms)")
                else:
                    # Simple concatenation
                    combined = combined + segment
                    print(f"  ✅ Added {audio_file} ({len(segment)}ms)")
            
            # Export the merged audio
            print(f"\n💾 Exporting to {output_path}...")
            combined.export(
                output_path,
                format=self.output_format,
                bitrate=self.bitrate,
                parameters=["-ar", str(self.sample_rate), "-ac", "2"]
            )
            
            total_duration = len(combined) / 1000
            print(f"  ✅ Merged audio saved ({total_duration:.1f}s total)")
            
            return output_path
            
        except Exception as e:
            print(f"  ❌ Merge failed: {e}")
            return None
    
    def normalize_audio(self, input_path: str,
                       output_path: str = None,
                       target_loudness: float = -20) -> Optional[str]:
        """
        Normalize audio levels using FFmpeg.
        
        Args:
            input_path: Path to input audio file
            output_path: Path for normalized output (auto-generated if None)
            target_loudness: Target loudness in LUFS
            
        Returns:
            Path to normalized audio file or None if failed
        """
        
        if output_path is None:
            base, ext = os.path.splitext(input_path)
            output_path = f"{base}_normalized{ext}"
        
        print(f"\n🔊 Normalizing audio to {target_loudness} LUFS...")
        
        try:
            # Use ffmpeg-normalize for proper loudness normalization
            cmd = [
                "ffmpeg",
                "-i", input_path,
                "-af", f"loudnorm=I=-20:TP=-1.5:LRA=11",
                "-y",  # Overwrite output file
                output_path
            ]
            
            result = subprocess.run(cmd, capture_output=True, text=True)
            
            if result.returncode == 0:
                print(f"  ✅ Audio normalized: {output_path}")
                return output_path
            else:
                print(f"  ❌ Normalization failed: {result.stderr}")
                return None
                
        except FileNotFoundError:
            print("  ❌ FFmpeg not found. Install it with: brew install ffmpeg")
            return None
        except Exception as e:
            print(f"  ❌ Error: {e}")
            return None


class SongProducer:
    """Complete song production pipeline."""
    
    def __init__(self, config_path: str):
        """
        Initialize producer with configuration.
        
        Args:
            config_path: Path to JSON configuration file
        """
        with open(config_path, 'r') as f:
            self.config = json.load(f)
        
        self.generator = AudioGenerator(
            primary_url=self.config['ttsApiConfiguration']['endpoint'],
            fallback_url=self.config['ttsApiConfiguration']['fallbackEndpoint'],
            timeout=self.config['ttsApiConfiguration']['timeout'],
            max_retries=self.config['ttsApiConfiguration']['maxRetries']
        )
        
        merge_config = self.config['mergeConfiguration']['qualitySettings']
        self.merger = AudioMerger(
            output_format=merge_config['format'],
            bitrate=merge_config['bitrate'],
            sample_rate=merge_config['sampleRate']
        )
        
        self.output_dir = "audio_output"
        os.makedirs(self.output_dir, exist_ok=True)
    
    def generate_part(self, part: Dict) -> Optional[str]:
        """Generate audio for a single part."""
        
        print(f"\n🎵 {part['name']}")
        print(f"   {part['description']}")
        print(f"   Target duration: {part['duration']}s")
        
        part_audio_files = []
        
        for segment in part['segments']:
            print(f"\n   📝 Generating: {segment['id']} ({segment['duration']}s)")
            
            output_path = os.path.join(
                self.output_dir,
                f"{part['id']}_{segment['id']}.mp3"
            )
            
            audio_file = self.generator.generate_audio(
                text=segment['text'],
                voice=segment.get('voice', 'en-US-AriaNeural'),
                emotion=segment.get('emotion', 'neutral'),
                rate=segment.get('rate', 'normal'),
                output_path=output_path
            )
            
            if audio_file:
                part_audio_files.append(audio_file)
            else:
                print(f"   ⚠️  Skipping {segment['id']} due to generation failure")
        
        if not part_audio_files:
            print(f"   ❌ Failed to generate {part['name']}")
            return None
        
        # Merge segments into part
        part_output = os.path.join(self.output_dir, part['outputFile'])
        return self.merger.merge_audio_files(
            part_audio_files,
            part_output,
            crossfade=0.5
        )
    
    def produce(self) -> Optional[str]:
        """Execute complete production pipeline."""
        
        print("=" * 60)
        print("🎬 SONG PRODUCTION PIPELINE")
        print("=" * 60)
        print(f"Project: {self.config['project']}")
        print(f"Total Duration: {self.config['metadata']['totalDuration']}")
        print(f"Output Format: {self.config['metadata']['outputFormat']}")
        print("=" * 60)
        
        # Generate all parts
        part_files = []
        
        for part in self.config['parts']:
            print(f"\n{'='*60}")
            part_file = self.generate_part(part)
            
            if part_file:
                part_files.append(part_file)
            else:
                print(f"\n⚠️  Skipping {part['name']} in final merge")
        
        if not part_files:
            print("\n❌ No parts generated successfully")
            return None
        
        # Merge all parts
        print(f"\n{'='*60}")
        merge_config = self.config['mergeConfiguration']
        final_output = os.path.join(self.output_dir, merge_config['outputFile'])
        
        merged_file = self.merger.merge_audio_files(
            part_files,
            final_output,
            crossfade=merge_config['transitions']['crossfadeDuration']
        )
        
        if not merged_file:
            print("\n❌ Merging failed")
            return None
        
        # Normalize audio if enabled
        if self.config['mergeConfiguration']['audioNormalization']['enabled']:
            normalized_file = self.merger.normalize_audio(merged_file)
            if normalized_file:
                final_output = normalized_file
        
        # Summary
        print(f"\n{'='*60}")
        print("✅ PRODUCTION COMPLETE!")
        print(f"{'='*60}")
        print(f"📁 Output Directory: {os.path.abspath(self.output_dir)}")
        print(f"🎵 Final File: {os.path.abspath(final_output)}")
        print(f"📊 Parts Generated: {len(part_files)}")
        print("=" * 60)
        
        return final_output


def main():
    """Main entry point."""
    
    config_path = "final.json"
    
    # Check if config exists
    if not os.path.exists(config_path):
        print(f"❌ Config file not found: {config_path}")
        sys.exit(1)
    
    # Check for FFmpeg
    try:
        subprocess.run(["ffmpeg", "-version"], capture_output=True, check=True)
    except (FileNotFoundError, subprocess.CalledProcessError):
        print("⚠️  WARNING: FFmpeg not found. Audio merging may fail.")
        print("   Install with: brew install ffmpeg (macOS) or apt-get install ffmpeg (Linux)")
    
    # Run production pipeline
    try:
        producer = SongProducer(config_path)
        result = producer.produce()
        
        if result:
            print(f"\n✅ Success! Final file: {result}")
            sys.exit(0)
        else:
            print("\n❌ Production failed")
            sys.exit(1)
            
    except Exception as e:
        print(f"\n❌ Fatal error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
