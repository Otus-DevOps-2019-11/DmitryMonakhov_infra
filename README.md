# DmitryMonakhov_infra
#### Connect to ssh internal host (someinternalhost) through external host (bastion)
###### Fisrt way: Oneline command connect to someinternalhost through bastionhost:

```sh
$ ssh -i ~/.ssh/appuser -t -A appuser@35.217.19.149 ssh -A appuser@10.166.0.5
```
###### Second way: add next lines to ~/.ssh/config:

```sh
Host bastion
  Hostname 35.217.19.149
  User appuser
  IdentityFile ~/.ssh/appuser
  ForwardAgent Yes
Host someinternalhost
  Hostname 10.166.0.5
  User appuser
  ProxyCommand ssh -q bastion nc -q0 someinternalhost 22
```
then run:
```sh
$ ssh someinternalhost
```

#### Options for VPN connection:
bastion_IP = 35.217.19.149
someinternalhost_IP = 10.166.0.5

##### Configure VPN server for use letencript sertificate:
Add ip address "35.217.19.149.sslip.io" in pritunl server's settings
