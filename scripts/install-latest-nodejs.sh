#!/bin/bash

#installation for amazon linux
#
yum install -y npm --enablerepo=epel
npm update -g npm
npm install -g n
n stable
NODE_STABLE_VERSION=$(n --stable)
NODE_STABLE_BINPATH=$(n which $NODE_STABLE_VERSION)
rm -f /usr/bin/node
ln -s /usr/local/bin/node /usr/bin/node

#for UserData
#yum install -y npm --enablerepo=epel && npm update -g npm && npm install -g n && n stable && NODE_STABLE_VERSION=$(n --stable) && NODE_STABLE_BINPATH=$(n which $NODE_STABLE_VERSION) && rm -f /usr/bin/node && ln -s /usr/local/bin/node /usr/bin/node

#installation for debian jessie
#
#apt-get install -y npm
#npm update -g npm
#npm install -g n
#n stable

#apt-get install -y npm && npm update -g npm && npm install -g n && n stable
