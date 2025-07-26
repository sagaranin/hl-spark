#!/bin/bash

# Скрипт для управления Spark кластером

echo "=== Команды управления Spark кластером ==="
echo ""

case "$1" in
    "start")
        echo "Запуск Spark кластера..."
        docker-compose up -d
        echo "Кластер запущен!"
        echo "Веб-интерфейсы:"
        echo "  - Spark Master: http://localhost:8080"
        echo "  - Worker 1: http://localhost:8081"
        echo "  - Worker 2: http://localhost:8082"
        ;;
    
    "stop")
        echo "Остановка Spark кластера..."
        docker-compose down
        echo "Кластер остановлен!"
        ;;
    
    "restart")
        echo "Перезапуск Spark кластера..."
        docker-compose down
        docker-compose up -d
        echo "Кластер перезапущен!"
        ;;
    
    "status")
        echo "Статус контейнеров:"
        docker-compose ps
        ;;
    
    "logs")
        if [ -z "$2" ]; then
            echo "Логи всех сервисов:"
            docker-compose logs --tail=50
        else
            echo "Логи сервиса $2:"
            docker-compose logs --tail=50 "$2"
        fi
        ;;
    
    "shell")
        echo "Подключение к Spark Master..."
        docker exec -it spark-master bash
        ;;
    
    "pyspark")
        echo "Запуск PySpark shell..."
        docker exec -it spark-master pyspark --master spark://spark-master:7077
        ;;
    
    "spark-shell")
        echo "Запуск Spark Scala shell..."
        docker exec -it spark-master spark-shell --master spark://spark-master:7077
        ;;
    
    "submit")
        if [ -z "$2" ]; then
            echo "Использование: $0 submit <путь-к-приложению>"
            echo "Пример: $0 submit /opt/bitnami/spark/apps/word_count.py"
        else
            echo "Отправка Spark приложения: $2"
            docker exec -it spark-master spark-submit --master spark://spark-master:7077 "$2"
        fi
        ;;
    
    "example")
        echo "Запуск примера подсчета слов..."
        docker exec -it spark-master spark-submit --master spark://spark-master:7077 /opt/bitnami/spark/apps/word_count.py
        ;;
    
    "clean")
        echo "Очистка всех данных и остановка кластера..."
        docker-compose down -v
        echo "Кластер остановлен и данные очищены!"
        ;;
    
    *)
        echo "Доступные команды:"
        echo "  start      - Запустить кластер"
        echo "  stop       - Остановить кластер"
        echo "  restart    - Перезапустить кластер"
        echo "  status     - Показать статус контейнеров"
        echo "  logs [сервис] - Показать логи (всех или конкретного сервиса)"
        echo "  shell      - Подключиться к master контейнеру"
        echo "  pyspark    - Запустить PySpark shell"
        echo "  spark-shell - Запустить Spark Scala shell"
        echo "  submit <app> - Отправить Spark приложение"
        echo "  example    - Запустить пример подсчета слов"
        echo "  clean      - Остановить кластер и очистить данные"
        echo ""
        echo "Примеры:"
        echo "  $0 start"
        echo "  $0 logs spark-master"
        echo "  $0 submit /opt/bitnami/spark/apps/word_count.py"
        ;;
esac
