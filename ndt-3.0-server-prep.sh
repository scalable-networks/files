#!/bin/bash

# Copyright 2015 Scalable Network Technologies Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This is not meant to be a permanent addition to Network Defense Trainer,
# more of a hold-over until we can get actual debian packaging worked out.
# Also, this will probably guide the debian work by detailing all the
# actual stuff that needs to be done to install NDT correctly.



## Some simple helper functions for writing bash scripts.
## Lifted directly from lib.sh created by Google Inc.
function Info {
  echo -e -n '\e[7m'
  echo "$@"
  echo -e -n '\e[0m'
}
function InstallPackage {
  Info "Checking for package '$1'"
  if ! dpkg -s $1 >/dev/null 2>/dev/null; then
    Info "Have to install package $1"
     sudo apt-get install $1 
  else
    Info "Package Already Present"    ;
    Info "----------------------";   
  fi
}

function pip_install()  {
  sudo -H pip install --no-index --find-links . $1   
}

function python_install() {
  echo ":------------ Python PIP Offline installation----------:";

  echo "Updating Pip....";
  sudo -H pip install --upgrade pip      
  echo "[1/4] Installing Django 1.6.2 ....";
  pip_install Django==1.6.2
  echo "[2/4] Installing Django RestframeWork 2.3.14 ....";
  pip_install djangorestframework==2.3.14
  echo "[3/4] Installing netaddr 0.7.11 ....";
  pip_install netaddr==0.7.11
  echo "[4/4] Installing pymongo 2.7.1 ....";
  pip_install pymongo==2.7.1
  echo "---------------- PIP installation completed ----------------";
}
## Set up environment
BINDIR="${BINDIR-/usr/bin}"
cd "$(dirname $0)"

Info "Welcome to the NDT Server pre-requisite package installer"

set -e
Info "Making sure we have sudo access"
sudo cat /dev/null
set +e

count=0;
count2=0;

# MySQL Server
read -r -p "Install MySQL Server? [y/N] " mysql_server
mysql_server=${mysql_server,,}    
if [[ $mysql_server ]]
then 
	let 'count=count+1'
fi
# MongoDB Server
read -r -p "Install MongoDB Server? [y/N] " mongodb
mongodb=${mongodb,,}    
if [[ $mongodb ]]
then 
	let 'count=count+1'
fi

# Web Application
read -r -p "Are you installing Web Application on this machine? [y/N] " webapp
webapp=${webapp,,}
if [[ $webapp ]]
then 
	let 'count=count+1'
fi  

# Simulation Service
read -r -p "Are you installing Simulation Service on this machine? [y/N] " simservice
simservice=${simservice,,}    
if [[ $simservice ]]
then 
	let 'count=count+1'
fi 

# Core Services
read -r -p "Are you installing Core Services on this machine? [y/N] " coreservices
coreservices=${coreservices,,}   
if [[ $coreservices ]]
then 
	let 'count2=count2+1'
fi 

# Virtual Machine Manager
read -r -p "Are you installing Virtual Machine Manager on this machine? [y/N] " vmmgr
vmmgr=${vmmgr,,}  
if [[ $vmmgr ]]
then 
	let 'count2=count2+1'
fi   

# VoiceChat Service
read -r -p "Are you installing VoiceChat Service on this machine? [y/N] " voicechat
voicechat=${voicechat,,}    
if [[ $voicechat ]]
then 
	let 'count=count+1'
fi 
# Shared File Server 
read -r -p "Is this machine going to be the Shared file system server (Samba)? [y/N] " samba
samba=${samba,,}   
if [[ $samba ]]
then 
	let 'count=count+1'
fi  

let 'total=count+count2';
count=0;
echo "Total selected services : $total";

#
# Install Packages
#

Info "Refreshing the apt repositories" 
sudo apt-get update


## MySQL Server
if [[ $mysql_server =~ ^(yes|y)$ ]]
then
let 'count=count+1';
Info "[$count/$total] Installing MySQL server"
InstallPackage mysql-server
fi

## MongoDB Server
if [[ $mongodb =~ ^(yes|y)$ ]]
then
let 'count=count+1';
Info "[$count/$total] Installing MongoDB server"
InstallPackage mongodb
fi

## Web App
if [[ $webapp =~ ^(yes|y)$ ]]
then
let 'count=count+1';
Info "[$count/$total] Installing Apache web server"
InstallPackage apache2
InstallPackage apache2-utils
InstallPackage libapache2-mod-wsgi

Info "[$count/$total] Installing Python / Django"
InstallPackage unzip
InstallPackage libxml2-utils
InstallPackage m4
InstallPackage build-essential
InstallPackage python-dev

InstallPackage python
InstallPackage python-mysqldb
InstallPackage python-pip

#sudo pip install -U pip
#sudo pip install -U Django==1.6
#sudo pip install -U djangorestframework==2.3.14
#sudo pip install -U netaddr==0.7.11
#sudo pip install -U pymongo==2.7.1

python_install

sudo service apache2 restart

Info "[$count/$total] Installing Common Internet File System utilities"
InstallPackage cifs-utils

fi

## All Node servers
if [[ $simservice =~ ^(yes|y)$ || $coreservices =~ ^(yes|y)$ || $vmmgr =~ ^(yes|y)$ || $voicechat =~ ^(yes|y)$ ]]
then
let 'count=count+1'; 
let 'end=count+1';

str="[$count";
if [ $count2 == 2 ]
then
    str="$str-$end";
    let 'count=count+1';
fi


Info "$str/$total] Installing NodeJS and Node Modules";

InstallPackage build-essential
InstallPackage curl

## Install Node and NPM from source
curl -O http://nodejs.org/dist/v6.11.0/node-v6.11.0.tar.gz
tar xzvf node-v6.11.0.tar.gz
pushd node-v6.11.0
./configure
make
sudo make install
sudo ldconfig
popd

fi

## Sim Service
if [[ $simservice =~ ^(yes|y)$ ]]
then
let 'count=count+1';

Info "[$count/$total] Installing LSB Core"
InstallPackage lsb-core

Info "[$count/$total] Installing DKMS"
InstallPackage dkms

Info "[$count/$total] Installing LIBpcap"
InstallPackage libpcap0.8

Info "[$count/$total] Installing Common Internet File System utilities"
InstallPackage cifs-utils

fi

## Voice Chat
if [[ $voicechat =~ ^(yes|y)$ ]]
then
let 'count=count+1';
Info "Adding Freeswitch repositories to local apt repositories"
sudo bash -c "echo 'deb http://files.freeswitch.org/repo/deb/debian/ wheezy main' >> /etc/apt/sources.list.d/freeswitch.list"
sudo gpg --keyserver pool.sks-keyservers.net --recv-key D76EDC7725E010CF
sudo gpg -a --export D76EDC7725E010CF | sudo apt-key add -
sudo apt-get update

Info "[$count/$total] Installing Freeswitch"
InstallPackage freeswitch-meta-vanilla
InstallPackage freeswitch-mod-shout
InstallPackage freeswitch-mod-opus

sudo cp -r /usr/share/freeswitch/conf/vanilla /etc/freeswitch
sudo chown -R freeswitch /etc/freeswitch

sudo service freeswitch restart

fi

## Samba File Server
if [[ $samba =~ ^(yes|y)$ ]]
then
let 'count=count+1';
Info "[$count/$total]Installing Samba file server"
InstallPackage samba
fi

Info "You should run the comment 'sudo apt-get autoremove' to clean up unneeded packages."

Info "Done. You can run the NDT Installer now."
