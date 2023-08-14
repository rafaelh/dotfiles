#!/usr/bin/env python3
""" Sets up a linux environment with the dotfiles in this repo """

import os
import sys
from datetime import datetime

def print_message(color, message):
    """ Prints a formatted message to the console. Used in other functions, so it comes first. """
    if   color == "green":  print("\033[1;32m[+] \033[0;37m" + datetime.now().strftime("%H:%M:%S") + " - " + message)
    elif color == "blue":   print("\n\033[1;34m[i] \033[0;37m" + datetime.now().strftime("%H:%M:%S") + " - " + message)
    elif color == "yellow": print("\033[0;33m[<] \033[0;37m" + datetime.now().strftime("%H:%M:%S") + " - " + message, end="")
    elif color == "red":    print("\033[1;31m[-] \033[0;37m" + datetime.now().strftime("%H:%M:%S") + " - " + message)
    elif color == "error":  print("\033[1;31m[!] \033[0;37m" + datetime.now().strftime("%H:%M:%S") + " - " + message)
    else:                   print("\033[0;41mInvalid Format\033[0;37m " + datetime.now().strftime("%H:%M:%S") + " " + message)

def elevate_privileges():
    """ Gets sudo privileges and returns the current date """
    status = os.system("sudo date; echo")
    return status

def update_packages():
    """ Do a general update of the system packages, if not on archlinux """
    cmdseries = ['sudo apt update',
                 'sudo apt full-upgrade -y',
                 'sudo apt autoremove -y']
    if not os.path.exists("/etc/pacman.conf"):
        for cmdstring in cmdseries:
            os.system(cmdstring)

def sync_git_repo(gitrepo, repo_collection_dir):
    """ Sync the specified git repository """
    repo_name = gitrepo.split("/")[-1].lower()
    if os.path.exists(repo_collection_dir + '/' + repo_name):
        print_message("yellow", "Syncing " + repo_name + ": ")
        sys.stdout.flush()
        cmdstring = "git -C " + repo_collection_dir + '/' + repo_name + " pull"
        os.system(cmdstring)
    else:
        print_message("green", "Cloning " + repo_name)
        cmdstring = "git clone " + gitrepo + ' ' + repo_collection_dir + '/' + repo_name
        os.system(cmdstring)

def link(origin, linkname):
    """ Create a soft link on the file system """
    if not os.path.exists(linkname):
        print_message("green", "Linking " + origin + " to " + linkname)
        cmdstring = "ln -s %s %s" % origin, linkname
        os.system(cmdstring)

def main():
    windows_home_dir = "/mnt/c/Users/" + os.getenv("USER")
    linux_home_dir = os.getenv("HOME")
    vim_plugin_dir = os.getenv("HOME") + '/dotfiles/config/vim/bundle'
    # Get sudo privileges
    if elevate_privileges(): sys.exit(1)

    # Update and upgrade apt packages
    print_message("blue", "General Update")
    update_packages()

    # Install initial packages if on a Debian based system
    print_message("blue", "Installing core packages")
    if not os.path.exists("/etc/pacman.conf"):
        cmdstring = "sudo apt install -y vim dos2unix git python3-pip python3-apt pwgen"
        os.system(cmdstring)
    else:
        cmdstring = "bash-completion most mtools net-tools"
        os.system(cmdstring)

    # Install fonts
    print_message("blue", "Installing fonts")
    cmdstring = "sudo cp ~/dotfiles/fonts/*.ttf /usr/share/fonts && fc-cache -f -v"
    os.system(cmdstring)

    # Set environment variables
    homedir = os.getenv("HOME") + '/'
    configdir = os.getenv("HOME") + '/dotfiles/config/'
    links = os.listdir(configdir)
    ignore = ['.git', '.gitignore', 'README.md', 'setup.py', 'setup',
            'foxyproxy.json', 'wpscan', 'config']

    # Remove directories I don't use
    defaultdirs = ['Pictures', 'Templates', 'Videos', 'Documents', 'Public', 'Music']
    for defaultdir in defaultdirs:
        if os.path.exists(homedir + defaultdir):
            if not os.path.islink(homedir + defaultdir):
                print_message("red", "Removing " + defaultdir)
                cmdstring = "rmdir %s%s" % (homedir, defaultdir)
                os.system(cmdstring)

    # Remove standard config files
    if os.path.exists('/etc/skel'):
        basicdotfiles = os.listdir('/etc/skel')
        for basicdotfile in basicdotfiles:
            if not os.path.islink(homedir + basicdotfile) and \
            not os.path.isdir(homedir + basicdotfile) and \
            os.path.exists(homedir + basicdotfile):
                print_message("red", "Removing " + basicdotfile)
                cmdstring = "rm %s%s" % (homedir, basicdotfile)
                os.system(cmdstring)

    # Simlink dotfiles
    for link in links:
        if link not in ignore and not os.path.exists(homedir + '.' + link):
            print_message("green", "Linking: %s" % link)
            cmdstring = "ln -s %s%s %s.%s" % (configdir, link, homedir, link)
            print(cmdstring)
            os.system(cmdstring)

    # Download git plugins
    if not os.path.exists(configdir + 'vim/bundle'):
        cmdstring = "mkdir %s" % configdir + 'vim/bundle'
        os.system(cmdstring)

    sync_git_repo('https://github.com/jiangmiao/auto-pairs', vim_plugin_dir)
    sync_git_repo('https://github.com/PProvost/vim-ps1', vim_plugin_dir)
    sync_git_repo('https://github.com/scrooloose/nerdtree', vim_plugin_dir)
    sync_git_repo('https://github.com/Xuyuanp/nerdtree-git-plugin', vim_plugin_dir)
    sync_git_repo('https://github.com/tpope/vim-sensible', vim_plugin_dir)
    sync_git_repo('https://github.com/jistr/vim-nerdtree-tabs', vim_plugin_dir)
    sync_git_repo('https://github.com/pangloss/vim-javascript', vim_plugin_dir)
    sync_git_repo('https://github.com/itchyny/lightline.vim', vim_plugin_dir)
    sync_git_repo('https://github.com/plasticboy/vim-markdown', vim_plugin_dir)

    sync_git_repo('git@github.com:rafaelh/update-kali', os.getenv("HOME") + '/dotfiles/scripts')
    sync_git_repo('git@github.com:rafaelh/recon', os.getenv("HOME") + '/dotfiles/scripts')

if __name__ == "__main__":
    main()
