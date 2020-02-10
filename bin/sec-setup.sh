#!/bin/bash

GREEN="\033[1;32m"
YELLOW="\e[0;33m"
ENDCOLOR="\e[0m"


# Install Core Packages -------------------------------------------------------
echo -ne $GREEN">>> "$ENDCOLOR; echo "Installing Basic Packages"
sudo apt update  -y

if [ $(dpkg-query -W -f='${Status}' most 2>/dev/null | grep -c "ok installed") -eq 0 ];
then echo -ne $YELLOW">>> "$ENDCOLOR; echo "Package 'most' already installed";
else apt install -y most; fi

if [ $(dpkg-query -W -f='${Status}' ttf-mscorefonts-installer 2>/dev/null | grep -c "ok installed") -eq 0 ];
then echo -ne $YELLOW">>> "$ENDCOLOR; echo "Package 'ttf-mscorefonts-installer' already installed";
else apt install -y ttf-mscorefonts-installer; fi

if [ $(dpkg-query -W -f='${Status}' pydf 2>/dev/null | grep -c "ok installed") -eq 0 ];
then echo -ne $YELLOW">>> "$ENDCOLOR; echo "Package 'pydf' already installed";
else apt install -y pydf; fi


# Install Python and useful libraries ----------------------------------------
echo -ne $GREEN">>> "$ENDCOLOR; echo "Installing Python 3"
sudo apt install -y python3 python3-setuptools python3-dev build-essential python3-pip python3-venv

echo -ne $GREEN">>> "$ENDCOLOR; echo "Updating Pip packages"
sudo pip3 install --upgrade pip
sudo pip3 install --upgrade pipenv
sudo pip3 install --upgrade pylint


# Create personal directory structure and sync useful repos -------------------
echo -ne $GREEN">>> "$ENDCOLOR; echo "Creating Directories & Syncing Repos"
if [ -d ~/x ]; then
    echo -ne $YELLOW">>> "$ENDCOLOR; echo "Personal repo directory 'x' exists"
else
    mkdir ~/x
fi

if [ -d ~/z ]; then
    echo -ne $YELLOW">>> "$ENDCOLOR; echo "External repo directory 'z' exists"
else
    mkdir ~/z
fi

if [ -d ~/x/security ]; then
    echo -ne $YELLOW">>> "$ENDCOLOR; echo "Personal repo 'security' exists"
else git clone git@github.com:rafaelh/security.git ~/x/security; fi

if [ -d ~/x/notes ]; then
    echo -ne $YELLOW">>> "$ENDCOLOR; echo "Personal repo 'notes' exists"
else git clone git@github.com:rafaelh/notes.git ~/x/notes; fi

if [ -d ~/z/seclists ]; then
    echo -ne $YELLOW">>> "$ENDCOLOR; echo "Personal repo 'seclists' exists"
else git clone https://github.com/danielmiessler/SecLists ~/z/seclists; fi

if [ -d ~/z/impacket ]; then
    echo -ne $YELLOW">>> "$ENDCOLOR; echo "Personal repo 'impacket' exists"
else
    git clone https://github.com/SecureAuthCorp/impacket ~/z/impacket
    pip install ~/z/impacket
fi

