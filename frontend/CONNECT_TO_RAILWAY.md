# 🔗 Подключение Frontend к Railway Backend

После развертывания бэкенда на Railway необходимо обновить конфигурацию фронтенда.

## 📋 Шаги подключения

### 1. Получите URL Railway бэкенда

После успешного деплоя на Railway:

1. **Перейдите** в Railway Dashboard
2. **Выберите** ваш проект II-Agent
3. **Скопируйте** URL развертывания (например: `https://ii-agent-backend-production-abc123.up.railway.app`)

### 2. Обновите переменные Cloudflare Pages

#### В Cloudflare Dashboard:

1. **Перейдите** в Pages → ii-agent-frontend → Settings → Environment variables

2. **Обновите Production переменные:**
```env
NEXT_PUBLIC_API_URL=https://your-app.railway.app/api
NEXT_PUBLIC_WS_URL=wss://your-app.railway.app/ws
NODE_ENV=production
```

3. **Обновите Preview переменные:**
```env  
NEXT_PUBLIC_API_URL=https://your-app.railway.app/api
NEXT_PUBLIC_WS_URL=wss://your-app.railway.app/ws
NODE_ENV=development
```

### 3. Обновите локальные файлы

#### Обновите frontend/.env.production:
```env
NEXT_PUBLIC_API_URL=https://your-app.railway.app/api
NEXT_PUBLIC_WS_URL=wss://your-app.railway.app/ws
NEXT_PUBLIC_APP_NAME=II-Agent
NEXT_PUBLIC_APP_VERSION=1.0.0
NODE_ENV=production
```

#### Обновите frontend/pages.toml:
```toml
[build]
command = "npm run build"
destination = ".next"

[build.environment]
NODE_VERSION = "18"

[[redirects]]
from = "/api/*"
to = "https://your-app.railway.app/api/*"
status = 200

[[redirects]]  
from = "/ws/*"
to = "wss://your-app.railway.app/ws/*"
status = 200

[[headers]]
for = "/*"
[headers.values]
X-Frame-Options = "DENY"
X-Content-Type-Options = "nosniff"
```

### 4. Пересоберите и разверните

#### Автоматически (рекомендуется):
```bash
# Закоммитьте изменения
git add .
git commit -m "Connect frontend to Railway backend"
git push origin main

# Cloudflare автоматически пересоберет приложение
```

#### Вручную:
```bash
cd frontend

# Пересборка с новыми переменными
npm run build

# Деплой на Cloudflare Pages  
npx wrangler pages deploy .next --project-name ii-agent-frontend --env production
```

## 🔍 Проверка подключения

### 1. Проверьте бэкенд

Убедитесь что бэкенд работает:
```bash
curl https://your-app.railway.app/health
# Должен вернуть: {"status": "healthy", ...}
```

### 2. Проверьте фронтенд

1. **Откройте** https://ii-agent-frontend.pages.dev
2. **Проверьте** Developer Tools → Network
3. **Убедитесь** что запросы идут на Railway URL
4. **Проверьте** WebSocket соединение

### 3. Тест интеграции

1. **Откройте** приложение в браузере
2. **Попробуйте** создать новую сессию
3. **Отправьте** тестовое сообщение
4. **Убедитесь** что ответ приходит от бэкенда

## 🛠️ Устранение неполадок

### CORS ошибки
Если видите CORS ошибки, проверьте что в Railway добавлена переменная:
```env
ALLOWED_ORIGINS=https://ii-agent-frontend.pages.dev,https://*.ii-agent-frontend.pages.dev
```

### WebSocket ошибки  
1. Убедитесь что Railway поддерживает WebSocket (поддерживает)
2. Проверьте что URL начинается с `wss://` а не `ws://`
3. Проверьте firewall и proxy настройки

### Медленная загрузка
Railway может "засыпать" при отсутствии трафика:
1. Настройте health check пинги
2. Рассмотрите Hobby+ план для избежания "засыпания"

## 📊 Мониторинг

### Railway Dashboard
- **Deployment Logs**: Логи развертывания
- **Application Logs**: Логи приложения  
- **Metrics**: CPU, Memory, Network usage

### Cloudflare Analytics
- **Page Views**: Статистика просмотров
- **Performance**: Скорость загрузки
- **Errors**: 4xx/5xx ошибки

## 🔄 Обновления

При обновлении бэкенда:
1. **Railway** автоматически пересобирает при push
2. **URL остается** тем же (не нужно обновлять фронтенд)
3. **Zero-downtime** деплой

При обновлении фронтенда:
1. **Cloudflare** автоматически пересобирает при push  
2. **Переменные** сохраняются
3. **CDN кэш** автоматически инвалидируется

## 🎯 Готово!

После выполнения всех шагов у вас будет полностью интегрированное приложение:

**🌐 Frontend**: https://ii-agent-frontend.pages.dev
**⚡ Backend**: https://your-app.railway.app  
**📡 Автосинхронизация**: GitHub → Railway/Cloudflare

**🔗 Полезные ссылки:**
- Railway Dashboard: https://railway.app/dashboard
- Cloudflare Pages: https://dash.cloudflare.com/pages
- Документация API: https://your-app.railway.app/docs