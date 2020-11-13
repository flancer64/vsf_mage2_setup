#!/usr/bin/env/bash
## ************************************************************************
#     Script to configure and build 'mage2vuestorefront' app.
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
DIR_M2V="${DIR_APPS}/mage2vuestorefront"

echo "========================================================================"
echo "Clone 'mage2vuestorefront' application."
echo "========================================================================"
git clone https://github.com/DivanteLtd/mage2vuestorefront.git "${DIR_M2V}"
cd "${DIR_M2V}" || exit 255
#git checkout "feature/es7"

echo "========================================================================"
echo "Build 'mage2vuestorefront' application."
echo "========================================================================"
yarn install

echo "========================================================================"
echo "Create launch script to run all sync tasks."
echo "========================================================================"
cat <<EOM | tee "${DIR_M2V}/replicate.sh" >/dev/null
#!/bin/bash
#  Exit immediately if a command exits with a non-zero status.
set -e
ROOT=\$(cd "\$(dirname "\$0")/" && pwd)
M2V_CLI="\${ROOT}/src/cli.js"

export TIME_TO_EXIT="2000"

# Setup connection to Elasticsearch
export ELASTICSEARCH_API_VERSION="7.5"
export DATABASE_URL="${ES_URL}"

# Setup connection to Magento
export MAGENTO_CONSUMER_KEY="${MAGE_API_CONSUMER_KEY}"
export MAGENTO_CONSUMER_SECRET="${MAGE_API_CONSUMER_SECRET}"
export MAGENTO_ACCESS_TOKEN="${MAGE_API_ACCESS_TOKEN}"
export MAGENTO_ACCESS_TOKEN_SECRET="${MAGE_API_ACCESS_TOKEN_SECRET}"
export MAGENTO_URL="${MAGE_URL_REST}"

# Setup default store
export INDEX_NAME="${ES_INDEX_NAME}"

# Perform data replications
node --harmony "\${M2V_CLI}" taxrule --removeNonExistent=true
node --harmony "\${M2V_CLI}" attributes --removeNonExistent=true
node --harmony "\${M2V_CLI}" categories --removeNonExistent=true
node --harmony "\${M2V_CLI}" productcategories
node --harmony "\${M2V_CLI}" products --removeNonExistent=true
EOM

# set 'executable' permissions to the script.
chmod ug+x "${DIR_M2V}/replicate.sh"

echo "========================================================================"
echo "Process is completed."
echo "========================================================================"
