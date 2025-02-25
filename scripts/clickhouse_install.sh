apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 8919F6BD2B48D754
echo "deb https://packages.clickhouse.com/deb stable main" > /etc/apt/sources.list.d/clickhouse.list
apt update
apt install -y expect
/usr/bin/expect <<EOD
set timeout 300
spawn sudo apt-get install -y clickhouse-server clickhouse-client
expect {
    "Set up the password for the default user:" { send "\r"; exp_continue }
    "*** users.xml (Y/I/N/O/D/Z) \[default=N\] ?" { send "N\r"; exp_continue }
    eof { exit 0 }
}
EOD
systemctl start clickhouse-server
systemctl enable clickhouse-server

# Проверка, что clickhouse-client доступен
if ! command -v clickhouse-client &> /dev/null; then
    echo "Ошибка: clickhouse-client не найден. Убедитесь, что ClickHouse установлен."
    exit 1
fi

# Создание таблицы kafka_queue
clickhouse-client --query "
CREATE TABLE kafka_queue
(
    id UInt32,
    message String
)
ENGINE = Kafka
SETTINGS kafka_broker_list = '192.168.1.110:9092',
         kafka_topic_list = 'my_topic',
         kafka_group_name = 'clickhouse_group',
         kafka_format = 'JSONEachRow';
"

# Создание таблицы my_data
clickhouse-client --query "
CREATE TABLE my_data
(
    id UInt32,
    message String,
    timestamp DateTime DEFAULT now()
)
ENGINE = MergeTree()
ORDER BY (timestamp, id);
"

# Создание материализованного представления kafka_to_data
clickhouse-client --query "
CREATE MATERIALIZED VIEW kafka_to_data
TO my_data
AS SELECT id, message, now() AS timestamp
FROM kafka_queue;
"

# Проверка успешного выполнения
if [ $? -eq 0 ]; then
    echo "Таблицы и материализованное представление успешно созданы."
    # Вывод списка таблиц для проверки
    clickhouse-client --query "SHOW TABLES;"
else
    echo "Ошибка при создании таблиц или материализованного представления."
    echo "Проверьте логи ClickHouse: /var/log/clickhouse-server/clickhouse-server.log"
    exit 1
fi