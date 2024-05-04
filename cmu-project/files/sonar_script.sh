#!/bin/bash

# Increase the vm.max_map_count for kernel and ulimit for the current session at runtime.
sudo sysctl -w vm.max_map_count=524288
sudo sysctl -w fs.file-max=131072
ulimit -n 65536
ulimit -u 4096

# Increase these limits permanently
sudo bash -c 'cat <<EOT> /etc/security/limits.conf
sonarqube   -   nofile   65536
sonarqube   -   nproc    4096
EOT'

# Need JDK 17 or higher to run SonarQube 9.9
sudo apt-get update -y
sudo apt-get install openjdk-17-jdk -y
java -version

# Install and configure PostgreSQL & create a user and database for sonar
wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
sudo apt-get update -y
sudo apt install postgresql postgresql-contrib -y
sudo systemctl enable postgresql
sudo systemctl start  postgresql
echo "postgres:admin123" | sudo chpasswd
runuser -l postgres -c "createuser sonar"
sudo -i -u postgres psql -c "ALTER USER sonar WITH ENCRYPTED PASSWORD 'admin123';"
sudo -i -u postgres psql -c "CREATE DATABASE sonarqube OWNER sonar;"
sudo -i -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE sonarqube to sonar;"
sudo systemctl restart postgresql

# Download the binaries for SonarQube
sudo mkdir -p /sonarqube/
cd /sonarqube/
sudo curl -O https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-10.5.1.90531.zip
sudo apt-get install zip -y
sudo unzip -o sonarqube-10.5.1.90531.zip -d /opt/
sudo mv /opt/sonarqube-10.5.1.90531/ /opt/sonarqube

# Configure SonarQube
sudo bash -c 'cat <<EOT> /opt/sonarqube/conf/sonar.properties
sonar.jdbc.username=sonar
sonar.jdbc.password=admin123
sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube
sonar.web.host=0.0.0.0
sonar.web.port=9000
sonar.web.javaAdditionalOpts=-server
sonar.search.javaOpts=-Xmx512m -Xms512m -XX:+HeapDumpOnOutOfMemoryError
sonar.log.level=INFO
sonar.path.logs=logs
EOT'
sudo chown sonar:sonar /opt/sonarqube/ -R

# Create a systemd service file for SonarQube to run at system startup
sudo bash -c 'cat <<EOT> /etc/systemd/system/sonarqube.service
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking

ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop

User=sonar
Group=sonar
Restart=always

LimitNOFILE=65536
LimitNPROC=4096
LimitMEMLOCK=infinity
LimitAS=infinity

[Install]
WantedBy=multi-user.target
EOT'

# Automatically enable SonarQube at system startup
sudo systemctl daemon-reload
sudo systemctl enable sonarqube.service
sudo systemctl start sonarqube.service
