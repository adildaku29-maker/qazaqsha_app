# Qazaqsha Content Server

Отдельный сервер контента для Qazaqsha.

## Архитектура
- Flutter: UI, карта и локальная пользовательская сессия.
- Content Server: FastAPI API + админ-панель.
- Database: SQLite для разработки, PostgreSQL для production.
- Whisper Server: отдельный независимый ASR-сервис.

## Public API
- GET /health
- GET /api/topics
- GET /api/topics/{slug}/lessons/{number}
- POST /api/users/sync
- POST /api/progress

## Admin API
- POST /api/auth/login
- GET /api/admin/stats
- GET /api/admin/topics
- GET /api/admin/lessons?topic_id=...
- GET/POST/PUT/DELETE /api/admin/questions
- GET /api/admin/users
- GET /admin

## Запуск
```powershell
cd backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
$env:ADMIN_USERNAME="admin"
$env:ADMIN_PASSWORD="change-me-now"
$env:JWT_SECRET="long-random-secret"
python seed.py
uvicorn app.main:app --host 0.0.0.0 --port 8001
```

Админка: http://127.0.0.1:8001/admin

Для постоянного сервера используем Docker Compose. В production заменить SQLite на PostgreSQL и поставить HTTPS/reverse proxy. Секреты не коммитить.
