#!/bin/bash
echo "======add user to docker group ======"
gpasswd -a $USER docker 
newgrp docker
mkdir -p /etc/docker
touch /etc/docker/daemon.json
chmod 777 /etc/docker/daemon.json
echo "{
 \"registry-mirrors\": [\"https://docker.mirrors.ustc.edu.cn\"]
}" >> /etc/docker/daemon.json
echo "======change docker source======"
systemctl daemon-reload
systemctl restart docker
systemctl enable docekr
git clone https://github.com/kidari/docker-data.git
docker run -p 3306:3306 --restart always --name mysql01 \
    -v /home/vagrant/docker-data/mysql/conf:/etc/mysql/ \
    -v /home/vagrant/docker-data/mysql/log:/var/log/mysql \
    -v /home/vagrant/docker-data/mysql/data:/var/lib/mysql \
    -e MYSQL_ROOT_PASSWORD=abc123 \
    -d mysql:5.7
echo "======mysql start======"
echo "docker exec -it mysql /bin/bash"
docker run -p 6379:6379 --restart always --name redis01 \
    -v /home/vagrant/docker-data/redis/data:/data \
    -v /home/vagrant/docker-data/redis/conf/redis.conf:/etc/redis/redis.conf \
    -d redis:5.0.7 redis-server /etc/redis/redis.conf
echo "======redis start======"