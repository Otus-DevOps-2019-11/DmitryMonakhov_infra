# DmitryMonakhov_infra
DmitryMonakhov Infra repository

## homework#13 ansible-4
### Разработка и тестирование Ansible ролей и плейбуков
Подготовка окружения для локальной разработки с помощью `Vagrant` . Статус виртуальных машин проверяется с помощью `vagrant status`

Роли `app` и `db` доработаны для провижининга в Vagrant с помощью Ansible, например, для работающего хоста dbserver выполнить: `vagrant provision dbserver`

Плейбук `app.yml` доработан для проксирования приложения с помощью nginx

Для локального тестирования ролей Ansible использованы `Molecule` для создания виртуальных машин проверки конфигурации и `Testinfra` для подготовки тестов

Тест `test_default.py` доработан для проверки, что MongoDB принимает подключения на порту 27017: `assert socket.is_listening`

Для создания заготовки тестов использовать `molecule init scenario --scenario-name default -r db -d vagrant`. Для применения самих тестов использовать `molecule verify `

Роль `db` вынесена во внешний репозитарий `https://github.com/DmitryMonakhov/practice-db-role`, подключена для окружений `stage` и `prod` в плейбуке `requirements.yml`


## homework#12 ansible-3
### Ansible: работа с ролями и окружениями
Ключевое понятие "Роль" - основной способ группировки и переиспользования конфигурационного кода в Ansible. Рассмотрено использование `ansible-galaxy` для автоматического формирования структуры ролей `app` и `db`:
```sh
$ ansible-galaxy init app
$ ansible-galaxy init db
```

Подготовлены окружения `prod` и `stage` для управления хостами в них с помощью Ansible. Использованы переменные для группы хосты для управления и вывода информации об окружении

Реорганизовано хранение плейбуков в соответствии с best practices. Скорректированы шаблоны `app` и `db`, используемые Packer

Использована community-роль `jdauphant.nginx`  для обратного проксирования с помощью nginx для  приложения. Обеспечена доступность приложения по порту 80

Подготовлен плейбук `ansible/playbooks/users.yml` для создания пользователей, пароль которых хранится в зашифрованном виде в файле `credentials.yml` с помощью механизма Ansible Vault
```sh
$ ansible-vault encrypt environments/prod/credentials.yml
```

Настроено использование динамического инвентори для окружений `stage` и `prod` с помощью модуля `gce_compute`. Конфигурирование сервиса приложения осуществляется с помощью переменной `db_host: "{{ hostvars[groups['db'][0]]['ansible_internal_ip'] }}"`

## homework#11 ansible-2
### Деплой и управление конфигурацией с Ansible
Рассмотрены различные способы формирования плейбуков:
 1. Один плейбук, один сценарий: для указания хостов, к которым будут применяться задачи необходимо использовать опции `--limit` для указания группы хостов и `--tags` для указания нужных задач. Используемый плейбук `reddit_app.yml`, например:
```sh
$ ansible-playbook reddit_app.yml --limit app --tags app-tag
```
2. Один плейбук, несколько сценариев: для указания какие именно сценарии будут выполняться необходимо использовать только опцию `--tags`. Используемый плейбук `reddit_app2.yml`, например:
```sh
$ ansible-playbook reddit_app2.yml --tags db-tag
```
3. Отдельные плейбуки для каждого сценария: этот способ позволяет отказаться от использования опций `--limit` и `--tags` и сократить объем самих плейбуков. Используемые плейбуки `app.yml`, `db.yml`, `deploy.yml` и агрегирующий плейбук `site.yml`, например:
```sh
$ ansible-playbook app.yml
```

Настроен dynamic inventory с помощью плагина `gcp_compute`. Использование динамического инвентори указано в `ansible.cfg`: `inventory = ./inventory_gcp.yml`. Подключение плагина производится в секции `[inventory]`: `enable_plugins = gcp_compute`. Для доступа к инфраструктуре GCP используется serviceaccount `auth_kind:` `serviceaccount`. Проверено получение инвентаризации с помощью:
```sh
$ ansible-inventory --list -i inventory_gcp.yml
```
Выполнена сборка образов `packer-app` и `packer-db` с использованием провижинера `ansible`. Скорректирована секция "provisioners" в конфигурационных файлах `packer/app.json` и `packer/db.json`. Деплой приложений в образе сконфигурирован в отдельных плейбуках `ansible/packer_app.yml` и `ansible/packer_db.yml`. Сборка образов производится из корня репозитория:
```sh
$ packer build -var-file=packer/variables.json packer/db.json
$ packer build -var-file=packer/variables.json packer/app.json
```



## homework#10 ansible-1
### Управление конфигурацией. Основные DevOps инструменты. Знакомство с Ansible
Установка и определение основных параметров ansible в файле `ansible.cfg`

Развертывание stage-окружение с помощью terraform

Изучение принципов выполнения команд на хостах с использованием файлов статической инвентаризации `inventory`, `inventory.yml`, понятие «Группа хостов»

Выполнение команд на хостах с использованием различных модулей - `shell`, `command`, `systemd`, `service`, `git`

Создание простого плейбука `clone.yml`, проверка его работы в случае, если склонированная ранее папка с репозитарием была удалена с хоста

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
- `terraform plan` - планирование изменений ресурсов относительно текущего состояния, зафиксированного в tfstate-файле;
- `terraform validate` - проверка синтаксиса конфигурационных файлов;
- `terraform fmt` - форматирование конфигурационных файлов;
- `terraform apply` - собственно создание ресурсов;
- `terraform output` - просмотр выходных переменных;
- `terraform.tfvars` - параметризация конфигурационных файлов с помощью входных переменных, определяемыхв в файлах с раширением `.tf`;
- установка приложения внутри инстанса VM с помощью провижнеров типа `file` и `remote-exec`, подключающихся по ssh;
- добавление ssh-ключей в метаданные проекта GCP с помощью `google_compute_project_metadata_item`. Любые другие ssh-ключи, добавленные вручную в интерфейсе GCP, будут удалены при применении `terraform apply`.

## homework#07 packer-base
### Работа с образами VM в облаке. Знакомство с Packer и экосистемой компании HashiCorp
Подготовка образа для развертывания VM instance reddit-base:
```sh
$ packer build -var-file=variables.json ubuntu16.json
```
Файл ubuntu16.json исключить из индекса git

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

## homework#06 cloud-testapp
### Способы управления ресурсами в GCP
Settings from homework#05:
```sh
bastion_IP = 35.228.94.43
someinternalhost_IP = 10.166.0.9
```
App settings
```
testapp_IP = 34.66.35.100
testapp_port = 9292
```
Create GCP VM instance:
```sh
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
```sh
gcloud compute firewall-rules create default-puma-server --allow tcp:9292 --target-tags 'puma-server' --source-ranges 0.0.0.0/0
```
For install packages and deploy app use install scripts in appuser home directory:
```sh
$ cd ~
$ install_ruby.sh
$ install_mongodb.sh
$ deploy.sh
```

## homework#05 cloud-bastion
### Практики безопасного доступа к ресурсам (SSH, Bastion Host, VPN)
Connect to ssh internal host (someinternalhost) through external host (bastion)

Fisrt way: Oneline command connect to someinternalhost through bastionhost:
```sh
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
```sh
$ ssh someinternalhost
```
Options for VPN connection:
```
bastion_IP = 35.228.94.43
someinternalhost_IP = 10.166.0.9
```
Configure VPN server for use Let's Encript sertificate:
Add fqdn "35.228.94.43.sslip.io" at pritunl server's settings
