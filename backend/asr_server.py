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

YANDEX_API_KEY = os.getenv("YANDEX_API_KEY", "").strip()
YANDEX_TTS_VOICE = os.getenv("YANDEX_TTS_VOICE", "saule").strip()
YANDEX_TTS_URL = "https://tts.api.ml.yandexcloud.kz:443/tts/v3/utteranceSynthesis"

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
            "provider": "Yandex SpeechKit",
            "voice": YANDEX_TTS_VOICE,
            "configured": bool(YANDEX_API_KEY),
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

    if not YANDEX_API_KEY:
        raise HTTPException(status_code=503, detail="Yandex SpeechKit is not configured. Set YANDEX_API_KEY.")

    cache_key = hashlib.sha256(f"{YANDEX_TTS_VOICE}\0{text}".encode("utf-8")).hexdigest()
    cached = TTS_CACHE.get(cache_key)
    if cached is not None:
        return Response(content=cached, media_type="audio/wav")

    payload = {
        "text": text,
        "hints": [{"voice": YANDEX_TTS_VOICE}],
        "outputAudioSpec": {
            "containerAudio": {
                "containerAudioType": "WAV"
            }
        },
        "loudnessNormalizationType": "LUFS",
    }

    import httpx

    try:
        async with httpx.AsyncClient(timeout=30) as client:
            yandex_response = await client.post(
                YANDEX_TTS_URL,
                json=payload,
                headers={
                    "Authorization": f"Api-Key {YANDEX_API_KEY}",
                    "Content-Type": "application/json",
                },
            )
    except Exception as exc:
        raise HTTPException(status_code=502, detail=f"Yandex TTS request failed: {exc}") from exc

    if yandex_response.status_code != 200:
        raise HTTPException(
            status_code=502,
            detail=f"Yandex TTS {yandex_response.status_code}: {yandex_response.text[:500]}",
        )

    try:
        response_json = yandex_response.json()
        audio_b64 = response_json["result"]["audioChunk"]["data"]
        import base64
        audio = base64.b64decode(audio_b64)
    except Exception as exc:
        raise HTTPException(status_code=502, detail=f"Invalid Yandex TTS response: {exc}") from exc

    TTS_CACHE[cache_key] = audio
    return Response(content=audio, media_type="audio/wav")