#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" 
    exit 1
fi

cd /root

# Update the System
apt update 
apt upgrade -y 
apt dist-upgrade -y
apt autoremove -y

#Install Packages we will want
apt install -y most pydf curl vim git tree
  
# Install Visual Studio Code
if [ $(dpkg-query -W -f='${Status}' code 2>/dev/null | grep -c "ok installed") -eq 0  ];
then
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
    mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list
    apt update && apt install code
fi


# tlp, tlp-rdw
