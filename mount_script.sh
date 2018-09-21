#!/bin/bash

function mountIt
{
    if [[ -z $1 || -z $2 ]]
    then
        echo " Please provide valid arguments..Exiting"
        return;
    fi 

    cd /mnt
    share="$(echo $2 | cut -f3 -d/ )";

    if [[ -z $share ]]
    then
        share="share";
    fi

    sudo mkdir $share
    sudo chmod 777 $share
    sudo chown nobody.nogroup $share 

    echo " $1 will be mounted at /mnt/$share";
    
    sudo mount -t cifs -o uid=www-data,gid=www-data $1 $2;

    if [ $? != 0 ]
        then
        echo " Mounting failed ..Exiting"
        return ;
    fi

#if already present remove mounting configuration
    cmd="sudo sed -i '/\s\/mnt\/$share\s/d' /etc/fstab";
    eval $cmd;

#indentation is as per fstab file.
    sudo cat>> /etc/fstab <<EOF
$1 $2 cifs auto,noperm,guest,uid=www-data,gid=www-data 0 0
EOF

    echo " Mounting is completed......";           
}

mountIt $1 $2;
