#!/bin/bash

# Создаем директорию для бэкапа
BACKUP_DIR="project_backups"
mkdir -p $BACKUP_DIR

# Генерируем имя файла с датой
BACKUP_NAME="DogCareProject_$(date +%Y-%m-%d_%H-%M-%S).zip"
BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"

# Список файлов и директорий для бэкапа
FILES_TO_BACKUP=(
    "*.swift"
    "*.strings"
    "*.plist"
    "*.xcdatamodeld"
    "*.xcodeproj"
    "ru.lproj"
)

# Создаем архив
zip -r "$BACKUP_PATH" ${FILES_TO_BACKUP[@]} \
    -x "*.DS_Store" \
    -x "*/.git/*" \
    -x "*/build/*" \
    -x "*/DerivedData/*" \
    -x "*.xcuserstate" \
    -x "project_backups/*"

echo "Backup created: $BACKUP_PATH" 