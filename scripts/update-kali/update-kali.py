#!/usr/bin/env python3
import os
import apt
import subprocess
import sys


def print_green(message):
    print("\n\033[1;32;40m>>> \033[1;37;40m" + message + "\033[0;37;0m")

def print_yellow(message):
    print("\033[1;33;40m>>> \033[0;37;40m" + message + "\033[0;37;0m")

def print_red(message):
    print("\033[0;31;40m>>> \033[1;37;40m" + message + "\033[0;37;0m")

def update_packages():
    ''' Do a general update of the system packages '''
    print_green("General Update")
    updatecmds = ['update', 'upgrade', 'dist-upgrade', 'autoremove']
    for updatecmd in updatecmds:
        os.system("sudo apt -y " + updatecmd)

def check_service_status(service):
    """ Returns 'active' or 'inactive' depending on service status """
    status = os.system("systemctl is-active " + service)
    return status

def package_install(package, cache):
    if cache[package].is_installed:
        print_yellow("Package '" + package + "' already installed")
    else:
        print_red(" Installing " + package)
        cmdstring = "sudo apt install -y " + package
        if package == "pip": cmdstring += " && sudo pip3 install --upgrade pip"
        os.system(cmdstring)

def pip_package_install(pip_packages, installed_pip_packages):
    for package in pip_packages:
        if package in installed_pip_packages:
            print_yellow("Pip package '" + package + "' already installed")
        else:
            print_red("Installing pip package " + package)
            cmdstring = "sudo pip3 install --upgrade " + package
            os.system(cmdstring)

def create_directory(directory):
    ''' Checks if the specified directory exists, and creates it if not '''
    if os.path.exists(directory):
        print_yellow("Directory exists: " + directory)
    else:
        print_red("Creating directory: " + directory)
        cmdstring = "mkdir " + directory
        os.system(cmdstring)

def remove_directory(directory):
    ''' Checks if the specified directory exists, and deletes it if it does '''
    directory = os.getenv("HOME") + '/' + directory
    if os.path.exists(directory):
        print_red("Removing directory: " + directory)
        cmdstring = "rmdir " + directory
        os.system(cmdstring)

def git_sync(gitrepo, directory):
    if os.path.exists(directory):
        print_yellow("Syncing " + directory)
        cmdstring = "git -C " + directory + " pull origin master"
        os.system(cmdstring)
    else:
        print_red("Cloning " + directory)
        cmdstring = "git clone " + gitrepo + " " + directory
        if directory == '/impacket': cmdstring += " && pip install " + external_repo_directory + '/impacket'
        os.system(cmdstring)


def main():
    # Set environment variables
    cache = apt.Cache()
    home_dir = os.getenv("HOME")
    personal_repo_directory = home_dir + '/x'
    external_repo_directory = home_dir + '/z'
    directories_to_remove = ['Documents', 'Music', 'Pictures', 'Public', 'Templates', 'Videos']
    package_list = ['most', 'ttf-mscorefonts-installer', 'pydf', 'python3-pip', 'python3-venv']
    pip_packages = ['pipenv', 'pylint']

    # Update and upgrade apt packages
    update_packages()

    print_green("Installing missing packages")
    for package in package_list:
        package_install(package, cache)

    installed_pip_packages = [r.decode().split('==')[0] for r in \
        subprocess.check_output([sys.executable, '-m', 'pip', 'freeze']).split()] # must be post python3-pip install
    pip_package_install(pip_packages, installed_pip_packages)

    print_green("Creating directory structure")
    create_directory(personal_repo_directory)
    create_directory(external_repo_directory)
    for directory in directories_to_remove:
        remove_directory(directory)

    print_green("Syncing git repositories")
    git_sync('git@github.com:rafaelh/dotfiles.git', home_dir + '/dotfiles')
    git_sync('git@github.com:rafaelh/security.git', personal_repo_directory + '/security')
    git_sync('git@github.com:rafaelh/notes.git', personal_repo_directory + '/notes')
    git_sync('https://github.com/danielmiessler/SecLists', external_repo_directory + '/seclists')
    git_sync('https://github.com/SecureAuthCorp/impacket', external_repo_directory + '/impacket')
    git_sync('https://github.com/swisskyrepo/PayloadsAllTheThings', external_repo_directory + '/payloadsallthethings')

    if check_service_status('sshd') == 'active':
        print("sshd is active")
    else:
        print("sshd is inactive")
        print(check_service_status('sshd'))

if __name__ == '__main__':
    main()

'''
TODO:
* Install vscode and sync settings
* Install Typora and sync settings

sudo apt remove -y chromium

systemctl enable postresql
system start postgresql

Add loguru
move to separate repo
load variables from a file
start making it generically useful



'''