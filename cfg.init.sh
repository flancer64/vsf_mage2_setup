#!/usr/bin/env bash
# =========================================================================
#   Local configuration template.
#   Copy this file to `./cfg.local.sh`.
# =========================================================================
export HOST_VSF="255.255.255.255"   # ip address or domain name for VSF host (VSF Front/API, Elasticsearch & Redis)
export HOST_MAGE="mage2.host.com"   # ip address or domain name for Magento 2 host
# address of REST API of source Magento instance
export URL_MAGE_REST="http://${URL_MAGE}/rest"
export URL_MAGE_IMG="http://${URL_MAGE}/media/catalog/product"
export INDEX_NAME="vue_storefront_catalog"
# Magento integration options
# see: "How to integrate Magento2 with your local instance?"
# at: https://medium.com/the-vue-storefront-journal/vue-storefront-how-to-install-and-integrate-with-magento2-227767dd65b2
export MAGE_CONSUMER_KEY="..."
export MAGE_CONSUMER_SECRET="..."
export MAGE_ACCESS_TOKEN="..."
export MAGE_ACCESS_TOKEN_SECRET="..."
export MAGE_CURRENCY_CODE="..."
