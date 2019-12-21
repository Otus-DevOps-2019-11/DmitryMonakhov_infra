# DmitryMonakhov_infra
DmitryMonakhov Infra repository
#### Connect to ssh internal host (someinternalhost) through external host (bastion)
###### Fisrt way: Oneline command connect to someinternalhost through bastionhost:
```sh
$ ssh -i ~/.ssh/appuser -t -A appuser@35.228.94.43 ssh -A appuser@10.166.0.9
```
###### Second way: add next lines to ~/.ssh/config:
```sh
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
#### Options for VPN connection:
```sh
bastion_IP = 35.228.94.43
someinternalhost_IP = 10.166.0.9
```
##### Configure VPN server for use Let's Encript sertificate:
Add fqdn "35.228.94.43.sslip.io" at pritunl server's settings
