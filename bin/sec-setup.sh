#!/bin/bash

GREEN="\033[1;32m"
ENDCOLOR="\e[0m"

echo -ne $GREEN">>> "$ENDCOLOR; echo "Installing Basic Packages"
sudo apt update  -y
sudo apt install -y most ttf-mscorefonts-installer pydf

echo -ne $GREEN">>> "$ENDCOLOR; echo "Installing Python 3"
sudo apt install -y python3 python3-setuptools python3-dev build-essential python3-pip python3-venv

echo -ne $GREEN">>> "$ENDCOLOR; echo "Updating Pip packages"
sudo pip3 install --upgrade pip
sudo pip3 install --upgrade pipenv
sudo pip3 install --upgrade pylint

echo -ne $GREEN">>> "$ENDCOLOR; echo "Creating Directories & Syncing Repos"
mkdir ~/x
mkdir ~/z

git clone git@github.com:rafaelh/security.git ~/x/security
git clone git@guthub.com:rafaelh/notes.git    ~/x/notes

git clone https://github.com/danielmiessler/SecLists ~/z/seclists
git clone https://github.com/SecureAuthCorp/impacket ~/z/impacket
pip install ~/z/impacket

