#!/usr/bin/env/bash
## ************************************************************************
#     Script to synchronize data between Magento2 and VSF.
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
echo "Rebuild indexes and get data from Elasticsearch."
echo "========================================================================"
cd ~/mage2vuestorefront/src
bash run.sh


echo "========================================================================"
echo "Rebuild indexes and get data from Elasticsearch."
echo "========================================================================"
cd ~/vue-storefront-api
rm -f ./var/catalog.json
npm run dump
npm run db rebuild -- --indexName="${INDEX_NAME}"