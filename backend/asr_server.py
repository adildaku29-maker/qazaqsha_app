import hashlib
import html
import io
import os

import numpy as np
import soundfile as sf
import torch
from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.responses import Response
from pydantic import BaseModel
from transformers import pipeline

MODEL_ID = "shyngys879/kazakh-whisper-large-v3-turbo"
DEVICE = 0 if torch.cuda.is_available() else -1
DTYPE = torch.float16 if torch.cuda.is_available() else torch.float32

AZURE_SPEECH_KEY = os.getenv("AZURE_SPEECH_KEY", "").strip()
AZURE_SPEECH_REGION = os.getenv("AZURE_SPEECH_REGION", "").strip()
AZURE_SPEECH_VOICE = os.getenv("AZURE_SPEECH_VOICE", "kk-KZ-AigulNeural").strip()
AZURE_TTS_URL = (
    f"https://{AZURE_SPEECH_REGION}.tts.speech.microsoft.com"
    "/cognitiveservices/v1"
    if AZURE_SPEECH_REGION
    else ""
 )

TTS_CACHE: dict[str, bytes] = {}

app = FastAPI(title="Qazaqsha Kazakh ASR + TTS")

asr = pipeline(
    "automatic-speech-recognition",
    model=MODEL_ID,
    device=DEVICE,
    torch_dtype=DTYPE,
    chunk_length_s=30,
 )

class SynthesizeRequest(BaseModel):
    text: str

@app.get("/health")
def health():
    return {
        "ok": True,
        "model": MODEL_ID,
        "device": "cuda" if torch.cuda.is_available() else "cpu",
        "tts": {
            "provider": "Microsoft Azure Speech",
            "voice": AZURE_SPEECH_VOICE,
            "configured": bool(AZURE_SPEECH_KEY and AZURE_SPEECH_REGION),
        },
    }

@app.post("/transcribe")
async def transcribe(file: UploadFile = File(...)):
    data = await file.read()
    if not data:
        raise HTTPException(status_code=400, detail="Empty audio file")

    try:
        audio, sample_rate = sf.read(io.BytesIO(data), dtype="float32")
    except Exception as exc:
        raise HTTPException(status_code=400, detail=f"Invalid audio: {exc}") from exc

    if audio.ndim > 1:
        audio = np.mean(audio, axis=1)

    result = asr(
        {"raw": audio, "sampling_rate": sample_rate},
        generate_kwargs={"language": "kk", "task": "transcribe"},
    )

    return {"text": result["text"].strip()}

@app.post("/synthesize")
async def synthesize(request: SynthesizeRequest):
    text = request.text.strip()
    if not text:
        raise HTTPException(status_code=400, detail="Text is required")

    if not AZURE_SPEECH_KEY or not AZURE_SPEECH_REGION:
        raise HTTPException(status_code=503, detail="Azure Speech is not configured. Set AZURE_SPEECH_KEY and AZURE_SPEECH_REGION.")

    cache_key = hashlib.sha256(f"{AZURE_SPEECH_VOICE}\0{text}".encode("utf-8")).hexdigest()
    cached = TTS_CACHE.get(cache_key)
    if cached is not None:
        return Response(content=cached, media_type="audio/mpeg")

    ssml = f'''<?xml version="1.0" encoding="UTF-8"?>
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xml:lang="kk-KZ">
  <voice name="{html.escape(AZURE_SPEECH_VOICE)}">
    {html.escape(text)}
  </voice>
</speak>'''

    import httpx

    try:
        async with httpx.AsyncClient(timeout=30) as client:
            azure_response = await client.post(
                AZURE_TTS_URL,
                content=ssml.encode("utf-8"),
                headers={
                    "Ocp-Apim-Subscription-Key": AZURE_SPEECH_KEY,
                    "Content-Type": "application/ssml+xml",
                    "X-Microsoft-OutputFormat": "audio-24khz-96kbitrate-mono-mp3",
                    "User-Agent": "Qazaqsha/2.0",
                },
            )
    except Exception as exc:
        raise HTTPException(status_code=502, detail=f"Azure TTS request failed: {exc}") from exc

    if azure_response.status_code != 200:
        raise HTTPException(status_code=502, detail=f"Azure TTS {azure_response.status_code}: {azure_response.text[:500]}")

    audio = azure_response.content
    TTS_CACHE[cache_key] = audio
    return Response(content=audio, media_type="audio/mpeg"),