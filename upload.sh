#!/bin/bash

# ════════════════════════════════════════════════════════════════
# 🚀 Универсальный скрипт загрузки проекта на GitHub
# ════════════════════════════════════════════════════════════════
# 
# Использование:
# 1. Скопируйте этот файл в папку проекта
# 2. Запустите: ./upload.sh
# 3. Следуйте инструкциям
#
# Первый запуск:
# - Получите токен: https://github.com/settings/tokens
# - Выполните: export GITHUB_TOKEN='ваш_токен'
# ════════════════════════════════════════════════════════════════

set -e

# Цвета
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear

echo -e "${CYAN}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║           🚀 GitHub Project Upload Tool 🚀                ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# ════════════════════════════════════════════════════════════════
# ПРОВЕРКА GITHUB ТОКЕНА
# ════════════════════════════════════════════════════════════════

if [ -z "$GITHUB_TOKEN" ]; then
    echo -e "${RED}❌ GitHub токен не найден!${NC}"
    echo ""
    echo -e "${YELLOW}📝 Как получить токен:${NC}"
    echo "   1. Откройте: ${CYAN}https://github.com/settings/tokens${NC}"
    echo "   2. Нажмите ${GREEN}\"Generate new token (classic)\"${NC}"
    echo "   3. Выберите права: ${GREEN}✓ repo${NC}"
    echo "   4. Скопируйте токен"
    echo ""
    echo -e "${YELLOW}💾 Сохраните токен:${NC}"
    echo "   ${CYAN}export GITHUB_TOKEN='ваш_токен_здесь'${NC}"
    echo ""
    echo -e "${YELLOW}🔒 Чтобы сохранить навсегда:${NC}"
    echo "   ${CYAN}echo 'export GITHUB_TOKEN=\"ваш_токен\"' >> ~/.bashrc${NC}"
    echo "   ${CYAN}source ~/.bashrc${NC}"
    echo ""
    exit 1
fi

# Проверка валидности токена
echo -e "${BLUE}🔍 Проверка GitHub токена...${NC}"
GITHUB_USER=$(curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user | grep -o '"login": "[^"]*' | cut -d'"' -f4)

if [ -z "$GITHUB_USER" ]; then
    echo -e "${RED}❌ Токен невалидный или истек!${NC}"
    echo -e "${YELLOW}Создайте новый токен: https://github.com/settings/tokens${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Токен валидный. GitHub пользователь: ${GITHUB_USER}${NC}"
echo ""

# ════════════════════════════════════════════════════════════════
# ПОЛУЧЕНИЕ ИНФОРМАЦИИ О ПРОЕКТЕ
# ════════════════════════════════════════════════════════════════

CURRENT_DIR=$(pwd)
PROJECT_NAME=$(basename "$CURRENT_DIR")

echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}📂 Текущая папка: ${NC}$CURRENT_DIR"
echo -e "${CYAN}📦 Название папки: ${NC}$PROJECT_NAME"
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo ""

# Название репозитория
echo -e "${YELLOW}📝 Введите название репозитория на GitHub${NC}"
echo -e "${YELLOW}   (нажмите Enter для использования: ${GREEN}$PROJECT_NAME${YELLOW})${NC}"
read -r REPO_NAME

if [ -z "$REPO_NAME" ]; then
    REPO_NAME="$PROJECT_NAME"
fi

# Описание репозитория
echo ""
echo -e "${YELLOW}📝 Введите описание проекта (необязательно):${NC}"
read -r REPO_DESCRIPTION

# Видимость репозитория
echo ""
echo -e "${YELLOW}🔒 Выберите тип репозитория:${NC}"
echo "   ${GREEN}1)${NC} Private (приватный) - ${CYAN}рекомендуется${NC}"
echo "   ${GREEN}2)${NC} Public (публичный)"
echo ""
read -p "Ваш выбор (1 или 2): " VISIBILITY_CHOICE

if [ "$VISIBILITY_CHOICE" = "2" ]; then
    VISIBILITY="public"
    PRIVATE_FLAG="false"
else
    VISIBILITY="private"
    PRIVATE_FLAG="true"
fi

# ════════════════════════════════════════════════════════════════
# ПОДТВЕРЖДЕНИЕ
# ════════════════════════════════════════════════════════════════

echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}📋 Параметры загрузки:${NC}"
echo -e "${BLUE}────────────────────────────────────────────────────────────${NC}"
echo -e "${CYAN}📂 Папка:${NC} $CURRENT_DIR"
echo -e "${CYAN}📦 Репозиторий:${NC} $REPO_NAME"
if [ -n "$REPO_DESCRIPTION" ]; then
    echo -e "${CYAN}📝 Описание:${NC} $REPO_DESCRIPTION"
fi
echo -e "${CYAN}🔒 Видимость:${NC} $VISIBILITY"
echo -e "${CYAN}👤 GitHub:${NC} https://github.com/$GITHUB_USER/$REPO_NAME"
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo ""

read -p "$(echo -e ${YELLOW}Начать загрузку? ${GREEN}\(y/n\)${NC}: )" CONFIRM

if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo -e "${RED}❌ Отменено${NC}"
    exit 0
fi

echo ""
echo -e "${GREEN}🚀 Начинаем загрузку...${NC}"
echo ""

# ════════════════════════════════════════════════════════════════
# СОЗДАНИЕ .gitignore
# ════════════════════════════════════════════════════════════════

if [ ! -f ".gitignore" ]; then
    echo -e "${BLUE}📝 Создание .gitignore...${NC}"
    cat > .gitignore << 'EOF'
# Dependencies
node_modules/
vendor/
.pnp
.pnp.js
bower_components/
jspm_packages/

# Production
build/
dist/
*.log
out/

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local
.env.*
config.local.php
secrets.json
credentials.json

# IDE & Editors
.vscode/
.idea/
*.swp
*.swo
*~
.DS_Store
*.sublime-project
*.sublime-workspace

# OS Files
Thumbs.db
Desktop.ini
.DS_Store
.AppleDouble
.LSOverride

# Logs
logs/
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*
pnpm-debug.log*

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Testing
coverage/
.nyc_output/
*.test.js.snap

# Database
*.sqlite
*.sqlite3
*.db
*.db-shm
*.db-wal

# Cache
.cache/
.parcel-cache/
.next/
.nuxt/
.sass-cache/
*.cache

# Secrets & Keys
*.pem
*.key
*.p12
*.pfx
id_rsa
id_rsa.pub
*.ppk

# Temporary files
tmp/
temp/
*.tmp
*.bak
*.swp

# Compiled files
*.com
*.class
*.dll
*.exe
*.o
*.so
*.pyc
__pycache__/

# Archives
*.7z
*.dmg
*.gz
*.iso
*.jar
*.rar
*.tar
*.zip

# PHP
composer.phar
composer.lock

# Python
*.py[cod]
*$py.class
*.egg-info/
dist/
venv/
ENV/

# Ruby
*.gem
.bundle/

# Java
target/
*.jar
*.war
*.ear

# This script
upload.sh
EOF
    echo -e "${GREEN}✓ .gitignore создан${NC}"
else
    echo -e "${YELLOW}⚠ .gitignore уже существует${NC}"
fi

# ════════════════════════════════════════════════════════════════
# ИНИЦИАЛИЗАЦИЯ GIT
# ════════════════════════════════════════════════════════════════

if [ ! -d ".git" ]; then
    echo -e "${BLUE}📦 Инициализация Git...${NC}"
    git init
    echo -e "${GREEN}✓ Git инициализирован${NC}"
else
    echo -e "${YELLOW}⚠ Git уже инициализирован${NC}"
fi

# Проверка текущей ветки
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "")
if [ -z "$CURRENT_BRANCH" ]; then
    CURRENT_BRANCH="main"
fi

if [ "$CURRENT_BRANCH" != "main" ]; then
    echo -e "${BLUE}🔀 Переименование ветки в main...${NC}"
    git branch -M main
fi

# ════════════════════════════════════════════════════════════════
# СОЗДАНИЕ РЕПОЗИТОРИЯ НА GITHUB
# ════════════════════════════════════════════════════════════════

echo -e "${BLUE}🔨 Создание репозитория на GitHub...${NC}"

if [ -n "$REPO_DESCRIPTION" ]; then
    CREATE_RESPONSE=$(curl -s -X POST \
      -H "Authorization: token $GITHUB_TOKEN" \
      -H "Accept: application/vnd.github.v3+json" \
      https://api.github.com/user/repos \
      -d "{\"name\":\"$REPO_NAME\",\"description\":\"$REPO_DESCRIPTION\",\"private\":$PRIVATE_FLAG}")
else
    CREATE_RESPONSE=$(curl -s -X POST \
      -H "Authorization: token $GITHUB_TOKEN" \
      -H "Accept: application/vnd.github.v3+json" \
      https://api.github.com/user/repos \
      -d "{\"name\":\"$REPO_NAME\",\"private\":$PRIVATE_FLAG}")
fi

if echo "$CREATE_RESPONSE" | grep -q "\"id\""; then
    echo -e "${GREEN}✓ Репозиторий создан успешно!${NC}"
else
    if echo "$CREATE_RESPONSE" | grep -q "already exists"; then
        echo -e "${YELLOW}⚠ Репозиторий уже существует. Продолжаем...${NC}"
    else
        echo -e "${RED}❌ Ошибка создания репозитория:${NC}"
        echo "$CREATE_RESPONSE" | grep "message"
        exit 1
    fi
fi

# ════════════════════════════════════════════════════════════════
# ДОБАВЛЕНИЕ ФАЙЛОВ И КОММИТ
# ════════════════════════════════════════════════════════════════

echo -e "${BLUE}📦 Добавление файлов в Git...${NC}"
git add .

if git diff --staged --quiet; then
    echo -e "${YELLOW}⚠ Нет изменений для коммита${NC}"
else
    echo -e "${BLUE}💾 Создание коммита...${NC}"
    git commit -m "Initial commit: Upload project to GitHub

Project: $REPO_NAME
Uploaded via automated script"
    echo -e "${GREEN}✓ Коммит создан${NC}"
fi

# ════════════════════════════════════════════════════════════════
# НАСТРОЙКА REMOTE И PUSH
# ════════════════════════════════════════════════════════════════

if git remote | grep -q "origin"; then
    echo -e "${YELLOW}⚠ Remote origin уже существует, обновляем...${NC}"
    git remote set-url origin "https://github.com/$GITHUB_USER/$REPO_NAME.git"
else
    echo -e "${BLUE}🔗 Добавление remote origin...${NC}"
    git remote add origin "https://github.com/$GITHUB_USER/$REPO_NAME.git"
fi

echo -e "${BLUE}🚀 Загрузка на GitHub...${NC}"
git push -u origin main

# ════════════════════════════════════════════════════════════════
# УСПЕХ!
# ════════════════════════════════════════════════════════════════

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                            ║${NC}"
echo -e "${GREEN}║          ✅ ПРОЕКТ УСПЕШНО ЗАГРУЖЕН НА GITHUB! ✅         ║${NC}"
echo -e "${GREEN}║                                                            ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}🔗 Ссылка на репозиторий:${NC}"
echo -e "${BLUE}   https://github.com/$GITHUB_USER/$REPO_NAME${NC}"
echo ""
echo -e "${CYAN}📝 Для обновления проекта в будущем используйте:${NC}"
echo -e "${YELLOW}   git add .${NC}"
echo -e "${YELLOW}   git commit -m \"Описание изменений\"${NC}"
echo -e "${YELLOW}   git push${NC}"
echo ""
echo -e "${GREEN}🎉 Готово!${NC}"
echo ""