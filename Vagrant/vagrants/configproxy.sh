#!/bin/bash
## Author: Azher Khan
## This script is created to configure the proxy into the system
## and set the vi editor mode
sudo su -
echo "Acquire::http::Proxy "http://web-proxy.cup.hp.com:8080";" > /etc/apt/apt.conf.d/01proxy
echo "set -o vi" >> /etc/bash.bashrc
source /etc/bash.bashrc
mkdir -p ~/.pip/ 
echo -e "[global]\nproxy = http://web-proxy.cup.hp.com:8080" >> ~/.pip/pip.conf
