#!/bin/bash

# ════════════════════════════════════════════════════════════════
# 🚀 Универсальный скрипт загрузки проекта на GitHub (v2)
# ════════════════════════════════════════════════════════════════

set -e

# Цвета
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

clear

echo -e "${CYAN}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║           🚀 GitHub Project Upload Tool v2 🚀             ║"
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
    echo "   ${CYAN}echo 'export GITHUB_TOKEN=\"ваш_токен\"' >> ~/.zshrc${NC}"
    echo "   ${CYAN}source ~/.zshrc${NC}"
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
# ПРОВЕРКА СУЩЕСТВУЮЩЕГО РЕПОЗИТОРИЯ
# ════════════════════════════════════════════════════════════════

CURRENT_DIR=$(pwd)
PROJECT_NAME=$(basename "$CURRENT_DIR")

echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}📂 Текущая папка: ${NC}$CURRENT_DIR"
echo -e "${CYAN}📦 Название папки: ${NC}$PROJECT_NAME"
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo ""

# Проверка есть ли уже Git репозиторий
if [ -d ".git" ]; then
    EXISTING_REMOTE=$(git remote get-url origin 2>/dev/null || echo "")
    
    if [ -n "$EXISTING_REMOTE" ]; then
        # Извлекаем название репозитория из URL
        REPO_NAME_FROM_URL=$(echo "$EXISTING_REMOTE" | sed 's/.*\/\([^/]*\)\.git$/\1/')
        
        echo -e "${GREEN}✓ Найден существующий Git репозиторий!${NC}"
        echo -e "${CYAN}🔗 Remote: ${NC}$EXISTING_REMOTE"
        echo -e "${CYAN}📦 Репозиторий: ${NC}$REPO_NAME_FROM_URL"
        echo ""
        
        echo -e "${YELLOW}Что хотите сделать?${NC}"
        echo "   ${GREEN}1)${NC} Push изменений (обновить проект)"
        echo "   ${GREEN}2)${NC} Изменить видимость репозитория (public/private)"
        echo "   ${GREEN}3)${NC} Изменить remote на другой репозиторий"
        echo "   ${GREEN}4)${NC} Создать новый репозиторий"
        echo ""
        read -p "Ваш выбор (1/2/3/4): " EXISTING_CHOICE
        
        if [ "$EXISTING_CHOICE" = "1" ]; then
            # ════════════════════════════════════════════════════════════
            # ОБНОВЛЕНИЕ СУЩЕСТВУЮЩЕГО РЕПОЗИТОРИЯ
            # ════════════════════════════════════════════════════════════
            
            echo ""
            echo -e "${BLUE}📦 Проверка изменений...${NC}"
            git add .
            
            if git diff --staged --quiet; then
                echo -e "${YELLOW}⚠ Нет изменений для коммита${NC}"
                echo -e "${CYAN}Репозиторий уже синхронизирован!${NC}"
                exit 0
            fi
            
            echo ""
            echo -e "${YELLOW}📝 Введите описание изменений:${NC}"
            read -r COMMIT_MESSAGE
            
            if [ -z "$COMMIT_MESSAGE" ]; then
                COMMIT_MESSAGE="Update project files"
            fi
            
            echo -e "${BLUE}💾 Создание коммита...${NC}"
            git commit -m "$COMMIT_MESSAGE"
            
            echo -e "${BLUE}🚀 Загрузка на GitHub...${NC}"
            git push
            
            echo ""
            echo -e "${GREEN}✅ Изменения успешно загружены!${NC}"
            echo -e "${CYAN}🔗 Репозиторий: ${NC}https://github.com/$GITHUB_USER/$REPO_NAME_FROM_URL"
            exit 0
            
        elif [ "$EXISTING_CHOICE" = "2" ]; then
            # ════════════════════════════════════════════════════════════
            # ИЗМЕНЕНИЕ ВИДИМОСТИ РЕПОЗИТОРИЯ
            # ════════════════════════════════════════════════════════════
            
            echo ""
            echo -e "${YELLOW}Изменить видимость репозитория:${NC}"
            echo "   ${GREEN}1)${NC} Сделать приватным (🔒 Private)"
            echo "   ${GREEN}2)${NC} Сделать публичным (🌐 Public)"
            echo ""
            read -p "Ваш выбор (1/2): " VISIBILITY_CHANGE
            
            if [ "$VISIBILITY_CHANGE" = "1" ]; then
                NEW_VISIBILITY="true"
                VISIBILITY_TEXT="приватным 🔒"
            else
                NEW_VISIBILITY="false"
                VISIBILITY_TEXT="публичным 🌐"
            fi
            
            echo ""
            echo -e "${BLUE}🔄 Изменение видимости репозитория...${NC}"
            
            UPDATE_RESPONSE=$(curl -s -X PATCH \
              -H "Authorization: token $GITHUB_TOKEN" \
              -H "Accept: application/vnd.github.v3+json" \
              "https://api.github.com/repos/$GITHUB_USER/$REPO_NAME_FROM_URL" \
              -d "{\"private\":$NEW_VISIBILITY}")
            
            if echo "$UPDATE_RESPONSE" | grep -q "\"id\""; then
                echo -e "${GREEN}✅ Репозиторий успешно сделан $VISIBILITY_TEXT${NC}"
                echo -e "${CYAN}🔗 Проверьте: ${NC}https://github.com/$GITHUB_USER/$REPO_NAME_FROM_URL"
            else
                echo -e "${RED}❌ Ошибка изменения видимости${NC}"
                echo "$UPDATE_RESPONSE" | grep "message"
            fi
            
            exit 0
            
        elif [ "$EXISTING_CHOICE" = "4" ]; then
            # Создать новый - продолжаем ниже
            echo -e "${BLUE}Переходим к созданию нового репозитория...${NC}"
        else
            # Изменить remote - показываем список
            SHOW_REPO_LIST=true
        fi
    fi
fi

# ════════════════════════════════════════════════════════════════
# ПОКАЗАТЬ СПИСОК РЕПОЗИТОРИЕВ (если выбрано)
# ════════════════════════════════════════════════════════════════

if [ "$SHOW_REPO_LIST" = "true" ]; then
    echo ""
    echo -e "${BLUE}🔍 Загрузка списка ваших репозиториев...${NC}"
    
    REPOS_JSON=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/user/repos?sort=updated&per_page=30")
    
    echo ""
    echo -e "${CYAN}📚 Ваши репозитории (последние 30, новые сверху):${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
    
    REPO_COUNT=0
    declare -a REPO_NAMES
    declare -a REPO_URLS
    
    # Простой парсинг JSON
    echo "$REPOS_JSON" | grep -o '"name":"[^"]*"' | cut -d'"' -f4 | head -30 | while read name; do
        REPO_COUNT=$((REPO_COUNT + 1))
        
        url="https://github.com/$GITHUB_USER/$name.git"
        
        # Проверка приватности
        private=$(echo "$REPOS_JSON" | grep -A 1 "\"name\":\"$name\"" | grep '"private"' | grep -o 'true\|false' | head -1)
        
        if [ "$private" = "true" ]; then
            privacy="${YELLOW}🔒${NC}"
        else
            privacy="${GREEN}🌐${NC}"
        fi
        
        printf "${GREEN}%2d)${NC} %s %-40s\n" "$REPO_COUNT" "$privacy" "$name"
        
        echo "$name" >> /tmp/repo_names_$$
        echo "$url" >> /tmp/repo_urls_$$
    done
    
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}Введите номер репозитория (или 0 для создания нового):${NC}"
    read -p "Ваш выбор: " REPO_CHOICE
    
    if [ "$REPO_CHOICE" != "0" ]; then
        SELECTED_NAME=$(sed "${REPO_CHOICE}q;d" /tmp/repo_names_$$ 2>/dev/null)
        SELECTED_URL=$(sed "${REPO_CHOICE}q;d" /tmp/repo_urls_$$ 2>/dev/null)
        
        rm -f /tmp/repo_names_$$ /tmp/repo_urls_$$
        
        if [ -n "$SELECTED_NAME" ]; then
            echo ""
            echo -e "${GREEN}✓ Выбран: ${CYAN}$SELECTED_NAME${NC}"
            
            # Инициализация Git если нужно
            if [ ! -d ".git" ]; then
                git init
                git branch -M main
            fi
            
            # Установка remote
            if git remote | grep -q "origin"; then
                git remote set-url origin "$SELECTED_URL"
            else
                git remote add origin "$SELECTED_URL"
            fi
            
            # Создание .gitignore
            if [ ! -f ".gitignore" ]; then
                cat > .gitignore << 'GITIGNORE'
node_modules/
vendor/
.env
.env.*
.DS_Store
.vscode/
.idea/
*.log
dist/
build/
*.swp
upload.sh
GITIGNORE
            fi
            
            git add .
            
            echo ""
            echo -e "${YELLOW}📝 Описание коммита:${NC}"
            read -r COMMIT_MSG
            
            if [ -z "$COMMIT_MSG" ]; then
                COMMIT_MSG="Initial commit"
            fi
            
            git commit -m "$COMMIT_MSG"
            git push -u origin main --force
            
            echo ""
            echo -e "${GREEN}✅ Загружено!${NC}"
            echo -e "${CYAN}🔗 ${NC}https://github.com/$GITHUB_USER/$SELECTED_NAME"
            exit 0
        fi
    fi
    
    rm -f /tmp/repo_names_$$ /tmp/repo_urls_$$
fi

# ════════════════════════════════════════════════════════════════
# СОЗДАНИЕ НОВОГО РЕПОЗИТОРИЯ
# ════════════════════════════════════════════════════════════════

echo ""
echo -e "${YELLOW}📝 Название нового репозитория${NC}"
echo -e "${YELLOW}   (Enter для: ${GREEN}$PROJECT_NAME${YELLOW})${NC}"
read -r REPO_NAME

if [ -z "$REPO_NAME" ]; then
    REPO_NAME="$PROJECT_NAME"
fi

echo ""
echo -e "${YELLOW}📝 Описание проекта (необязательно):${NC}"
read -r REPO_DESCRIPTION

echo ""
echo -e "${YELLOW}🔒 Тип репозитория:${NC}"
echo "   ${GREEN}1)${NC} Private (приватный) 🔒 - ${CYAN}рекомендуется${NC}"
echo "   ${GREEN}2)${NC} Public (публичный) 🌐"
echo ""
read -p "Ваш выбор (1/2): " VISIBILITY_CHOICE

if [ "$VISIBILITY_CHOICE" = "2" ]; then
    VISIBILITY="public 🌐"
    PRIVATE_FLAG="false"
else
    VISIBILITY="private 🔒"
    PRIVATE_FLAG="true"
fi

# Подтверждение
echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}📋 Параметры:${NC}"
echo -e "${BLUE}────────────────────────────────────────────────────────────${NC}"
echo -e "${CYAN}📦 Название:${NC} $REPO_NAME"
[ -n "$REPO_DESCRIPTION" ] && echo -e "${CYAN}📝 Описание:${NC} $REPO_DESCRIPTION"
echo -e "${CYAN}🔒 Видимость:${NC} $VISIBILITY"
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo ""

read -p "$(echo -e ${YELLOW}Создать? ${GREEN}\(y/n\)${NC}: )" CONFIRM

if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo -e "${RED}❌ Отменено${NC}"
    exit 0
fi

echo ""
echo -e "${GREEN}🚀 Создание репозитория...${NC}"
echo ""

# .gitignore
if [ ! -f ".gitignore" ]; then
    echo -e "${BLUE}📝 Создание .gitignore...${NC}"
    cat > .gitignore << 'GITIGNORE'
node_modules/
vendor/
.env
.env.*
config.local.php
secrets.json
.vscode/
.idea/
*.swp
.DS_Store
*.log
dist/
build/
*.sqlite
*.db
*.tmp
upload.sh
GITIGNORE
    echo -e "${GREEN}✓${NC}"
fi

# Git init
if [ ! -d ".git" ]; then
    echo -e "${BLUE}📦 Git init...${NC}"
    git init
    git branch -M main
    echo -e "${GREEN}✓${NC}"
fi

# Создание на GitHub
echo -e "${BLUE}🔨 Создание на GitHub...${NC}"

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
    echo -e "${GREEN}✓ Создан!${NC}"
elif echo "$CREATE_RESPONSE" | grep -q "already exists"; then
    echo -e "${YELLOW}⚠ Уже существует${NC}"
else
    echo -e "${RED}❌ Ошибка${NC}"
    exit 1
fi

# Commit и push
echo -e "${BLUE}📦 Коммит...${NC}"
git add .
git commit -m "Initial commit: $REPO_NAME"

if git remote | grep -q "origin"; then
    git remote set-url origin "https://github.com/$GITHUB_USER/$REPO_NAME.git"
else
    git remote add origin "https://github.com/$GITHUB_USER/$REPO_NAME.git"
fi

echo -e "${BLUE}🚀 Push...${NC}"
git push -u origin main

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║               ✅ УСПЕШНО ЗАГРУЖЕНО! ✅                    ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}🔗 ${NC}https://github.com/$GITHUB_USER/$REPO_NAME"
echo ""
echo -e "${CYAN}Для обновлений:${NC}"
echo -e "${YELLOW}  ./upload.sh ${NC}(выберите опцию 1)"
echo -e "${CYAN}Или:${NC}"
echo -e "${YELLOW}  git add . && git commit -m \"msg\" && git push${NC}"
echo ""