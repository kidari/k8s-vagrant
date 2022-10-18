#!/bin/bash
#  . 添加root密码 sudo passwd
# 2. 更改当前用户文件访问权限 /etc/sudoers
# 3. 修改host /etc/hosts
# cd /etc/systemd/system/network-online.target.wants/
# systemd-networkd-wait-online.service
# TimeoutStartSec=2sec
# mvn clean package -Dmaven.test.skip=true
PUBLIC_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCmllUw+LxXIOaecGKltIOPSJME3oDTt0fhT3b9H7/jICuhTQOzASvoNpdLTB0kmgEyDxJtbBA7yPX455GQlAUm9PHvFI+ojhDRkew5DUcbGRRSzAMZbPORpxLPRTIKlRib9q9OOMu4fN+Bg73gE5f8B4J0yRi7rJIw6V13fXX4CVlo5xpnE8bs2KQwGqjkoQJML+jblUy08A52T1fHw8eOqjJKMOXbKAIVtgepJBApnkrFB/13pHDM3lhL0ocyrOnBCkf/JR0wJJbJ7UtreuC4SQ3YCVvn5n5pDmXiUYuEnTQGfeOS7/yLVkIkEFFAHViNI13nv+ukCFEs083vA5Kqzq3Jj8/B4qmxf7yCWHHWQwqhW4KEQcigTOkTXKBhF08wgqLCYwgy3fk3apunycqVPrsGNl+Wm2dqpHuOa9kiLq+UCvVbo1PtAdQVnTJH+hDg36GbS3rRPxpIE3gMJFL66uHviW0SOtvTJmubczZEcUR84tNDKrXxXbKGrSXhBMs= Administrator@MS-202009112247"
SERVER=master
USER_FILE_FOLDER=/home/kidari
ENVIRONMENT_LOCATION=/opt/env
SOFTWARE_LOCATION=$USER_FILE_FOLDER/soft
WORKSPACE_LOCATION=$USER_FILE_FOLDER/workspace
JAVAWORKSPACE_LOCATION=$WORKSPACE_LOCATION/java 
GOWORKSPACE_LOCATION=$WORKSPACE_LOCATION/go
PYTHONWORKSPACE_LOCATION=$WORKSPACE_LOCATION/python
WEBFRONTWORKSPACE_LOCATION=$WORKSPACE_LOCATION/front
GO_VERSION=go
JDK_VERSION=jdk1.8.0_211
JDK_PACKAGE=jdk-8u211-linux-x64.tar.gz
JDK11_VERSION=jdk-11.0.2
JDK11_PACKAGE=openjdk-11.0.2_linux-x64_bin.tar.gz
MAVEN_VERSION=apache-maven-3.6.3
MAVEN_PACKAGE=apache-maven-3.6.3-bin.tar.gz
MAVEN_ALI_CONF=settings.xml.ali
MAVEN_localRepository=/opt/env/mvn_repository

GO_PACKAGE=go1.14.6.linux-amd64.tar.gz

NODEJS_VERSION=node-v12.18.3-linux-x64
NODEJS_PACAGE=node-v12.18.3-linux-x64.tar.xz
# PATHEND="export PATH=\$PATH:\$GOROOT:\$GOBIN:\$GOPATH:\$JAVA_HOME/bin:\$JAVA_HOME/jre/bin:\$MAVEN_HOME/bin:\$NODE_HOME/bin"
PATHEND="export PATH=\$PATH:\$GOROOT:\$GOBIN:\$GOPATH:\$JAVA_HOME/bin:\$MAVEN_HOME/bin:\$NODE_HOME/bin"
publicKey_ssh_copy_id(){
    echo "======remote master isa_pub:$PUBLIC_KEY======"
    sleep 1s
    mkdir $USER_FILE_FOLDER/.ssh
    echo $PUBLIC_KEY >> $USER_FILE_FOLDER/.ssh/authorized_keys
}

pip_install(){
    echo "======start change pypi source======"
    sleep 1s
sudo apt-get -y install python3-pip
mkdir $USER_FILE_FOLDER/.pip
echo "[global]
index-url = https://mirrors.aliyun.com/pypi/simple/

[install]
trusted-host=mirrors.aliyun.com" >> $USER_FILE_FOLDER/.pip/pip.conf

}

docker_install(){
# Step 1: 安装必要软件
sudo apt-get -y install apt-transport-https ca-certificates software-properties-common
# Step 2: 安装GPG证书
curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
# Step 3: 写入软件源信息
sudo add-apt-repository "deb [arch=amd64] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
# Step 4: 更新并安装Docker-CE
sudo apt-get -y update
sudo apt-get -y install docker-ce
# Step 6: 更换镜像源
sudo mkdir -p /etc/docker
sudo touch /etc/docker/daemon.json
sudo chmod 777 /etc/docker/daemon.json
echo "{
 \"registry-mirrors\": [\"https://docker.mirrors.ustc.edu.cn\"]
}" >> /etc/docker/daemon.json
echo "======change docker source======"
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo docker pull mysql:5.7
sudo docker pull redis:5.0.7
sudo docker pull nginx

# docker pull wurstmeister/kafka:2.12-2.0.1
# docker pull zookeeper:3.4.14 
# docker pull emqx/emqx
# docker pull timescale/timescaledb
#mysql
mkdir -p $USER_FILE_FOLDER/mydata/mysql/node-01/conf
echo "[client]
default-character-set = utf8

[mysql]
default-character-set = utf8

[mysqld]
init_connect='SET collation_connection = utf8_unicode_ci'
init_connect='SET NAMES utf8'
character-set-server=utf8
collation-server=utf8_unicode_ci
skip-character-set-client-handshake
skip-name-resolve" >> $USER_FILE_FOLDER/mydata/mysql/node-01/conf/my.conf
#redis
mkdir -p $USER_FILE_FOLDER/mydata/redis/node-01/conf
echo "appendonly yes" >> $USER_FILE_FOLDER/mydata/redis/node-01/conf/redis.conf
}

dockerContainer_install(){

docker run -p 3306:3306 --name mysql01 \
    -v ~/mydata/mysql/node-01/conf:/etc/mysql/ \
    -v ~/mydata/mysql/node-01/log:/var/log/mysql \
    -v ~/mydata/mysql/node-01/data:/var/lib/mysql \
    -e MYSQL_ROOT_PASSWORD=123456 \
    -d mysql:5.7
# echo "======mysql start======"

docker run -p 6379:6379 --name redis01 \
    -v ~/mydata/redis/node-01/data:/data \
    -v ~/mydata/redis/node-01/conf/redis.conf:/etc/redis/redis.conf \
    -d redis:5.0.7 redis-server /etc/redis/redis.conf
# echo "======redis start======"
}

golang_install(){
    echo "======start install go version-no:$GO_PACKAGE======"
    sleep 1s
    cd $SOFTWARE_LOCATION
    wget http://$SERVER/$GO_PACKAGE
    tar zxf $GO_PACKAGE
    sudo cp -r $GO_VERSION $ENVIRONMENT_LOCATION
    echo "export GOROOT=$ENVIRONMENT_LOCATION/go" >>/etc/profile
    echo "export GOBIN=\$GOROOT/bin" >>/etc/profile
    echo "export GOPATH=$GOWORKSPACE_LOCATION" >>/etc/profile
    echo "export GO111MODULE=on" >>/etc/profile
    echo "export GOPROXY=http://mirrors.aliyun.com/goproxy/" >>/etc/profile
}

jdk8_install(){
    echo "======start install jdk8 version-no:$JDK_VERSION======"
    cd $SOFTWARE_LOCATION
    wget http://$SERVER/$JDK_PACKAGE
    echo "======start install maven version-no:$MAVEN_VERSION======"
    sleep 1s
    wget http://$SERVER/$MAVEN_PACKAGE
    wget http://$SERVER/$MAVEN_ALI_CONF
    tar zxf $JDK_PACKAGE
    sudo cp -r $JDK_VERSION $ENVIRONMENT_LOCATION
    tar zxf $MAVEN_PACKAGE 
    sudo cp -r $MAVEN_VERSION $ENVIRONMENT_LOCATION
    cd $ENVIRONMENT_LOCATION
    sudo mv $JDK_VERSION jdk
    sudo mv $MAVEN_VERSION maven
    echo "======maven change ali source======"
    sudo mv maven/conf/settings.xml maven/conf/settings.xml.bak
    sudo cp $SOFTWARE_LOCATION/$MAVEN_ALI_CONF maven/conf/settings.xml
    echo "export JAVA_HOME=$ENVIRONMENT_LOCATION/jdk" >>/etc/profile
    echo "export CLASSPATH=.:\$JAVA_HOME/lib/tools.jar:\$JAVA_HOME/jre/lib/dt.jar" >>/etc/profile
    echo "export MAVEN_HOME=$ENVIRONMENT_LOCATION/maven" >>/etc/profile
    echo "======install completed jdk version-no:$JDK_VERSION======"
    sleep 1s
}

jdk11_install(){
    echo "======start install jdk11 version-no:$JDK11_VERSION======"
    cd $SOFTWARE_LOCATION
    wget http://$SERVER/$JDK11_PACKAGE
    echo "======start install maven version-no:$MAVEN_VERSION======"
    sleep 1s
    wget http://$SERVER/$MAVEN_PACKAGE
    wget http://$SERVER/$MAVEN_ALI_CONF
    tar zxf $JDK11_PACKAGE
    sudo cp -r $JDK11_VERSION $ENVIRONMENT_LOCATION
    tar zxf $MAVEN_PACKAGE 
    sudo cp -r $MAVEN_VERSION $ENVIRONMENT_LOCATION
    cd $ENVIRONMENT_LOCATION
    sudo mv $JDK11_VERSION jdk
    sudo mv $MAVEN_VERSION maven
    echo "======maven change ali source======"
    sudo mv maven/conf/settings.xml maven/conf/settings.xml.bak
    sudo cp $SOFTWARE_LOCATION/$MAVEN_ALI_CONF maven/conf/settings.xml
    echo "export JAVA_HOME=$ENVIRONMENT_LOCATION/jdk" >>/etc/profile
    echo "export MAVEN_HOME=$ENVIRONMENT_LOCATION/maven" >>/etc/profile
    echo "======install completed jdk version-no:$JDK11_VERSION======"
    sleep 1s
}

nodejs_install(){
    echo "======start install nodejs version-no:$NODEJS_VERSION======"
    sleep 1s
    cd $SOFTWARE_LOCATION
    wget http://$SERVER/$NODEJS_PACAGE
    tar xf $NODEJS_PACAGE 
    sudo cp -r $NODEJS_VERSION $ENVIRONMENT_LOCATION
    cd $ENVIRONMENT_LOCATION
    sudo mv $NODEJS_VERSION nodejs
    echo "export NODE_HOME=$ENVIRONMENT_LOCATION/nodejs" >>/etc/profile
    echo "export NODE_PATH=\$NODE_HOME/lib/node_modules" >>/etc/profile
}



#修改时区上海
timedatectl set-timezone Asia/Shanghai
sudo mkdir $ENVIRONMENT_LOCATION
sudo mkdir $MAVEN_localRepository
sudo chmod 777 $MAVEN_localRepository
mkdir $SOFTWARE_LOCATION
mkdir -p $GOWORKSPACE_LOCATION
mkdir -p $JAVAWORKSPACE_LOCATION
mkdir -p $PYTHONWORKSPACE_LOCATION
mkdir -p $WEBFRONTWORKSPACE_LOCATION
sudo cp /etc/profile /etc/profile.bak
sudo chmod 777 /etc/profile
#更新
sudo apt-get update -y
#升级
sudo apt-get upgrade -y
sudo apt-get -y install curl wget
#ssh免密登录
publicKey_ssh_copy_id
#pypi安装 换源
pip_install
#golang安装
golang_install
#jdk安装 maven安装 换源
# jdk8_install
jdk11_install
#nodejs安装 npm换源
nodejs_install
echo $PATHEND >> /etc/profile
#PATH变量添加后执行
echo "======npm change ali source======"
npm config set registry http://registry.npm.taobao.org
npm config get registry
#docker-ce安装 换源
docker_install
# Step 5: 添加当前用户到docker组
echo "======add user to docker group ======"
sudo gpasswd -a $USER docker 
newgrp docker
#docker Mysql redis安装
# dockerContainer_install
