# Qazaqsha Kazakh Whisper ASR

Qazaqsha uses shyngys879/kazakh-whisper-large-v3-turbo on the backend instead of Android's generic speech recognition.

Windows PowerShell:

    cd backend
    py -3.11 -m venv .venv
    .\.venv\Scripts\Activate.ps1
    python -m pip install --upgrade pip
    pip install -r requirements.txt

Start:

    uvicorn asr_server:app --host 0.0.0.0 --port 8000

The first start downloads the model (about 1.62 GB) from Hugging Face. The model card recommends 16 kHz audio and language kk / task transcribe. CUDA is used automatically when available.

Health check:

    http://127.0.0.1:8000/health

Android emulator uses http://10.0.2.2:8000 by default.

For a physical Android phone, use:

    flutter run --dart-define=ASR_URL=http://YOUR_PC_IP:8000
