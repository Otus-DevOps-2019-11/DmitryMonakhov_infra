# DmitryMonakhov_infra
DmitryMonakhov Infra repository

## homework#08 terraform-1
### Практика IaC с использованием Terraform
Изучение принципов работы с terraform:
- ```terraform plan``` - планирование изменений ресурсов относительно текущего состояния, зафиксированного в tfstate-файле;
- ```terraform validate``` - проверка синтаксиса конфигурационных файлов;
- ```terraform fmt``` - форматирование конфигурационных файлов;
- ```terraform apply``` - собственно создание ресурсов;
- ```terraform output``` - просмотр выходных переменных;
- ```terraform.tfvars``` - параметризация конфигурационных файлов с помощью входных переменных, определяемых в в файлах с расширением ```.tf```;
- установка приложения внутри инстанса VM с помощью провижнеров типа ```file``` и ```remote-exec```, подключающихся по ssh;
- добавление ssh-ключей в метаданные проекта GCP с помощью ```google_compute_project_metadata_item```. Внимание: любые другие ssh-ключи, добавленные вручную в интерфейсе GCP, будут удалены при применении ```terraform apply```.
При выполнении ```terraform apply``` будет создан инстанс VM на базе образа reddit-base с описанием ```main.tf```, правило для firewall  и переменными, указанными в ```variables.tf```.

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
