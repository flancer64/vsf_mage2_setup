# vsf_mage2_setup
Set of scripts to automate binding of Vue Storefront PWA with Magento 2 backend. 

**Attention: this project is not ready to use, it is under development yet.**

## Setup on standalone host

Host under `Linux Ubuntu 18.04 LTS 64-bit` is used in development.

There are 5 steps for now:

1. [Step 01](./bin/step01_env.sh): upgrade OS and install additional services (Elasticsearch, Redis, node, yarn, ...).
1. [Step 02](./bin/step02_vsf_front.sh): install and configure [vue-storefront](https://github.com/DivanteLtd/vue-storefront) app. 
1. [Step 03](./bin/step03_vsf_api.sh): install and configure [vue-storefront-api](https://github.com/DivanteLtd/vue-storefront-api) app.
1. [Step 04](./bin/step04_mage2vsf.sh): install and configure [mage2vuestorefront](https://github.com/DivanteLtd/mage2vuestorefront) app to transfer Magento 2 data to Elasticsearch DB.
1. [Step 05](./bin/step05_sync_data.sh): replicate Magento 2 data to VSF (Elasticsearch).



## Usage
```
$ git clone https://github.com/flancer64/vsf_mage2_setup.git
$ cd ./vsf_mage2_setup
$ cp cfg.init.sh cfg.local.sh
$ nano cfg.local.sh
...
$ bash ./bin/step01_env.sh
$ bash ./bin/step02_vsf_front.sh
$ bash ./bin/step03_vsf_api.sh
$ bash ./bin/step04_mage2vsf.sh
$ bash ./bin/step05_sync_data.sh
```