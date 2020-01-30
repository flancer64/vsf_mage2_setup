#!/usr/bin/env bash
# =========================================================================
#   Local configuration template.
#   Copy this file to `./cfg.local.sh`.
# =========================================================================

# VSF frontend
export VSF_FRONT_SERVER_IP="127.0.0.1"
export VSF_FRONT_SERVER_PORT="3100"
export VSF_FRONT_WEB_HOST="front.vsf.demo.com"
export VSF_FRONT_WEB_PROTOCOL="http"

# VSF API
export VSF_API_SERVER_IP="127.0.0.1"
export VSF_API_SERVER_PORT="3130"
export VSF_API_WEB_HOST="api.vsf.demo.com"
export VSF_API_WEB_PROTOCOL="http"

# Redis
export REDIS_HOST="127.0.0.1"
export REDIS_PORT="6379"
export REDIS_DB="0"

# Elasticsearch
export ES_HOST="127.0.0.1"
export ES_PORT="9200"
export ES_API_VERSION="7.2"
export ES_URL="http://${ES_HOST}:${ES_PORT}"
export ES_INDEX_NAME="vue_demo"

# Magento
export MAGE_HOST="magento.demo.com"
export MAGE_URL_REST="http://${MAGE_HOST}/rest"
export MAGE_URL_IMG="http://${MAGE_HOST}/media/catalog/product"
# Magento API access
export MAGE_API_CONSUMER_KEY="87ufsjl20l5lrub7j1k041a7aoxafmvm"
export MAGE_API_CONSUMER_SECRET="7fi88hdlp3ibtfr2bwf0395xhtuvu6zu"
export MAGE_API_ACCESS_TOKEN="xxsa70xlqo3zmksy858h663p8hr19dbv"
export MAGE_API_ACCESS_TOKEN_SECRET="hmhfyxs5dkd70cna5p49g6oiju8xctk0"