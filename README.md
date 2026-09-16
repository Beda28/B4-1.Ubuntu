# 1. 문서 개요
> 본 프로젝트는 Ubuntu 환경에서 애플리케이션을 실행하고, 시스템 환경을 구성하는 과정을 다룹니다.

# 2. 환경 세팅
```bash
# docker의 우분투 이미지 내부에서 실습을 진행했습니다.
docker pull ubuntu:22.04
docker run -dit --name ubuntu        \
    --privileged                     \
    -p 20022:20022 -p 15034:15034    \
    -v ./bind:/usr/bind ubuntu:22.04 \
    sleep infinity
docker exec -it [컨테이너_id] bash 
```

# 3. 유저 / 그룹 생성
```bash
# 그룹 생성
groupadd agent-common
groupadd agent-core

# 사용자 생성
useradd -m -s /bin/bash agent-admin
useradd -m -s /bin/bash agent-dev  
useradd -m -s /bin/bash agent-test

# 그룹에 사용자 추가
usermod -aG agent-common agent-admin
usermod -aG agent-common agent-dev  
usermod -aG agent-common agent-test

usermod -aG agent-core agent-admin
usermod -aG agent-core agent-dev  
```

# 4. 디렉토리 생성 및 이동
```bash
mkdir -p /home/agent-admin/agent-app/{upload_files,api_keys,bin}
mkdir -p /var/log/agent-app

mv /usr/bind/agent-app-linux-x86 /home/agent-admin/agent-app/
mv /usr/bind/moniter.sh /home/agent-admin/agent-app/bin/

echo 'agent_api_key_test' > /home/agent-admin/agent-app/api_keys/secret.key
touch /var/log/agent-app/moniter.log
```

# 5. 디렉토리 권한 설정
```bash
chown agent-admin:agent-core /home/agent-admin/agent-app
chmod 750 /home/agent-admin/agent-app

chown agent-admin:agent-core /home/agent-admin/agent-app/agent-app-linux-x86
chmod 750 /home/agent-admin/agent-app/agent-app-linux-x86

chown agent-admin:agent-core /home/agent-admin/agent-app/upload_files
chmod 750 /home/agent-admin/agent-app/upload_files

chown agent-admin:agent-core /home/agent-admin/agent-app/api_keys
chmod 750 /home/agent-admin/agent-app/api_keys

chown agent-admin:agent-core /home/agent-admin/agent-app/api_keys/secret.key
chmod 660 /home/agent-admin/agent-app/api_keys/secret.key

chown agent-admin:agent-core /home/agent-admin/agent-app/bin
chmod 750 /home/agent-admin/agent-app/bin

chown agent-dev:agent-core /home/agent-admin/agent-app/bin/moniter.sh
chmod 750 /home/agent-admin/agent-app/bin/moniter.sh

chown agent-dev:agent-core /var/log/agent-app
chmod 770 /var/log/agent-app

chown agent-dev:agent-core /var/log/agent-app/moniter.log
chmod 660 /var/log/agent-app/moniter.log
```

# 6. 사용자 전환, 환경변수 설정, 파일 실행
```bash
su agent-admin
cd agent-app

export AGENT_HOME=/home/agent-admin/agent-app
export AGENT_PORT=15034
export AGENT_UPLOAD_DIR=$AGENT_HOME/upload_files
export AGENT_KEY_PATH=$AGENT_HOME/api_keys 
export AGENT_LOG_DIR=/var/log/agent-app

./agent-app-linux-x86 
```
![실행 성공 이미지](/screenshot/5OK.png)

# 7. 패키지 설치
```bash
apt update
apt install openssh-server -y
apt install ufw -y
apt install nano -y
apt install cron -y
apt install logrotate -y
```

# 8. ssh 세팅
```bash
nano /etc/ssh/sshd_config

Port 22 => Port 20022

#주석 해제 및 변경
PermitRootLogin 
prohibit-password => no 

service ssh restart
service ssh status
```

# 9. ufw 세팅
```bash
ufw allow 20022/tcp
ufw allow 15034/tcp
ufw enable
```

# 10. moniter.sh cron 등록
```bash
su - agent-dev
crontab -e

# 분 시 일 월 요일 실행할 명령어
* * * * * /home/agent-admin/agent-app/bin/moniter.sh

service cron start
service cron status

cat /var/log/agent-app/moniter.log
```

# 11. logrotate 설정 (메모리 관리)
```bash
nano /etc/logrotate.d/agent-app

/var/log/agent-app/moniter.log {
    size 10M
    rotate 10
    missingok
    notifempty
    compress
    delaycompress
    copytruncate
    su agent-dev agent-core
}

chown root:root /etc/logrotate.d/agent-app
chmod 644 /etc/logrotate.d/agent-app

cat /etc/logrotate.d/agent-app

logrotate -v -f /etc/logrotate.d/agent-app
ls -lh /var/log/agent-app
```