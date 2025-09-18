# 🚀 Быстрая настройка деплоя на Cloudflare Pages

## 📋 Чек-лист перед деплоем

- [ ] Cloudflare аккаунт создан
- [ ] GitHub репозиторий настроен  
- [ ] Бэкенд API размещен и доступен
- [ ] Node.js 18+ установлен локально

## ⚡ Быстрый старт

### 1. Настройка Cloudflare Pages

```bash
# 1. Подключите репозиторий в Cloudflare Dashboard
# 2. Настройки сборки:
Build command: npm run build
Build output directory: .next
Root directory: frontend
Node.js version: 18
```

### 2. Переменные окружения

В Cloudflare Dashboard добавьте:

```env
# Production
NEXT_PUBLIC_API_URL=https://your-backend-url.com/api
NEXT_PUBLIC_WS_URL=wss://your-backend-url.com/ws
NODE_ENV=production

# Preview  
NEXT_PUBLIC_API_URL=https://your-staging-backend-url.com/api
NEXT_PUBLIC_WS_URL=wss://your-staging-backend-url.com/ws
NODE_ENV=development
```

### 3. GitHub Secrets

В GitHub Settings > Secrets and variables > Actions:

```env
CLOUDFLARE_API_TOKEN=your_token
CLOUDFLARE_ACCOUNT_ID=your_account_id
NEXT_PUBLIC_API_URL=https://your-backend-url.com/api
NEXT_PUBLIC_WS_URL=wss://your-backend-url.com/ws
```

### 4. Локальный деплой

```bash
cd frontend

# Установка зависимостей
npm install

# Сборка и деплой preview
./deploy-cloudflare.sh preview

# Сборка и деплой production
./deploy-cloudflare.sh production
```

## 🎯 URL после деплоя

- **Production**: `https://ii-agent-frontend.pages.dev`
- **Preview**: `https://[commit-hash].ii-agent-frontend.pages.dev`

## 🔧 Полезные команды

```bash
# Локальная разработка
npm run dev

# Локальная разработка с Pages
npm run pages:dev

# Быстрый деплой
npm run cf:build        # production
npm run cf:preview      # preview

# Проверка статуса
npx wrangler pages project list
```

## 📚 Дополнительная информация

Подробная документация: [CLOUDFLARE_DEPLOY.md](../CLOUDFLARE_DEPLOY.md)