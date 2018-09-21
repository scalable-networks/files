#!/bin/bash

function createShare
{
    if [[ -z $1 ]]
    then
        echo " Please provide valid folder name..Exiting"
        return;
    fi     

    echo " Creating shared folder $1..........";
    mkdir -p $HOME/$1

    if [ $? ]
    then
        echo " Created $1";
    else
        echo " Failed to create $1";
        return;
    fi
    cd $HOME
    sudo chmod 777 $1
    sudo chown nobody.nogroup $1     

#indentation cannt be maintained, otherwise smb.conf would be in-consistent
sudo cat>> /etc/samba/smb.conf <<eof
[$1]
comment = NDT File Server Share
path = $HOME/$1
browseable = yes
guest ok = yes
read only = no
create mask = 0755    
eof

    sudo smbd restart;
    sudo nmbd restart;
  
    echo " Created shared folder : $HOME/$1";        
}

createShare $1
