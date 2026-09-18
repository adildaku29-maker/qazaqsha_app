import io

import numpy as np
import soundfile as sf
import torch
from fastapi import FastAPI, File, UploadFile, HTTPException
from transformers import pipeline

MODEL_ID = "shyngys879/kazakh-whisper-large-v3-turbo"
DEVICE = 0 if torch.cuda.is_available() else -1
DTYPE = torch.float16 if torch.cuda.is_available() else torch.float32

app = FastAPI(title="Qazaqsha Kazakh ASR")

asr = pipeline(
    "automatic-speech-recognition",
    model=MODEL_ID,
    device=DEVICE,
    torch_dtype=DTYPE,
    chunk_length_s=30,
)

@app.get("/health")
def health():
    return {
        "ok": True,
        "model": MODEL_ID,
        "device": "cuda" if torch.cuda.is_available() else "cpu",
    }

@app.post("/transcribe")
async def transcribe(file: UploadFile = File(...)):
    if not file.content_type or not file.content_type.startswith("audio/"):
        raise HTTPException(status_code=400, detail="Audio file required")

    data = await file.read()
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
