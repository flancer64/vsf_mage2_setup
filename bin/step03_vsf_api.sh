#!/usr/bin/env/bash
## ************************************************************************
#     Script to configure and build 'vue-storefront-api' app.
## ************************************************************************
# shellcheck disable=SC1090
# root directory (set before or relative to the current shell script)
DIR_ROOT=${DIR_ROOT:=$(cd "$(dirname "$0")/../" && pwd)}
#  Exit immediately if a command exits with a non-zero status.
set -e -x

echo "========================================================================"
echo "Read local configuration."
echo "========================================================================"
. "${DIR_ROOT}/cfg.local.sh"
# check external vars used in this script (see cfg.[work|live].sh)
: "${ES_API_VERSION:?}"
: "${ES_HOST:?}"
: "${ES_INDEX_NAME=:?}"
: "${ES_PORT:?}"
: "${MAGE_API_ACCESS_TOKEN:?}"
: "${MAGE_API_ACCESS_TOKEN_SECRET:?}"
: "${MAGE_API_CONSUMER_KEY:?}"
: "${MAGE_API_CONSUMER_SECRET:?}"
: "${MAGE_HOST:?}"
: "${MAGE_URL_IMG:?}"
: "${MAGE_URL_REST:?}"
: "${REDIS_DB:?}"
: "${REDIS_HOST:?}"
: "${REDIS_PORT:?}"
: "${VSF_API_SERVER_IP:?}"
: "${VSF_API_SERVER_PORT:?}"
: "${VSF_API_WEB_HOST:?}"
: "${VSF_API_WEB_PROTOCOL:?}"
# local context vars
DIR_APPS="/home/${USER}"
DIR_VSF_API="${DIR_APPS}/vue-storefront-api"

echo "========================================================================"
echo "Clone 'vue-storefront-api' application."
echo "========================================================================"
cd "${DIR_APPS}" || exit 255
git clone https://github.com/DivanteLtd/vue-storefront-api.git "${DIR_VSF_API}"

echo "========================================================================"
echo "Configure 'vue-storefront-api' application."
echo "========================================================================"
cd "${DIR_VSF_API}" || exit 255
cat <<EOM | tee "${DIR_VSF_API}/config/local.json" >/dev/null
{
  "server": {
    "host": "${VSF_API_SERVER_IP}",
    "port": ${VSF_API_SERVER_PORT}
  },
  "elasticsearch": {
    "host": "${ES_HOST}",
    "port": ${ES_PORT},
    "indices": [
      "${ES_INDEX_NAME}"
    ],
    "apiVersion": "${ES_API_VERSION}"
  },
  "redis": {
    "host": "${REDIS_HOST}",
    "port": ${REDIS_PORT},
    "db": ${REDIS_DB}
  },
  "authHashSecret": "__SECRET_CHANGE_ME__",
  "objHashSecret": "__SECRET_CHANGE_ME__",
  "tax": {
    "defaultCountry": "RU"
  },
  "magento2": {
    "imgUrl": "${MAGE_URL_IMG}",
    "api": {
      "url": "${MAGE_URL_REST}",
      "consumerKey": "${MAGE_API_CONSUMER_KEY}",
      "consumerSecret": "${MAGE_API_CONSUMER_SECRET}",
      "accessToken": "${MAGE_API_ACCESS_TOKEN}",
      "accessTokenSecret": "${MAGE_API_ACCESS_TOKEN_SECRET}"
    }
  },
  "magento1": {},
  "imageable": {
    "whitelist": {
      "allowedHosts": [
        "${MAGE_HOST}"
      ]
    }
  }
}
EOM

echo "========================================================================"
echo "Build & start 'vue-storefront-api' application."
echo "========================================================================"
cd "${DIR_VSF_API}"
yarn install
yarn build
yarn start
echo "Create empty structure for Elasticsearch 7.x."
yarn db new

echo "========================================================================"
echo "Process is completed."
echo "========================================================================"
