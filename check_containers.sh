#!/bin/bash

# Скрипт для периодической проверки работоспособности Docker контейнеров
# и их перезапуска в случае падения

# Имена контейнеров
CONTAINER1="mtproxy"
CONTAINER2="nostalgic_hawking"

# Скрипты запуска
START_SCRIPT1="/opt/start-mtpoxy.sh"
START_SCRIPT2="/opt/socksstart.sh"

# Интервал проверки в секундах (по умолчанию 60 секунд)
CHECK_INTERVAL=${1:-60}

# Функция проверки состояния контейнера
check_container() {
    local container_name=$1
    local start_script=$2
    
    # Проверяем, запущен ли контейнер
    if ! docker ps --format "{{.Names}}" | grep -q "^${container_name}$"; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Контейнер ${container_name} не работает. Запускаем..."
        
        # Проверяем существование скрипта запуска
        if [ -x "$start_script" ]; then
            "$start_script"
            if [ $? -eq 0 ]; then
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] Контейнер ${container_name} успешно запущен."
            else
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] Ошибка при запуске контейнера ${container_name}!"
            fi
        else
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] Скрипт ${start_script} не найден или не исполняемый!"
        fi
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Контейнер ${container_name} работает нормально."
    fi
}

# Основной цикл
echo "Запуск мониторинга контейнеров..."
echo "Интервал проверки: ${CHECK_INTERVAL} секунд"
echo "Контейнеры: ${CONTAINER1}, ${CONTAINER2}"
echo "Нажмите Ctrl+C для остановки"
echo ""

while true; do
    check_container "$CONTAINER1" "$START_SCRIPT1"
    check_container "$CONTAINER2" "$START_SCRIPT2"
    
    sleep "$CHECK_INTERVAL"
done
