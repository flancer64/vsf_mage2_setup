#!/usr/bin/env/bash
## ************************************************************************
#     Script to configure and build 'vue-storefront' app.
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
: "${ES_INDEX_NAME=:?}"
: "${REDIS_DB:?}"
: "${REDIS_HOST:?}"
: "${REDIS_PORT:?}"
: "${VSF_API_SERVER_IP:?}"
: "${VSF_API_SERVER_PORT:?}"
: "${VSF_API_WEB_HOST:?}"
: "${VSF_API_WEB_PROTOCOL:?}"
: "${VSF_FRONT_SERVER_IP:?}"
: "${VSF_FRONT_SERVER_PORT:?}"
: "${VSF_FRONT_WEB_HOST:?}"
: "${VSF_FRONT_WEB_PROTOCOL:?}"
# local context vars
DIR_APPS="/home/${USER}"
DIR_VSF="${DIR_APPS}/vue-storefront"

echo "========================================================================"
echo "Clone 'vue-storefront' application."
echo "========================================================================"
cd "${DIR_APPS}" || exit 255
git clone https://github.com/DivanteLtd/vue-storefront.git "${DIR_VSF}"

echo "========================================================================"
echo "Configure 'vue-storefront' application."
echo "========================================================================"
cd "${DIR_VSF}" || exit 255
cat <<EOM | tee "${DIR_VSF}/config/local.json" >/dev/null
{
  "server": {
    "host": "${VSF_FRONT_SERVER_IP}",
    "port": ${VSF_FRONT_SERVER_PORT},
    "protocol": "http"
  },
  "redis": {
    "host": "${REDIS_HOST}",
    "port": ${REDIS_PORT},
    "db": ${REDIS_DB}
  },
  "api": {
    "url": "${VSF_API_WEB_PROTOCOL}://${VSF_API_WEB_HOST}"
  },
  "elasticsearch": {
    "index": "${ES_INDEX_NAME}",
    "indices": [
      "${ES_INDEX_NAME}"
    ]
  },
  "images": {
    "useExactUrlsNoProxy": false,
    "baseUrl": "${VSF_API_WEB_PROTOCOL}://${VSF_API_WEB_HOST}/img/",
    "productPlaceholder": "/assets/placeholder.jpg"
  },
  "install": {
    "is_local_backend": true
  },
  "tax": {
    "defaultCountry": "LV"
  },
  "i18n": {
    "defaultCountry": "LV",
    "defaultLanguage": "EN",
    "availableLocale": ["en-US"],
    "defaultLocale": "en-US",
    "currencyCode": "EUR",
    "currencySign": "€",
    "currencySignPlacement": "preppend",
    "dateFormat": "l LT",
    "fullCountryName": "Latvian Republic",
    "fullLanguageName": "Latvia",
    "bundleAllStoreviewLanguages": true
  }
}
EOM

echo "========================================================================"
echo "Install 'capybara' theme."
echo "========================================================================"
cd "${DIR_VSF}"
git submodule add -b master https://github.com/DivanteLtd/vsf-capybara.git src/themes/capybara
git submodule update --init --remote
node src/themes/capybara/scripts/generate-local-config.js
sed -i 's/themes\/default/themes\/capybara/' tsconfig.json
lerna bootstrap

echo "========================================================================"
echo "Build & start 'vue-storefront' application."
echo "========================================================================"
cd "${DIR_VSF}"
yarn install
yarn build
yarn start

echo "========================================================================"
echo "Process is completed."
echo "========================================================================"
