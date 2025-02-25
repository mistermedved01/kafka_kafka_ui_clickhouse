# Установка OpenJDK и Kafka
apt update
apt install -y openjdk-17-jdk
wget https://downloads.apache.org/kafka/3.9.0/kafka_2.12-3.9.0.tgz
mkdir /opt/kafka
tar zxf kafka_*.tgz -C /opt/kafka --strip 1

cat <<EOF >> /opt/kafka/config/server.properties
delete.topic.enable = true
listeners=PLAINTEXT://0.0.0.0:9092
advertised.listeners=PLAINTEXT://192.168.1.110:9092
EOF

# Создание пользователя
useradd -r -c 'Kafka broker user service' kafka
chown -R kafka:kafka /opt/kafka

# Zookeeper systemd-юнит
cat <<EOF > /etc/systemd/system/zookeeper.service
[Unit]
Description=Zookeeper Service
Requires=network.target remote-fs.target
After=network.target remote-fs.target

[Service]
Type=simple
User=kafka
ExecStart=/opt/kafka/bin/zookeeper-server-start.sh /opt/kafka/config/zookeeper.properties
ExecStop=/opt/kafka/bin/zookeeper-server-stop.sh
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Kafka systemd-юнит
cat <<EOF > /etc/systemd/system/kafka.service
[Unit]
Description=Kafka Service
Requires=zookeeper.service
After=zookeeper.service

[Service]
Type=simple
User=kafka
ExecStart=/bin/sh -c '/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties > /opt/kafka/kafka.log 2>&1'
ExecStop=/opt/kafka/bin/kafka-server-stop.sh
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Настройка автозапуска
systemctl daemon-reload || { echo "Ошибка перезагрузки systemd"; exit 1; }
sleep 5
systemctl enable zookeeper kafka || { echo "Ошибка настройки автозапуска"; exit 1; }
sleep 5
systemctl start kafka
sleep 5

# Проверка порта
ss -tunlp | grep :9092

# Создаем топик из которого ClickHouse будет читать данные. Брокер - localhost:9092 Топик: my_topic
/opt/kafka/bin/kafka-topics.sh --create --topic my_topic --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1
# Создаем тествое сообщение
echo '{"id": 1, "message": "Hello, ClickHouse!"}' | /opt/kafka/bin/kafka-console-producer.sh --topic my_topic --bootstrap-server 192.168.1.110:9092
### На машине ClickHouse выполнив команду: clickhouse-client --query "SELECT * FROM my_data;" 
### Мы должны увидеть сообщение вида: 1 Hello, ClickHouse! 2025-02-25 13:10:19