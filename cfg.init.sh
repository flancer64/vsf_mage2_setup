#!/usr/bin/env bash
# =========================================================================
#   Deployment configuration template. Copy this file to `cfg.local.sh`.
# =========================================================================
# VSF Server (contains Front/API servers, Elasticsearch & Redis services)
export HOST_VSF="255.255.255.255"
# address of REST API of source Magento instance
export URL_MAGE="http://mage2.host.com"
export URL_MAGE_REST="${URL_MAGE}/rest"
export URL_MAGE_IMG="${URL_MAGE}/media/catalog/product/cache/"
export INDEX_NAME="vue_storefront_catalog"
# Magento integration options
export MAGE_CONSUMER_KEY="..."
export MAGE_CONSUMER_SECRET="..."
export MAGE_ACCESS_TOKEN="..."
export MAGE_ACCESS_TOKEN_SECRET="..."
export MAGE_CURRENCY_CODE="..."
