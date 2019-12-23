# DmitryMonakhov_infra
DmitryMonakhov Infra repository
##### Settings from homework#4:
```console
bastion_IP = 35.228.94.43
someinternalhost_IP = 10.166.0.9
```
##### App settings
```console
testapp_IP = 34.66.35.100
testapp_port = 9292
```
##### Create GCP VM instance:
```console
gcloud compute instances create reddit-app \
	--boot-disk-size=10GB \
	--image-family ubuntu-1604-lts \
	--image-project=ubuntu-os-cloud \
	--machine-type=g1-small \
	--tags puma-server \
	--restart-on-failure \
	--startup-script=startup-script.sh
```
##### Create firewall rule:
```console
gcloud compute firewall-rules create default-puma-server --allow tcp:9292 --target-tags 'puma-server' --source-ranges 0.0.0.0/0
```
##### For install packages and deploy app use install scripts in appuser home directory:
```sh
$ cd ~
$ install_ruby.sh
$ install_mongodb.sh
$ deploy.sh
```
