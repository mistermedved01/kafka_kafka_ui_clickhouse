ENV['VAGRANT_SERVER_URL'] = 'http://vagrant.elab.pro'

Vagrant.configure("2") do |config|
  config.vm.define "clickhouse" do |clickhouse|
    clickhouse.vm.box = "ubuntu/jammy64"
    clickhouse.vm.network "private_network", ip: "192.168.1.112"
    clickhouse.vm.provision "shell", path: "scripts/clickhouse_install.sh"
    clickhouse.vm.provider "virtualbox" do |vb|
      vb.name = "clickhouse"
      vb.memory = "2000"
      vb.cpus = 2
    end
  end
  config.vm.define "kafka" do |kafka|
    kafka.vm.box = "ubuntu/jammy64"
    kafka.vm.network "private_network", ip: "192.168.1.110"
    kafka.vm.provision "shell", path: "scripts/kafka_install.sh"
    kafka.vm.provider "virtualbox" do |vb|
      vb.name = "kafka"
      vb.memory = "2000"
      vb.cpus = 2
      end
    end
  config.vm.define "kafka_ui" do |kafka_ui|
    kafka_ui.vm.box = "ubuntu/jammy64"
    kafka_ui.vm.network "private_network", ip: "192.168.1.111"
    kafka_ui.vm.provision "shell", path: "scripts/kafka_ui_install.sh"
    kafka_ui.vm.provider "virtualbox" do |vb|
      vb.name = "kafka_ui"
      vb.memory = "2000"
      vb.cpus = 2
      end
    end
  end