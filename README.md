## Задача :bulb:

1. Установить Kafka (VM - kafka)
2. Установить Kafka UI (VM - kafka_ui)
3. Подключить Kafka UI к Kafka.
4. Установить ClickHouse (VM - clickhouse)
5. Настроить БД ClickHouse для хранения данных из Kafka.
6. Через Kafka UI записать сообщение в Kafka и проверить, что оно появилось в ClickHouse

### I. Отправка данных через консоль :pager::

#### 1. VM - kafka. Producer отправляет данные в `my_topic`:
`echo '{"id": 1, "message": "Hello, ClickHouse!"}' | /opt/kafka/bin/kafka-console-producer.sh --topic my_topic --bootstrap-server 192.168.1.110:9092`

#### 2. VM - kafka. Создает Topic из которого ClickHouse будет читать данные:
`/opt/kafka/bin/kafka-topics.sh --create --topic my_topic --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1`

#### 3. VM - kafka. Broker принимает данные от Producer, хранит их в топике и отдаёт Consumer.

`/opt/kafka/config/server.properties`

`listeners=PLAINTEXT://0.0.0.0:9092`
`advertised.listeners=PLAINTEXT://192.168.1.110:9092`

#### 4. VM - kafka. ZooKeeper управляет метаданными Kafka (топики, партиции, offset'ы) и координирует брокер.

#### 5. VM - clickhouse. Consumer читает данные из `my_topic` и записывает в `my_data`

#### VM - ClickHouse. Выполнив команду: 
`clickhouse-client --query "SELECT * FROM my_data;"` 
#### Мы должны увидеть сообщение из пункта 1: 
`1 Hello, ClickHouse! 2025-02-25 13:10:19`

### II. Отправка данных через UI :vhs::

Kafka UI доступна по адресу: `http://192.168.1.111:8080/`

Для записи сообщения через Kafka UI:

Topics -> my_topic -> Produce Message -> В поле Value `{"id": 2, "message": "Test from Kafka UI"}`

Проверяем: `clickhouse-client --query "SELECT * FROM my_data;"` 

`2       Test from Kafka UI      2025-02-25 16:17:58` отправлено через UI 

`1       Hello, ClickHouse!      2025-02-25 16:11:55` отправлено через консоль