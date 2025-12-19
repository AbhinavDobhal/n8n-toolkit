from io import BytesIO
import asyncio
from enum import Enum

from fastapi import FastAPI, HTTPException
from fastapi.responses import Response
from pydantic import BaseModel, Field
import edge_tts

app = FastAPI(title="Advanced TTS Service", version="2.0.0")


class LanguageEnum(str, Enum):
    en_us = "en-US"
    en_gb = "en-GB"
    en_au = "en-AU"
    en_in = "en-IN"
    es_es = "es-ES"
    fr_fr = "fr-FR"
    de_de = "de-DE"
    it_it = "it-IT"
    ja_jp = "ja-JP"
    zh_cn = "zh-CN"
    hi_in = "hi-IN"


class EmotionEnum(str, Enum):
    neutral = "neutral"
    cheerful = "cheerful"
    sad = "sad"
    angry = "angry"
    excited = "excited"


class RateEnum(str, Enum):
    slow_50 = "-50%"
    slow_25 = "-25%"
    normal = "+0%"
    fast_25 = "+25%"
    fast_50 = "+50%"


class TTSRequest(BaseModel):
    text: str = Field(..., description="Text to convert to speech", min_length=1, max_length=1000)
    lang: LanguageEnum = Field(LanguageEnum.en_us, description="Language and region")
    emotion: EmotionEnum = Field(EmotionEnum.neutral, description="Emotional style")
    rate: RateEnum = Field(RateEnum.normal, description="Speech rate")


@app.get("/health")
def health() -> dict:
    return {"status": "ok"}


@app.get("/voices")
def get_voices() -> dict:
    """Get available voices and emotions"""
    return {
        "emotions": [e.value for e in EmotionEnum],
        "languages": [l.value for l in LanguageEnum],
        "rates": [r.value for r in RateEnum]
    }


@app.post("/tts")
async def synthesize(req: TTSRequest):
    if not req.text.strip():
        raise HTTPException(status_code=400, detail="text must not be empty")

    try:
        # Select voice based on language
        voice_map = {
            "en-US": "en-US-AriaNeural",
            "en-GB": "en-GB-SoniaNeural",
            "en-AU": "en-AU-NatashaNeural",
            "en-IN": "en-IN-NeerjaNeural",
            "es-ES": "es-ES-ElviraNeural",
            "fr-FR": "fr-FR-DeniseNeural",
            "de-DE": "de-DE-AmalaNeural",
            "it-IT": "it-IT-ElsaNeural",
            "ja-JP": "ja-JP-NanamiNeural",
            "zh-CN": "zh-CN-XiaoxuanNeural",
            "hi-IN": "hi-IN-SwaraNeural"
        }
        
        voice = voice_map.get(req.lang, "en-US-AriaNeural")
        
        # Build prosody with emotion and rate
        text_with_prosody = f'<prosody rate="{req.rate}" pitch="+0%">{req.text}</prosody>'
        ssml = f'''<speak version="1.0" xml:lang="{req.lang}">
            <voice name="{voice}">
                <mstts:express-as style="{req.emotion}" styledegree="2.0">
                    {text_with_prosody}
                </mstts:express-as>
            </voice>
        </speak>'''
        
        # Generate audio
        buffer = BytesIO()
        communicate = edge_tts.Communicate(ssml, voice)
        
        async for chunk in communicate.stream():
            if chunk["type"] == "audio":
                buffer.write(chunk["data"])
        
        audio_bytes = buffer.getvalue()
        
        if not audio_bytes:
            raise HTTPException(status_code=500, detail="Failed to generate audio")

        return Response(
            content=audio_bytes,
            media_type="audio/mpeg",
            status_code=200,
            headers={
                "Content-Length": str(len(audio_bytes)),
                "Content-Disposition": "inline; filename=tts.mp3",
                "Accept-Ranges": "bytes",
                "Cache-Control": "public, max-age=3600",
                "X-Content-Type-Options": "nosniff",
            }
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"TTS Error: {str(e)}")
