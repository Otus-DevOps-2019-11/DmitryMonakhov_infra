# DmitryMonakhov_infra
DmitryMonakhov Infra repository

Подготовка образа для развертывания VM instance reddit-base:
```sh
$ packer build -var-file=variables.json ubuntu16.json
```
Файл ubuntu16.json исключить из индекса git.
Выполнить создание GCP VM instance на базе образа reddit-base:
- Step 1. Create GCP VM Instance
```sh
$ gcloud compute instances create reddit-app \
--image-family reddit-base \
--machine-type=g1-small \
--boot-disk-size=10GB \
--tags puma-server \
--restart-on-failure
```
- Step 2. Create firewall rule
```sh
$ gcloud compute firewall-rules create default-puma-server \
--allow tcp:9292 \
--target-tags=puma-server \
--source-ranges 0.0.0.0/0
```
или использовать скрипт запуска GCP VM instance из образа reddit-base - config-scripts/create-reddit-app.sh.
