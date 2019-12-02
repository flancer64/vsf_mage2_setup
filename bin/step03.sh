#!/usr/bin/env/bash
## ************************************************************************
#     Script to configure and build 'vsf' * 'vsf-api' apps.
## ************************************************************************
# root directory (set before or relative to the current shell script)
DIR_ROOT=${DIR_ROOT:=$(cd "$(dirname "$0")/../" && pwd)}
#  Exit immediately if a command exits with a non-zero status.
set -e

## ========================================================================
# Configuration variables.
## ========================================================================
# VSF Server (contains Front/API servers, Elasticsearch & Redis services)
HOST_VSF="x.x.x.x"
# address of REST API of source Magento instance
URL_MAGE="http://mage2.host.com"
URL_MAGE_REST="${URL_MAGE}/rest"
URL_MAGE_IMG="${URL_MAGE}/media/catalog/product/cache/"
INDEX_NAME="vue_storefront_catalog"
# Magento integration options
MAGE_CONSUMER_KEY="..."
MAGE_CONSUMER_SECRET="..."
MAGE_ACCESS_TOKEN="..."
MAGE_ACCESS_TOKEN_SECRET="..."

## ========================================================================
# Configure apps.
## ========================================================================
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
    "baseUrl": "${URL_MAGE_IMG}",
    "productPlaceholder": "/assets/placeholder.jpg"
  }
}
EOM

cat <<EOM | tee ~/vue-storefront-api/config/local.json
{
  "server": {
    "host": "0.0.0.0",
    "port": 8080
  },
  "elasticsearch": {
    "host": "localhost",
    "port": 9200
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
  }
}
EOM

## ========================================================================
# Build apps.
## ========================================================================
cd ~/vue-storefront && yarn install && yarn build
cd ~/vue-storefront-api && yarn install && yarn build

## ========================================================================
# Rebuild indexes and get data from Elasticsearch.
## ========================================================================
cd ~/vue-storefront-api
rm -f ./var/catalog.json
npm run dump
npm run db rebuild -- --indexName=${INDEX_NAME}

## ========================================================================
# Start services and apps.
## ========================================================================
cd ~/vue-storefront && yarn start
cd ~/vue-storefront-api && yarn start
