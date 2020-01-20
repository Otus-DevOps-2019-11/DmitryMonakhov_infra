# DmitryMonakhov_infra
DmitryMonakhov Infra repository

## homework#09 terraform-2
### Принципы организации инфраструктурного кода и работа над инфраструктурой в команде на примере Terraform
Для обеспечения возможности управления доступом к инстансам по протоколу ssh с помощью terraform производится импорт существующего ресурса - правила firewall в terraform.state `terraform import google_compute_firewall.firewall_ssh default-allow-ssh`
С помощью packer подготовливаются образы reddit-base-db и reddit-base-app:
`packer build -var-file=variables.json app.json`
`packer build -var-file=variables.json db.json`
Для развертывания инстансов приложения и базы данных подготавливаются конфигурационные файлы `app.tf` и `db.tf`
Для обеспечения переиспользования кода создаются модули terraform: app, db и vpc
С использованием модулей app, db, vpc подготавливается инфраструктура для окружений `prod` и `stage`
Для хранение состояния инфраструктуры terraform в Google Cloud Storage используется модуль `storage-bucket`
Конфигурация реестра модулей описывается в файле `storage-bucket.tf`
Подключение бэкенда Google Cloud Storage производится с помощью конфигурационного файла `backend.tf`
Проверить созданный bucket можно с помощью утилиты `gsutil ls`

## homework#08 terraform-1
### Практика IaC с использованием Terraform
Изучение принципов работы с terraform:
- ```terraform plan``` - планирование изменений ресурсов относительно текущего состояния, зафиксированного в tfstate-файле;
- ```terraform validate``` - проверка синтаксиса конфигурационных файлов;
- ```terraform fmt``` - форматирование конфигурационных файлов;
- ```terraform apply``` - собственно создание ресурсов;
- ```terraform output``` - просмотр выходных переменных;
- ```terraform.tfvars``` - параметризация конфигурационных файлов с помощью входных переменных, определяемыхв в файлах с раширением ```.tf```;
- установка приложения внутри инстанса VM с помощью провижнеров типа ```file``` и ```remote-exec```, подключающихся по ssh;
- добавление ssh-ключей в метаданные проекта GCP с помощью ```google_compute_project_metadata_item```. Любые другие ssh-ключи, добавленные вручную в интерфейсе GCP, будут удалены при применении ```terraform apply```.

## homework#07 packer-base
### Работа с образами VM в облаке. Знакомство с Packer и экосистемой компании HashiCorp
Подготовка образа для развертывания VM instance reddit-base:
```
$ packer build -var-file=variables.json ubuntu16.json
```
Файл ubuntu16.json исключить из индекса git.
Выполнить создание GCP VM instance на базе образа reddit-base:
- Step 1. Create GCP VM Instance
```
$ gcloud compute instances create reddit-app \
--image-family reddit-base \
--machine-type=g1-small \
--boot-disk-size=10GB \
--tags puma-server \
--restart-on-failure
```
- Step 2. Create firewall rule
```
$ gcloud compute firewall-rules create default-puma-server \
--allow tcp:9292 \
--target-tags=puma-server \
--source-ranges 0.0.0.0/0
```
или использовать скрипт запуска GCP VM instance из образа reddit-base - config-scripts/create-reddit-app.sh.

## homework#06 cloud-testapp
### Способы управления ресурсами в GCP
Settings from homework#05:
```
bastion_IP = 35.228.94.43
someinternalhost_IP = 10.166.0.9
```
App settings
```
testapp_IP = 34.66.35.100
testapp_port = 9292
```
Create GCP VM instance:
```
gcloud compute instances create reddit-app \
	--boot-disk-size=10GB \
	--image-family ubuntu-1604-lts \
	--image-project=ubuntu-os-cloud \
	--machine-type=g1-small \
	--tags puma-server \
	--restart-on-failure \
	--metadata-from-file startup-script=startup-script.sh
```
Create firewall rule:
```
gcloud compute firewall-rules create default-puma-server --allow tcp:9292 --target-tags 'puma-server' --source-ranges 0.0.0.0/0
```
For install packages and deploy app use install scripts in appuser home directory:
```
$ cd ~
$ install_ruby.sh
$ install_mongodb.sh
$ deploy.sh
```

## homework#05 cloud-bastion
### Практики безопасного доступа к ресурсам (SSH, Bastion Host, VPN)
Connect to ssh internal host (someinternalhost) through external host (bastion)
Fisrt way: Oneline command connect to someinternalhost through bastionhost:
```
$ ssh -i ~/.ssh/appuser -t -A appuser@35.228.94.43 ssh -A appuser@10.166.0.9
```
Second way: add next lines to ~/.ssh/config:
```
Host bastion
Hostname 35.228.94.43
User appuser
IdentityFile ~/.ssh/appuser
ForwardAgent Yes
Host someinternalhost
Hostname 10.166.0.9
User appuser
ProxyCommand ssh -q bastion nc -q0 someinternalhost 22
```
then run:
```
$ ssh someinternalhost
```
Options for VPN connection:
```
bastion_IP = 35.228.94.43
someinternalhost_IP = 10.166.0.9
```
Configure VPN server for use Let's Encript sertificate:
Add fqdn "35.228.94.43.sslip.io" at pritunl server's settings
