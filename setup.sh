#!/bin/bash

echo "[TASK 1] Disable and turn off SWAP"
sed -i '/swap/d' /etc/fstab
swapoff -a

echo "[TASK 2] Stop and Disable firewall"
systemctl disable --now ufw >/dev/null 2>&1

echo "[TASK 3] Change source and update"
sed -i "s@http://.*archive.ubuntu.com@https://mirrors.aliyun.com@g" /etc/apt/sources.list
sed -i "s@http://.*security.ubuntu.com@https://mirrors.aliyun.com@g" /etc/apt/sources.list
apt-get update -y && apt-get upgrade -y >/dev/null 2>&1
mkdir -p /home/vagrant/environment
echo "[TASK 4] Download go and jdk"
# wget https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-x86_64.sh 
wget https://studygolang.com/dl/golang/go1.18.6.linux-amd64.tar.gz 
wget https://download.java.net/openjdk/jdk17/ri/openjdk-17+35_linux-x64_bin.tar.gz 
wget https://nodejs.org/dist/v16.17.1/node-v16.17.1-linux-x64.tar.xz 

tar -zxf go1.18.6.linux-amd64.tar.gz -C /home/vagrant/environment 
tar -zxf openjdk-17+35_linux-x64_bin.tar.gz -C /home/vagrant/environment 
tar -xf node-v16.17.1-linux-x64.tar.xz -C /home/vagrant/environment 
echo "export GO_HOME=/home/vagrant/environment/go" >>/etc/profile
echo "export GO111MODULE=on" >>/etc/profile
echo "export GOSUMDB=off" >>/etc/profile
echo "export GOPROXY=https://mirrors.aliyun.com/goproxy/" >>/etc/profile
echo "export JAVA_HOME=/home/vagrant/environment/jdk-17" >>/etc/profile
echo "export CLASSPATH=.:\${JAVA_HOME}/lib" >>/etc/profile
echo "export PATH=\${GO_HOME}/bin:\${JAVA_HOME}/bin:/home/vagrant/environment/node-v16.17.1-linux-x64/bin:\${PATH}" >>/etc/profile
source /etc/profile
echo "[TASK 5] Change conda proxy and pip proxy and npm"
mkdir /home/vagrant/.pip
echo "[global]
index-url = https://mirrors.aliyun.com/pypi/simple/
[install]
trusted-host=mirrors.aliyun.com" >> /home/vagrant/.pip/pip.conf
npm config set registy https://registry.npm.taobao.org
echo "channels:
  - defaults
show_channel_urls: true
default_channels:
  - http://mirrors.aliyun.com/anaconda/pkgs/main
  - http://mirrors.aliyun.com/anaconda/pkgs/r
  - http://mirrors.aliyun.com/anaconda/pkgs/msys2
custom_channels:
  conda-forge: http://mirrors.aliyun.com/anaconda/cloud
  msys2: http://mirrors.aliyun.com/anaconda/cloud
  bioconda: http://mirrors.aliyun.com/anaconda/cloud
  menpo: http://mirrors.aliyun.com/anaconda/cloud
  pytorch: http://mirrors.aliyun.com/anaconda/cloud
  simpleitk: http://mirrors.aliyun.com/anaconda/cloud"  >> /home/vagrant/.condarc