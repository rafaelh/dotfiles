#!/bin/bash

GREEN="\033[1;32m"
YELLOW="\e[0;33m"
ENDCOLOR="\e[0m"


# Install Core Packages -------------------------------------------------------
echo -ne $GREEN">>> "$ENDCOLOR; echo "Syncing and Updating Packages"
sudo apt update  -y
sudo apt upgrade -y

if [ $(sudo dpkg-query -W -f='${Status}' most 2>/dev/null | grep -c "ok installed") -eq 0 ];
then echo -ne $YELLOW">>> "$ENDCOLOR; echo "Package 'most' already installed";
else sudo apt install -y most; fi

if [ $(sudo dpkg-query -W -f='${Status}' ttf-mscorefonts-installer 2>/dev/null | grep -c "ok installed") -eq 0 ];
then echo -ne $YELLOW">>> "$ENDCOLOR; echo "Package 'ttf-mscorefonts-installer' already installed";
else sudo apt install -y ttf-mscorefonts-installer; fi

if [ $(sudo dpkg-query -W -f='${Status}' pydf 2>/dev/null | grep -c "ok installed") -eq 0 ];
then echo -ne $YELLOW">>> "$ENDCOLOR; echo "Package 'pydf' already installed";
else sudo apt install -y pydf; fi

if [ $(sudo dpkg-query -W -f='${Status}' build-essential 2>/dev/null | grep -c "ok installed") -eq 0 ];
then echo -ne $YELLOW">>> "$ENDCOLOR; echo "Package 'build-essential' already installed";
else sudo apt install -y build-essential; fi

# Install Python and useful libraries ----------------------------------------
echo -ne $GREEN">>> "$ENDCOLOR; echo "Installing Python 3"
if [ $(sudo dpkg-query -W -f='${Status}' python3 2>/dev/null | grep -c "ok installed") -eq 0 ];
then echo -ne $YELLOW">>> "$ENDCOLOR; echo "Package 'python3' already installed";
else sudo apt install -y python3; fi

if [ $(sudo dpkg-query -W -f='${Status}' python3-setuptools 2>/dev/null | grep -c "ok installed") -eq 0 ];
then echo -ne $YELLOW">>> "$ENDCOLOR; echo "Package 'python3-setuptools' already installed";
else sudo apt install -y python3-setuptools; fi

if [ $(sudo dpkg-query -W -f='${Status}' python3-dev 2>/dev/null | grep -c "ok installed") -eq 0 ];
then echo -ne $YELLOW">>> "$ENDCOLOR; echo "Package 'python3-dev' already installed";
else sudo apt install -y python3-dev; fi

if [ $(sudo dpkg-query -W -f='${Status}' python3-pip 2>/dev/null | grep -c "ok installed") -eq 0 ];
then echo -ne $YELLOW">>> "$ENDCOLOR; echo "Package 'python3-pip' already installed";
else sudo apt install -y python3-pip; fi

if [ $(sudo dpkg-query -W -f='${Status}' python3-venv 2>/dev/null | grep -c "ok installed") -eq 0 ];
then echo -ne $YELLOW">>> "$ENDCOLOR; echo "Package 'python3-venv' already installed";
else sudo apt install -y python3-venv; fi

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
    echo -ne $YELLOW">>> "$ENDCOLOR; echo "External repo 'seclists' exists"
else git clone https://github.com/danielmiessler/SecLists ~/z/seclists; fi

if [ -d ~/z/impacket ]; then
    echo -ne $YELLOW">>> "$ENDCOLOR; echo "External repo 'impacket' exists"
else
    git clone https://github.com/SecureAuthCorp/impacket ~/z/impacket
    pip install ~/z/impacket
fi

