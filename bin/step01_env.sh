#!/usr/bin/env/bash
## ************************************************************************
#     Script to setup empty Exoscale Cloud host
#     (Linux Ubuntu 18.04 LTS 64-bit /4 GB, 2 x 2198 MHz, 10 GB disk/)
#     Upgrade OS, install required services and run it, clone application
#     sources.
## ************************************************************************
# shellcheck disable=SC1090
# root directory (set before or relative to the current shell script)
DIR_ROOT=${DIR_ROOT:=$(cd "$(dirname "$0")/../" && pwd)}
#  Exit immediately if a command exits with a non-zero status.
set -e

echo "========================================================================"
echo "Read local configuration."
echo "========================================================================"
. "${DIR_ROOT}/cfg.local.sh"
# check external vars used in this script (see cfg.[work|live].sh)
: "${REDIS_HOST:?}"
: "${REDIS_HOST:?}"
: "${VSF_API_SERVER_IP:?}"
: "${VSF_API_SERVER_PORT:?}"
: "${VSF_API_WEB_HOST:?}"
: "${VSF_FRONT_SERVER_IP:?}"
: "${VSF_FRONT_SERVER_PORT:?}"
: "${VSF_FRONT_WEB_HOST:?}"

echo "========================================================================"
echo "Update current packages and install new ones."
echo "========================================================================"
#     nodejs & yarn
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
sudo add-apt-repository "deb https://dl.yarnpkg.com/debian/ stable main"
#     Elasticsearch
curl -sL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
# use Elasticsearch 7.x
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list

# Upgrade current packages and install new:
sudo apt update
echo "Remove 'apt' lock files to prevent error 'Could not get lock ...'"
sudo rm -f /var/cache/apt/archives/lock
sudo rm -f /var/lib/apt/lists/lock
sudo rm -f /var/lib/dpkg/lock*

echo "Upgrades all installed packages."
sudo apt upgrade -y

echo "Install new packages."
# https://unix.stackexchange.com/a/22876/240544
export DEBIAN_FRONTEND="noninteractive"
sudo apt install -q -y nodejs yarn openjdk-11-jre-headless elasticsearch=7.3.2 redis-server apache2
sudo npm install pm2@^2.10.4 -g # should be a certain version

# Change file permissions on user's home (`.confiig` folder is created under root permissions`)
sudo chown -R "${USER}" ~

echo "========================================================================"
echo "Configure Elasticsearch."
echo "========================================================================"
sudo cp /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml.orig
cat <<EOM | sudo tee /etc/elasticsearch/elasticsearch.yml
# config for Elasticsearch v7.3.2
# dedicated master-eligible node: https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-node.html
cluster.name: vsf
cluster.remote.connect: false
discovery.seed_hosts: []
discovery.type: single-node
http.cors.allow-credentials: true
http.cors.allow-headers: "X-Requested-With, Content-Type, Content-Length, X-User"
http.cors.allow-methods: OPTIONS, HEAD, GET, POST, PUT, DELETE
http.cors.allow-origin: "*"
http.cors.enabled: true
network.host: 0.0.0.0
node.data: true
node.ingest: true
node.master: true
node.ml: true
node.name: exo01
node.voting_only: false
path.data: /var/lib/elasticsearch
path.logs: /var/log/elasticsearch
xpack.ml.enabled: true
EOM

echo "========================================================================"
echo "Configure Redis."
echo "========================================================================"
sudo cp /etc/redis/redis.conf /etc/redis/redis.conf.orig
cat <<EOM | sudo tee /etc/redis/redis.conf
# this config is composed from './redis.conf.orig'
bind ${REDIS_HOST}
port ${REDIS_PORT}
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
echo "Configure Apache."
echo "========================================================================"
echo "Add virtual hosts to local DNS."
echo "127.0.0.1 front.vsf.demo.com api.vsf.demo.com" | sudo tee -a /etc/hosts > /dev/null
echo "Add virtual host config for frontend server"
cat <<EOM | sudo tee /etc/apache2/sites-enabled/vsf.front.conf > /dev/null
<VirtualHost *:80>
    ServerName ${VSF_FRONT_WEB_HOST}
    ProxyPreserveHost On
    ProxyPass / http://${VSF_FRONT_SERVER_IP}:${VSF_FRONT_SERVER_PORT}/
    ProxyPassReverse / http://${VSF_FRONT_SERVER_IP}:${VSF_FRONT_SERVER_PORT}/
    LogLevel info
    CustomLog ${APACHE_LOG_DIR}/vsf.front_access.log combined
    ErrorLog ${APACHE_LOG_DIR}/vsf.front_error.log
</VirtualHost>
EOM
echo "Add virtual host config for API server"
cat <<EOM | sudo tee /etc/apache2/sites-enabled/api.front.conf > /dev/null
<VirtualHost *:80>
    ServerName ${VSF_API_WEB_HOST}
    ProxyPreserveHost On
    ProxyPass / http://${VSF_API_SERVER_IP}:${VSF_API_SERVER_PORT}/
    ProxyPassReverse / http://${VSF_API_SERVER_IP}:${VSF_API_SERVER_PORT}/
    LogLevel info
    CustomLog ${APACHE_LOG_DIR}/vsf.api_access.log combined
    ErrorLog ${APACHE_LOG_DIR}/vsf.api_error.log
</VirtualHost>
EOM

echo "========================================================================"
echo "Setup autostart for services."
echo "========================================================================"
sudo systemctl enable elasticsearch
sudo systemctl enable redis-server
sudo systemctl enable apache2

echo "========================================================================"
echo "Start services."
echo "========================================================================"
sudo service elasticsearch restart
sudo service redis-server restart
sudo service apache2 restart

echo "========================================================================"
echo "Process is completed."
echo "========================================================================"
