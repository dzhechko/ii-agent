# 🚀 Развертывание II-Agent на Cloudflare Pages

Этот документ содержит пошаговые инструкции по развертыванию II-Agent на Cloudflare Pages.

## 📋 Предварительные требования

1. **Cloudflare аккаунт** с активированным Cloudflare Pages
2. **GitHub репозиторий** с вашим проектом II-Agent
3. **Node.js 18+** для локальной разработки
4. **Бэкенд API** размещенный отдельно (рекомендуется Railway, Render или DigitalOcean)

## 🏗️ Архитектура развертывания

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Cloudflare    │    │   Backend       │
│   (Next.js)     │───▶│   Pages         │───▶│   (Python)      │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

- **Frontend**: Развернут на Cloudflare Pages
- **Backend**: Развернут на отдельном хостинге
- **Связь**: Через API и WebSocket соединения

## 🛠️ Настройка Cloudflare Pages

### 1. Создание проекта в Cloudflare

1. Зайдите в [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. Перейдите в раздел **Pages**
3. Нажмите **Create a project**
4. Выберите **Connect to Git** и подключите ваш GitHub репозиторий

### 2. Настройка сборки

В настройках проекта укажите:

```yaml
Build command: npm run build
Build output directory: .next
Root directory: frontend
Node.js version: 18
```

### 3. Переменные окружения

В разделе **Settings > Environment variables** добавьте:

#### Production Environment
```
NEXT_PUBLIC_API_URL=https://your-backend-url.com/api
NEXT_PUBLIC_WS_URL=wss://your-backend-url.com/ws
NODE_ENV=production
```

#### Preview Environment  
```
NEXT_PUBLIC_API_URL=https://your-staging-backend-url.com/api
NEXT_PUBLIC_WS_URL=wss://your-staging-backend-url.com/ws
NODE_ENV=development
```

## 🔧 Локальная настройка

### 1. Установка Wrangler CLI

```bash
cd frontend
npm install -D wrangler
```

### 2. Аутентификация Cloudflare

```bash
npx wrangler login
```

### 3. Настройка проекта

Создайте или обновите `wrangler.toml`:

```toml
name = "ii-agent-frontend"
compatibility_date = "2024-09-01"

[env.production]
name = "ii-agent-frontend"

[env.preview]  
name = "ii-agent-frontend-preview"

pages_build_output_dir = ".next"
```

## 🚀 Методы развертывания

### Метод 1: Автоматический (Рекомендуется)

Развертывание происходит автоматически через GitHub Actions:

- **Pull Request** → Preview deployment
- **Push to main/master** → Production deployment

### Метод 2: Ручной через скрипт

```bash
cd frontend

# Развертывание в preview
./deploy-cloudflare.sh preview

# Развертывание в production
./deploy-cloudflare.sh production
```

### Метод 3: Через npm скрипты

```bash
cd frontend

# Preview
npm run cf:preview

# Production
npm run cf:build
```

### Метод 4: Прямой Wrangler

```bash
cd frontend

# Сборка проекта
npm run build

# Развертывание preview
npx wrangler pages deploy .next --project-name ii-agent-frontend --env preview

# Развертывание production
npx wrangler pages deploy .next --project-name ii-agent-frontend --env production
```

## 🔒 Настройка секретов GitHub

Для автоматического развертывания добавьте секреты в GitHub:

1. Перейдите в **Settings > Secrets and variables > Actions**
2. Добавьте следующие секреты:

```
CLOUDFLARE_API_TOKEN=your_cloudflare_api_token
CLOUDFLARE_ACCOUNT_ID=your_account_id
NEXT_PUBLIC_API_URL=https://your-backend-url.com/api
NEXT_PUBLIC_WS_URL=wss://your-backend-url.com/ws
```

### Получение Cloudflare API Token

1. Зайдите на [Cloudflare API Tokens](https://dash.cloudflare.com/profile/api-tokens)
2. Нажмите **Create Token**
3. Используйте шаблон **Custom token** с правами:
   - **Zone:Zone Settings:Read**
   - **Zone:Zone:Read** 
   - **Account:Cloudflare Pages:Edit**

## 🌐 Настройка бэкенда

### Варианты хостинга бэкенда

1. **Railway** (Рекомендуется)
   - Простое развертывание Python приложений
   - Автоматическое HTTPS
   - Интеграция с PostgreSQL

2. **Render**
   - Бесплатный план доступен
   - Автоматическое развертывание из Git

3. **DigitalOcean App Platform**
   - Хороший баланс цены и производительности

4. **Heroku**
   - Простота использования
   - Много дополнений

### Настройка CORS на бэкенде

Убедитесь, что ваш бэкенд настроен для работы с Cloudflare Pages:

```python
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://ii-agent-frontend.pages.dev",
        "https://*.ii-agent-frontend.pages.dev",
        "http://localhost:3000"  # для разработки
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

## 📊 Мониторинг и логи

### Cloudflare Analytics

1. Перейдите в **Pages > ii-agent-frontend > Analytics**
2. Отслеживайте:
   - Количество запросов
   - Время загрузки
   - Географическое распределение пользователей

### Логи развертывания

```bash
# Просмотр логов последнего развертывания
npx wrangler pages deployment list --project-name ii-agent-frontend

# Детали конкретного развертывания
npx wrangler pages deployment tail
```

## 🔧 Устранение неполадок

### Частые проблемы

1. **Ошибки сборки Next.js**
   ```bash
   # Очистка кеша
   rm -rf .next node_modules package-lock.json
   npm install
   npm run build
   ```

2. **Проблемы с переменными окружения**
   - Проверьте правильность названий переменных
   - Убедитесь что переменные начинаются с `NEXT_PUBLIC_`

3. **CORS ошибки**
   - Проверьте настройки CORS на бэкенде
   - Убедитесь что домен Cloudflare добавлен в allow_origins

4. **Проблемы с WebSocket**
   - Убедитесь что бэкенд поддерживает WebSocket
   - Проверьте правильность WSS URL

### Полезные команды

```bash
# Проверка статуса проекта
npx wrangler pages project list

# Просмотр настроек проекта
npx wrangler pages project show ii-agent-frontend

# Локальная разработка с Pages Functions
npx wrangler pages dev .next --port 3000
```

## 📝 Дополнительные ресурсы

- [Cloudflare Pages Documentation](https://developers.cloudflare.com/pages/)
- [Next.js Deployment Guide](https://nextjs.org/docs/deployment)
- [Wrangler CLI Reference](https://developers.cloudflare.com/workers/wrangler/)

## 🎯 Следующие шаги

1. ✅ Развертывание фронтенда на Cloudflare Pages
2. ⏳ Настройка бэкенда на выбранной платформе
3. ⏳ Настройка пользовательского домена
4. ⏳ Настройка мониторинга и алертов
5. ⏳ Оптимизация производительности

---

**🔗 Полезные ссылки:**
- Production URL: `https://ii-agent-frontend.pages.dev`
- Cloudflare Dashboard: `https://dash.cloudflare.com/pages`
- GitHub Actions: `https://github.com/your-username/ii-agent/actions`