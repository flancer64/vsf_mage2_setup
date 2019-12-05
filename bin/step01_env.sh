#!/usr/bin/env/bash
## ************************************************************************
#     Script to setup empty Exoscale Cloud host
#     (Linux Ubuntu 18.04 LTS 64-bit /4 GB, 2 x 2198 MHz, 10 GB disk/)
#     Upgrade OS, install required services and run it, clone application
#     sources.
## ************************************************************************
# root directory (set before or relative to the current shell script)
DIR_ROOT=${DIR_ROOT:=$(cd "$(dirname "$0")/../" && pwd)}
#  Exit immediately if a command exits with a non-zero status.
set -e

echo "========================================================================"
echo "Update current packages and install new ones."
echo "========================================================================"
#     nodejs & yarn
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
sudo add-apt-repository "deb https://dl.yarnpkg.com/debian/ stable main"
#     Elasticsearch
curl -sL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
# use ElasticSearch v5.x
# (see https://github.com/DivanteLtd/vue-storefront-api/blob/master/docker/elasticsearch/Dockerfile)
#echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-5.x.list
# use Elasticsearch 7.x
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list

# Upgrade current packages and install new:
sudo apt update
sleep 2 # wait 2 second before upgrade to prevent en error
sudo apt upgrade -y
# https://unix.stackexchange.com/a/22876/240544
export DEBIAN_FRONTEND="noninteractive"
sudo apt install -q -y nodejs yarn openjdk-11-jre-headless elasticsearch=7.3.2 redis-server
sudo npm install pm2@latest -g

# Change file permissions on user's home (`.confiig` folder is created under root permissions`)
sudo chown -R "${USER}" ~

echo "========================================================================"
echo "Configure services and apps."
echo "========================================================================"
sudo cp /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml.orig
cat <<EOM | sudo tee /etc/elasticsearch/elasticsearch.yml
cluster.name: vsf
node.name: exo01
network.host: 0.0.0.0
discovery.seed_hosts: []
path.data: /var/lib/elasticsearch
path.logs: /var/log/elasticsearch
EOM

sudo cp /etc/redis/redis.conf /etc/redis/redis.conf.orig
cat <<EOM | sudo tee /etc/redis/redis.conf
# this config is composed from './redis.conf.orig'
bind 0.0.0.0
port 6379
tcp-backlog 511
timeout 0
tcp-keepalive 300
daemonize yes
supervised no
pidfile /var/run/redis/redis-server.pid
loglevel notice
logfile /var/log/redis/redis-server.log
databases 16
EOM

echo "========================================================================"
echo "Setup autostart for services."
echo "========================================================================"
sudo systemctl enable elasticsearch
sudo systemctl enable redis-server

echo "========================================================================"
echo "Start services."
echo "========================================================================"
sudo service elasticsearch start
sudo service redis-server start