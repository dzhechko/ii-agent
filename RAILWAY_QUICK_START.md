# 🚂 Railway.app - Быстрый старт для II-Agent

## 🎯 5-минутный деплой

### 1. Подготовка (1 мин)
```bash
# Убедитесь что все файлы закоммичены
git add .
git commit -m "Add Railway configuration"
git push origin main
```

### 2. Создание проекта в Railway (2 мин)

1. **Перейдите на** [railway.app](https://railway.app)
2. **Нажмите** "Start a New Project"
3. **Выберите** "Deploy from GitHub repo"  
4. **Авторизуйтесь** через GitHub
5. **Выберите** репозиторий `ii-agent`
6. **Railway автоматически** начнет развертывание

### 3. Настройка переменных (2 мин)

В Railway Dashboard перейдите в **Variables** и добавьте **ОБЯЗАТЕЛЬНЫЕ**:

```env
ANTHROPIC_API_KEY=sk-ant-...
OPENAI_API_KEY=sk-...  
GOOGLE_API_KEY=AIza...
SECRET_KEY=your-32-char-secret-key
ALLOWED_ORIGINS=https://ii-agent-frontend.pages.dev,https://*.ii-agent-frontend.pages.dev
```

### 4. Проверка деплоя (30 сек)

1. **Дождитесь** зеленого статуса "Success"
2. **Нажмите** на URL развертывания (https://your-app.railway.app)  
3. **Проверьте** health endpoint: `https://your-app.railway.app/health`

## ✅ Результат

После выполнения у вас будет:
- 🌐 **Backend API**: `https://your-app.railway.app`
- 🔄 **Автодеплой**: При каждом push в main
- 📊 **Мониторинг**: Логи и метрики в Railway Dashboard
- 🔒 **HTTPS**: Автоматический SSL сертификат

## 🔧 Обновление Frontend

В Cloudflare Pages обновите переменные:

```env
# Settings → Environment variables → Production
NEXT_PUBLIC_API_URL=https://your-app.railway.app/api
NEXT_PUBLIC_WS_URL=wss://your-app.railway.app/ws
```

## 🎉 Готово!

Теперь у вас полностью рабочий II-Agent:
- **Frontend**: Cloudflare Pages  
- **Backend**: Railway.app
- **Автоматический деплой**: GitHub → Railway/Cloudflare

## 📚 Подробная инструкция

Полная документация: [RAILWAY_BACKEND_DEPLOY.md](RAILWAY_BACKEND_DEPLOY.md)