#! /bin/bash

# Install MongoDB
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0xd68fa50fea312927
sudo bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list'
sudo apt update
sudo apt install -y mongodb-org

# Start MongodDB
sudo systemctl start mongod
sudo systemctl enable mongod
appuser@reddit-app:~$ cat deploy.sh
#! /ban/bash

# Install git
sudo apt update
sudo apt install git -y

# Clone app
cd ~
git clone -b monolith https://github.com/express42/reddit.git

# Install dependences
cd reddit && bundle install

# Start app
puma -d
