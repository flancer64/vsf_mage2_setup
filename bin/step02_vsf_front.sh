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

echo "========================================================================"
echo "Clone 'vue-storefront' application."
echo "========================================================================"
cd ~
git clone -b "release/v1.11.0" https://github.com/DivanteLtd/vue-storefront.git

echo "========================================================================"
echo "Configure 'vue-storefront' application."
echo "========================================================================"
cat <<EOM | tee ~/vue-storefront/config/local.json
{
  "server": {
    "host": "0.0.0.0",
    "port": 3000
  },
  "redis": {
    "host": "${HOST_VSF}",
    "port": 6379,
    "db": 0
  },
  "graphql": {
    "host": "${HOST_VSF}",
    "port": 8080
  },
  "api": {
    "url": "http://${HOST_VSF}:8080"
  },
  "elasticsearch": {
    "indices": [
      "${INDEX_NAME}"
    ]
  },
  "images": {
    "useExactUrlsNoProxy": false,
    "baseUrl": "http://${HOST_VSF}:8080/img/",
    "productPlaceholder": "/assets/placeholder.jpg"
  },
  "i18n": {
    "defaultCountry": "RU",
    "defaultLanguage": "RU",
    "availableLocale": ["ru-RU"],
    "defaultLocale": "ru-RU",
    "currencyCode": "${MAGE_CURRENCY_CODE}",
    "currencySign": "₽",
    "currencySignPlacement": "preppend",
    "dateFormat": "l LT",
    "fullCountryName": "Russian Federation",
    "fullLanguageName": "Russian",
    "bundleAllStoreviewLanguages": true
  }
}
EOM

echo "========================================================================"
echo "Build & start 'vue-storefront' application."
echo "========================================================================"
cd ~/vue-storefront
yarn install
yarn build
yarn start

echo "========================================================================"
echo "Process is completed."
echo "========================================================================"