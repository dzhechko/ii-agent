# 🚂 Развертывание II-Agent Backend на Railway.app

Railway.app - это современная платформа для развертывания приложений, которая идеально подходит для Python-приложений с автоматическим HTTPS и простым управлением базами данных.

## 📋 Предварительные требования

- 🔗 Аккаунт Railway.app (можно зарегистрироваться через GitHub)
- 🐍 Python 3.10+ совместимый код
- 📁 GitHub репозиторий с вашим II-Agent проектом
- 🔑 API ключи для LLM провайдеров (Anthropic, OpenAI, Google)

## 🏗️ Архитектура

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Railway       │    │   Database      │
│ (Cloudflare     │───▶│   Backend       │───▶│   PostgreSQL    │
│  Pages)         │    │   (Python)      │    │   (Railway)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🚀 Пошаговое развертывание

### Шаг 1: Подготовка проекта

#### 1.1 Создайте файлы конфигурации Railway

Создайте файл `railway.json` в корне проекта:

```json
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "NIXPACKS",
    "buildCommand": "pip install -r requirements.txt"
  },
  "deploy": {
    "startCommand": "python run_gaia.py --server",
    "healthcheckPath": "/health",
    "healthcheckTimeout": 300,
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 10
  }
}
```

#### 1.2 Создайте или обновите requirements.txt

Убедитесь, что файл содержит все необходимые зависимости:

```txt
fastapi>=0.100.0
uvicorn[standard]>=0.20.0
websockets>=11.0
python-multipart>=0.0.6
pydantic>=2.0.0
anthropic>=0.25.0
openai>=1.0.0
google-generativeai>=0.3.0
google-cloud-aiplatform>=1.38.0
requests>=2.31.0
aiohttp>=3.8.0
python-dotenv>=1.0.0
psycopg2-binary>=2.9.0
sqlalchemy>=2.0.0
alembic>=1.12.0
redis>=4.5.0
celery>=5.3.0
```

#### 1.3 Создайте Procfile (опционально)

```
web: python run_gaia.py --server --host 0.0.0.0 --port $PORT
```

#### 1.4 Создайте runtime.txt

```
python-3.11
```

### Шаг 2: Настройка Railway проекта

#### 2.1 Регистрация и создание проекта

1. Перейдите на [railway.app](https://railway.app)
2. Нажмите **"Start a New Project"**
3. Выберите **"Deploy from GitHub repo"**
4. Авторизуйтесь через GitHub и выберите репозиторий `ii-agent`

#### 2.2 Настройка автодеплоя

1. Railway автоматически обнаружит Python проект
2. Настройте автодеплой из ветки `main`
3. Выберите корневую директорию проекта

### Шаг 3: Настройка переменных окружения

В Railway Dashboard перейдите в **Variables** и добавьте:

#### 3.1 LLM API Keys
```env
# Anthropic Claude
ANTHROPIC_API_KEY=your_anthropic_api_key

# OpenAI GPT
OPENAI_API_KEY=your_openai_api_key

# Google Gemini
GOOGLE_API_KEY=your_google_api_key

# Google Cloud (если используете)
GOOGLE_APPLICATION_CREDENTIALS=/app/gcp-credentials.json
```

#### 3.2 Application Settings
```env
# Environment
ENVIRONMENT=production
DEBUG=false
LOG_LEVEL=INFO

# Server Configuration
HOST=0.0.0.0
PORT=8000

# CORS Settings
ALLOWED_ORIGINS=https://ii-agent-frontend.pages.dev,https://*.pages.dev
ALLOWED_METHODS=GET,POST,PUT,DELETE,OPTIONS
ALLOWED_HEADERS=*

# Session Management
SECRET_KEY=your_very_long_random_secret_key_here
SESSION_TIMEOUT=3600

# WebSocket Settings
WS_MAX_CONNECTIONS=100
WS_HEARTBEAT_INTERVAL=30
```

#### 3.3 Database Configuration (если нужна БД)
```env
# PostgreSQL (Railway предоставляет автоматически)
DATABASE_URL=${{Postgres.DATABASE_URL}}
DB_POOL_SIZE=20
DB_MAX_OVERFLOW=30
```

#### 3.4 External Services
```env
# Redis (для кэширования и очередей)
REDIS_URL=${{Redis.REDIS_URL}}

# File Storage
STORAGE_TYPE=local
# Или для S3:
# STORAGE_TYPE=s3
# AWS_ACCESS_KEY_ID=your_key
# AWS_SECRET_ACCESS_KEY=your_secret
# AWS_S3_BUCKET=your_bucket
```

### Шаг 4: Добавление базы данных (опционально)

#### 4.1 Добавление PostgreSQL

1. В Railway Dashboard нажмите **"New"**
2. Выберите **"Database"** → **"Add PostgreSQL"**
3. Railway автоматически создаст переменную `DATABASE_URL`

#### 4.2 Добавление Redis

1. Нажмите **"New"** → **"Database"** → **"Add Redis"**
2. Railway создаст переменную `REDIS_URL`

### Шаг 5: Настройка кастомного домена (опционально)

#### 5.1 В Railway Dashboard

1. Перейдите в **Settings** → **Domains**
2. Нажмите **"Custom Domain"**
3. Введите ваш домен (например, `api.yourdomain.com`)
4. Настройте DNS записи в вашем регистраторе доменов

#### 5.2 DNS записи

Добавьте CNAME запись:
```
api.yourdomain.com → your-app.railway.app
```

### Шаг 6: Настройка мониторинга

#### 6.1 Health Check

Убедитесь что ваше приложение имеет health check endpoint:

```python
from fastapi import FastAPI

app = FastAPI()

@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat(),
        "version": "1.0.0"
    }
```

#### 6.2 Логирование

Railway автоматически собирает логи. Настройте структурированное логирование:

```python
import logging
import sys

# Настройка логгера для Railway
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    stream=sys.stdout
)

logger = logging.getLogger(__name__)
```

## 🔧 Обновление кода приложения для Railway

### Обновите run_gaia.py

```python
import os
import uvicorn
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# CORS настройки для Cloudflare Pages
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://ii-agent-frontend.pages.dev",
        "https://*.ii-agent-frontend.pages.dev",
        "http://localhost:3000"  # для локальной разработки
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "ii-agent-backend"}

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8000))
    host = os.environ.get("HOST", "0.0.0.0")
    
    uvicorn.run(
        "run_gaia:app",
        host=host,
        port=port,
        reload=False,
        log_level="info"
    )
```

### Создайте .env.example для разработки

```env
# LLM API Keys
ANTHROPIC_API_KEY=your_anthropic_api_key
OPENAI_API_KEY=your_openai_api_key
GOOGLE_API_KEY=your_google_api_key

# Application
ENVIRONMENT=development
DEBUG=true
LOG_LEVEL=DEBUG
HOST=127.0.0.1
PORT=8000

# Database (для локальной разработки)
DATABASE_URL=postgresql://user:password@localhost:5432/iiagent
REDIS_URL=redis://localhost:6379

# CORS
ALLOWED_ORIGINS=http://localhost:3000,https://ii-agent-frontend.pages.dev
```

## 🚀 Развертывание

### Автоматическое развертывание

1. **Commit & Push** ваши изменения в `main` ветку
2. Railway автоматически обнаружит изменения
3. Проект будет пересобран и развернут
4. Проверьте логи развертывания в Railway Dashboard

### Ручное развертывание

```bash
# Установка Railway CLI
npm install -g @railway/cli

# Логин в Railway
railway login

# Связь с проектом
railway link

# Развертывание
railway up
```

## 🔗 Обновление Frontend для работы с Railway

После развертывания обновите переменные окружения в Cloudflare Pages:

```env
# В Cloudflare Pages Dashboard → Settings → Environment variables
NEXT_PUBLIC_API_URL=https://your-app.railway.app/api
NEXT_PUBLIC_WS_URL=wss://your-app.railway.app/ws

# Или если используете кастомный домен:
NEXT_PUBLIC_API_URL=https://api.yourdomain.com/api
NEXT_PUBLIC_WS_URL=wss://api.yourdomain.com/ws
```

## 📊 Мониторинг и обслуживание

### Просмотр логов

```bash
# Railway CLI
railway logs

# Или в веб-интерфейсе
# Dashboard → Project → Deployments → View Logs
```

### Метрики и мониторинг

Railway предоставляет встроенные метрики:
- CPU и Memory usage
- Network traffic
- Request count и latency
- Error rates

### Масштабирование

1. **Vertical Scaling**: Railway автоматически масштабирует ресурсы
2. **Horizontal Scaling**: Доступно в Pro планах
3. **Auto-scaling**: Настраивается в Dependencies

## 💰 Цены и лимиты

### Hobby Plan (Бесплатный)
- $5 кредитов в месяц
- 500 часов выполнения
- 1GB RAM
- 1GB хранилища

### Pro Plan ($20/месяц)
- Неограниченные проекты
- Приоритетная поддержка
- Кастомные домены
- Расширенные метрики

## 🛠️ Устранение неполадок

### Распространенные проблемы

1. **Build Failures**
   ```bash
   # Проверьте requirements.txt
   # Убедитесь в правильности Python версии
   # Проверьте логи сборки в Railway Dashboard
   ```

2. **Environment Variables**
   ```bash
   # Убедитесь что все переменные установлены
   # Проверьте синтаксис (нет пробелов вокруг =)
   # Перезапустите сервис после изменения переменных
   ```

3. **CORS Errors**
   ```python
   # Убедитесь что Cloudflare домен добавлен в allow_origins
   # Проверьте что middleware настроен правильно
   ```

4. **Database Connection**
   ```bash
   # Проверьте DATABASE_URL
   # Убедитесь что PostgreSQL сервис запущен
   # Проверьте firewall и security group настройки
   ```

### Полезные команды

```bash
# Railway CLI команды
railway status          # Статус проекта
railway logs --tail     # Просмотр логов в реальном времени
railway shell           # SSH в контейнер
railway restart         # Перезапуск сервиса

# Локальная отладка
railway run python run_gaia.py  # Запуск с Railway переменными
railway connect                 # Подключение к Railway БД локально
```

## 🎯 Следующие шаги

После успешного развертывания:

1. ✅ **Тестирование**: Проверьте все endpoints API
2. ✅ **Мониторинг**: Настройте алерты и метрики
3. ✅ **Backup**: Настройте резервное копирование БД
4. ✅ **Security**: Реализуйте rate limiting и authentication
5. ✅ **Performance**: Оптимизируйте запросы и добавьте кэширование

## 📚 Полезные ссылки

- [Railway Documentation](https://docs.railway.app/)
- [Railway Templates](https://railway.app/templates)
- [Railway CLI Guide](https://docs.railway.app/develop/cli)
- [FastAPI Deployment Guide](https://fastapi.tiangolo.com/deployment/)
- [Python Railway Template](https://github.com/railwayapp/examples/tree/main/examples/fastapi)

---

**🎉 Поздравляем!** После выполнения всех шагов у вас будет полностью рабочий II-Agent с фронтендом на Cloudflare Pages и бэкендом на Railway.app!

**🔗 Итоговая архитектура:**
- Frontend: `https://ii-agent-frontend.pages.dev`
- Backend: `https://your-app.railway.app`
- Database: PostgreSQL на Railway
- Кэш: Redis на Railway (опционально)