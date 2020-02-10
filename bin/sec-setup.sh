#!/bin/bash

GREEN="\033[1;32m"
YELLOW="\e[0;33m"
ENDCOLOR="\e[0m"


# Install Core Packages -------------------------------------------------------
echo -ne $GREEN"\n>>> "$ENDCOLOR; echo "Syncing and updating existing packages"
sudo apt update  -y
sudo apt upgrade -y

echo -ne $GREEN"\n>>> "$ENDCOLOR; echo "Installing missing packages"

if [ $(sudo dpkg-query -W -f='${Status}' most 2>/dev/null | grep -c "ok installed") -eq 1 ];
then echo -ne $YELLOW">>> "$ENDCOLOR; echo "Package 'most' already installed";
else sudo apt install -y most; fi

if [ $(sudo dpkg-query -W -f='${Status}' ttf-mscorefonts-installer 2>/dev/null | grep -c "ok installed") -eq 1 ];
then echo -ne $YELLOW">>> "$ENDCOLOR; echo "Package 'ttf-mscorefonts-installer' already installed";
else sudo apt install -y ttf-mscorefonts-installer; fi

if [ $(sudo dpkg-query -W -f='${Status}' pydf 2>/dev/null | grep -c "ok installed") -eq 1 ];
then echo -ne $YELLOW">>> "$ENDCOLOR; echo "Package 'pydf' already installed";
else sudo apt install -y pydf; fi

if [ $(sudo dpkg-query -W -f='${Status}' build-essential 2>/dev/null | grep -c "ok installed") -eq 1 ];
then echo -ne $YELLOW">>> "$ENDCOLOR; echo "Package 'build-essential' already installed";
else sudo apt install -y build-essential; fi


# Install Python and useful libraries ----------------------------------------
echo -ne $GREEN"\n>>> "$ENDCOLOR; echo "Installing Python 3"
if [ $(sudo dpkg-query -W -f='${Status}' python3 2>/dev/null | grep -c "ok installed") -eq 1 ];
then echo -ne $YELLOW">>> "$ENDCOLOR; echo "Package 'python3' already installed";
else sudo apt install -y python3; fi

if [ $(sudo dpkg-query -W -f='${Status}' python3-setuptools 2>/dev/null | grep -c "ok installed") -eq 1 ];
then echo -ne $YELLOW">>> "$ENDCOLOR; echo "Package 'python3-setuptools' already installed";
else sudo apt install -y python3-setuptools; fi

if [ $(sudo dpkg-query -W -f='${Status}' python3-dev 2>/dev/null | grep -c "ok installed") -eq 1 ];
then echo -ne $YELLOW">>> "$ENDCOLOR; echo "Package 'python3-dev' already installed";
else sudo apt install -y python3-dev; fi

if [ $(sudo dpkg-query -W -f='${Status}' python3-pip 2>/dev/null | grep -c "ok installed") -eq 1 ];
then echo -ne $YELLOW">>> "$ENDCOLOR; echo "Package 'python3-pip' already installed";
else
    sudo apt install -y python3-pip
    sudo pip3 install --upgrade pip
fi

if [ $(sudo dpkg-query -W -f='${Status}' python3-venv 2>/dev/null | grep -c "ok installed") -eq 1 ];
then echo -ne $YELLOW">>> "$ENDCOLOR; echo "Package 'python3-venv' already installed";
else sudo apt install -y python3-venv; fi

echo -ne $GREEN"\n>>> "$ENDCOLOR; echo "Updating Pip packages"
if python3 -c "import pipenv" &> /dev/null; then
    echo -ne $YELLOW">>> "$ENDCOLOR; echo "Package 'pipenv' already installed"
else sudo pip3 install --upgrade pipenv; fi

if python3 -c "import pylint" &> /dev/null; then
    echo -ne $YELLOW">>> "$ENDCOLOR; echo "Package 'pylint' already installed"
else sudo pip3 install --upgrade pylint; fi


# Create personal directory structure and sync useful repos -------------------
echo -ne $GREEN"\n>>> "$ENDCOLOR; echo "Creating Directories & Syncing Repos"
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

