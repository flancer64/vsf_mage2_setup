#!/usr/bin/env/bash
## ************************************************************************
#     Script to configure and build 'vue-storefront-api' app.
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

echo "========================================================================"
echo "Clone 'vue-storefront-api' application."
echo "========================================================================"
cd ~
git clone -b "release/v1.11-rc1" https://github.com/DivanteLtd/vue-storefront-api.git

echo "========================================================================"
echo "Configure 'vue-storefront-api' application."
echo "========================================================================"
cat <<EOM | tee ~/vue-storefront-api/config/local.json
{
  "server": {
    "host": "0.0.0.0",
    "port": 8080
  },
  "elasticsearch": {
    "host": "localhost",
    "port": 9200,
    "apiVersion": "7.1"
  },
  "redis": {
    "host": "localhost",
    "port": 6379
  },
  "magento2": {
    "imgUrl": "${URL_MAGE_IMG}",
    "assetPath": "/../var/magento2-sample-data/pub/media",
    "api": {
      "url": "${URL_MAGE_REST}",
      "consumerKey": "${MAGE_CONSUMER_KEY}",
      "consumerSecret": "${MAGE_CONSUMER_SECRET}",
      "accessToken": "${MAGE_ACCESS_TOKEN}",
      "accessTokenSecret": "${MAGE_ACCESS_TOKEN_SECRET}"
    }
  },
  "imageable": {
    "whitelist": {
      "allowedHosts": [
        ".*biobox.eco"
      ]
    }
  }
}
EOM

echo "========================================================================"
echo "Build & start 'vue-storefront-api' application."
echo "========================================================================"
cd ~/vue-storefront-api
yarn install
yarn build
yarn start
