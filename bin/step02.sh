#!/usr/bin/env/bash
## ************************************************************************
#     Script to configure and build 'mage2vuestorefront' app.
## ************************************************************************
# shellcheck disable=SC1090
# root directory (set before or relative to the current shell script)
DIR_ROOT=${DIR_ROOT:=$(cd "$(dirname "$0")/../" && pwd)}
#  Exit immediately if a command exits with a non-zero status.
set -e

## ========================================================================
# Configuration variables
## ========================================================================
. "${DIR_ROOT}/cfg.local.sh" # this script is child of other script

## ========================================================================
# Install `mage2vsf` app.
## ========================================================================
cd ~/mage2vuestorefront/src
npm install

## ========================================================================
# Create launch script to run all sync tasks.
## ========================================================================
cat <<EOM | tee ~/mage2vuestorefront/src/run.sh
#!/usr/bin/env/bash
#  Exit immediately if a command exits with a non-zero status.
set -e

export TIME_TO_EXIT="2000"

# Setup connection to Magento
export MAGENTO_CONSUMER_KEY="${MAGE_CONSUMER_KEY}"
export MAGENTO_CONSUMER_SECRET="${MAGE_CONSUMER_SECRET}"
export MAGENTO_ACCESS_TOKEN="${MAGE_ACCESS_TOKEN}"
export MAGENTO_ACCESS_TOKEN_SECRET="${MAGE_ACCESS_TOKEN_SECRET}"

# Setup default store
export MAGENTO_URL="${URL_MAGE_REST}"
export INDEX_NAME="${INDEX_NAME}"

# Perform data replications
node --harmony cli.js taxrule --removeNonExistent=true
node --harmony cli.js attributes --removeNonExistent=true
node --harmony cli.js categories --removeNonExistent=true
node --harmony cli.js productcategories #--partitions=2
node --harmony cli.js products --removeNonExistent=true #--partitions=2

#cd ~/vue-storefront-api
#npm run db new -- --indexName=${INDEX_NAME}
EOM
