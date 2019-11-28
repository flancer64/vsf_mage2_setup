#!/usr/bin/env/bash
## ************************************************************************
#     Script to configure and build 'mage2vuestorefront' app.
## ************************************************************************
#  Exit immediately if a command exits with a non-zero status.
set -e

## ========================================================================
# Configuration variables
## ========================================================================
# address of REST API of source Magento instance
URL_MAGE="http://mage2.host.com"
URL_MAGE_REST="${URL_MAGE}/rest"
INDEX_NAME="vue_storefront_catalog"
# Magento integration options
MAGE_CONSUMER_KEY="..."
MAGE_CONSUMER_SECRET="..."
MAGE_ACCESS_TOKEN="..."
MAGE_ACCESS_TOKEN_SECRET="..."

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
