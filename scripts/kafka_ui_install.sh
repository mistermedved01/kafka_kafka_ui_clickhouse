sudo apt update
sudo apt install -y openjdk-17-jdk

wget https://github.com/provectus/kafka-ui/releases/download/v0.7.2/kafka-ui-api-v0.7.2.jar -O kafka-ui.jar
sudo mkdir -p /opt/kafka-ui
sudo mv kafka-ui.jar /opt/kafka-ui/
useradd -r -c 'Kafka-ui user service' kafka-ui
sudo chown -R kafka-ui:kafka-ui /opt/kafka-ui  

cat <<EOF > /opt/kafka-ui/config.yaml
server:
  port: 8080  # Порт для UI, можно сменить на другой, например, 8081
auth:
  type: DISABLED  # Отключить аутентификацию 
kafka:
  clusters:
    - name: my-kafka-cluster
      bootstrapServers: 192.168.1.110:9092 
EOF

cat <<EOF > /etc/systemd/system/kafka-ui.service
[Unit]
Description=Kafka UI Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/java -jar /opt/kafka-ui/kafka-ui.jar --spring.config.location=/opt/kafka-ui/config.yaml
ExecStop=/bin/kill -15 \$MAINPID
Restart=on-failure
StandardOutput=append:/opt/kafka-ui/kafka-ui.log
StandardError=append:/opt/kafka-ui/kafka-ui.log

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable kafka-ui
systemctl start kafka-ui