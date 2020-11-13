#!/usr/bin/env/bash
## ************************************************************************
#     Script to synchronize data between Magento2 and VSF.
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
: "${ES_INDEX_NAME:?}"
: "${ES_URL:?}"
: "${MAGE_API_ACCESS_TOKEN:?}"
: "${MAGE_API_ACCESS_TOKEN_SECRET:?}"
: "${MAGE_API_CONSUMER_KEY:?}"
: "${MAGE_API_CONSUMER_SECRET:?}"
: "${MAGE_URL_REST:?}"
# local context vars
DIR_APPS="/home/${USER}"
DIR_API="${DIR_APPS}/vue-storefront-api"
DIR_M2V="${DIR_APPS}/mage2vuestorefront"

echo "========================================================================"
echo "Get data from Magento."
echo "========================================================================"
cd "${DIR_M2V}"
bash replicate.sh


echo "========================================================================"
echo "Reconfigure VSF API."
echo "========================================================================"
cd "${DIR_API}"
rm -f ./var/catalog*
npm run dump -- --input-index="${ES_INDEX_NAME}"
npm run db rebuild -- --indexName="${ES_INDEX_NAME}"

echo "========================================================================"
echo "Process is completed."
echo "========================================================================"
