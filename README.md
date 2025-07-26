# Кластер Apache Spark с Docker Compose

Этот проект содержит конфигурацию для развертывания кластера Apache Spark с помощью Docker Compose.

## Архитектура кластера

- **1 Spark Master** - координирует работу кластера
- **2 Spark Worker** - выполняют вычислительные задачи

## Структура проекта

```
hl-spark/
├── docker-compose.yml    # Конфигурация Docker Compose
├── data/                 # Директория для данных
├── apps/                 # Директория для Spark приложений
└── README.md            # Этот файл
```

## Требования

- Docker
- Docker Compose

## Запуск кластера

1. Запустите кластер:
```bash
docker-compose up -d
```

2. Проверьте статус контейнеров:
```bash
docker-compose ps
```

## Доступ к веб-интерфейсам

После запуска кластера будут доступны следующие веб-интерфейсы:

- **Spark Master UI**: http://localhost:8080
  - Показывает информацию о кластере, подключенных воркерах и запущенных приложениях
  
- **Spark Worker 1 UI**: http://localhost:8081
  - Показывает информацию о первом воркере
  
- **Spark Worker 2 UI**: http://localhost:8082
  - Показывает информацию о втором воркере
  
- **Spark Application UI**: http://localhost:4040
  - Доступен только когда запущено Spark приложение

## Конфигурация воркеров

Каждый воркер настроен со следующими параметрами:
- **Память**: 2GB
- **CPU ядра**: 2

## Выполнение Spark задач

### Подключение к контейнеру master

```bash
docker exec -it spark-master bash
```

### Запуск Spark Shell

```bash
# Scala Shell
docker exec -it spark-master spark-shell --master spark://spark-master:7077

# Python Shell (PySpark)
docker exec -it spark-master pyspark --master spark://spark-master:7077
```

### Отправка Spark приложения

```bash
docker exec -it spark-master spark-submit \
  --master spark://spark-master:7077 \
  --class <main-class> \
  /opt/bitnami/spark/apps/<your-app.jar>
```

## Размещение приложений и данных

- Поместите ваши Spark приложения в директорию `apps/`
- Поместите данные для обработки в директорию `data/`
- Эти директории монтируются в контейнеры и доступны по путям:
  - `/opt/bitnami/spark/apps/` - для приложений
  - `/opt/bitnami/spark/data/` - для данных

## Пример использования

### Простой пример на PySpark

1. Создайте файл `apps/word_count.py`:

```python
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("WordCount") \
    .getOrCreate()

# Создаем простой RDD
data = ["Hello Spark", "Hello World", "Spark is great"]
rdd = spark.sparkContext.parallelize(data)

# Подсчитываем слова
word_counts = rdd.flatMap(lambda line: line.split(" ")) \
                 .map(lambda word: (word, 1)) \
                 .reduceByKey(lambda a, b: a + b)

# Выводим результат
for word, count in word_counts.collect():
    print(f"{word}: {count}")

spark.stop()
```

2. Запустите приложение:

```bash
docker exec -it spark-master spark-submit \
  --master spark://spark-master:7077 \
  /opt/bitnami/spark/apps/word_count.py
```

## Остановка кластера

```bash
# Остановить кластер
docker-compose down

# Остановить кластер и удалить volumes
docker-compose down -v
```

## Мониторинг

- Используйте `docker-compose logs` для просмотра логов
- Мониторьте ресурсы через веб-интерфейсы
- Проверяйте статус воркеров в Spark Master UI

## Масштабирование

Для добавления дополнительных воркеров, добавьте новые сервисы в `docker-compose.yml`:

```yaml
spark-worker-3:
  image: bitnami/spark:3.5
  container_name: spark-worker-3
  hostname: spark-worker-3
  environment:
    - SPARK_MODE=worker
    - SPARK_MASTER_URL=spark://spark-master:7077
    - SPARK_WORKER_MEMORY=2g
    - SPARK_WORKER_CORES=2
    # ... остальные переменные окружения
  ports:
    - "8083:8081"
  # ... остальная конфигурация
```

## Устранение неполадок

1. **Воркеры не подключаются к мастеру**:
   - Проверьте, что все контейнеры запущены
   - Убедитесь, что сеть spark-network работает корректно

2. **Недостаточно ресурсов**:
   - Уменьшите SPARK_WORKER_MEMORY и SPARK_WORKER_CORES
   - Проверьте доступные ресурсы Docker

3. **Порты заняты**:
   - Измените порты в docker-compose.yml на свободные
