# vsf_mage2_setup
Set of scripts to automate binding of Vue Storefront PWA with Magento 2 backend. 

**Attention: this project is not ready to use, it is under development yet.**

## Setup on standalone host

Host under `Linux Ubuntu 18.04 LTS 64-bit` is used in development.

There are 3 steps for now:

1. [Step 01](./bin/step01.sh): upgrade OS and install additional services (Elasticsearch, Redis, node, yarn, ...).
1. [Step 02](./bin/step02.sh): install and configure [mage2vuestorefront](https://github.com/DivanteLtd/mage2vuestorefront) app to transfer Magento 2 data to Elasticsearch DB.
1. [Step 03](./bin/step03.sh): install and configure [vue-storefront](https://github.com/DivanteLtd/vue-storefront) and [vue-storefront-api](https://github.com/DivanteLtd/vue-storefront-api) apps.


```
$ git clone https://github.com/flancer64/vsf_mage2_setup.git
$ cd ./vsf_mage2_setup
$ bash ./bin/step01.sh
```