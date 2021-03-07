#!/usr/bin/env python3

import os
import sys
from datetime import datetime

def print_message(color, message):
    """ Prints a formatted message to the console """
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
    """ Do a general update of the system packages """
    cmdseries = ['sudo apt update',
                 'sudo apt full-upgrade -y',
                 'sudo apt autoremove -y']
    for cmdstring in cmdseries:
        os.system(cmdstring)

# Need to combine and replace these
#def print_green(message):
#    """ Prints a message to the console prefixed with a green '>>>' """
#    print("\033[1;32;40m>>> \033[1;37;40m" + message + "\033[0;37;0m")

#def print_yellow(message):
#    """ Prints a message to the console prefixed with a yellow '>>>' """
#    print("\033[1;33;40m>>> \033[0;37;40m" + message + "\033[0;37;0m")

#def print_red(message):
#    """ Prints a message to the console prefixed with a red '>>>' """
#    print("\033[0;31;40m>>> \033[1;37;40m" + message + "\033[0;37;0m")

def linkfolder(windowspath, linkname):
    linkpath = os.getenv("HOME") + '/' + linkname
    if not os.path.exists(linkpath):
        cmdstring = "ln -s %s %s" % ('/mnt/c/Users/' + os.getenv("USER")
                + windowspath, linkpath)
        os.system(cmdstring)

def sync_vim_repo(gitrepo):
    """ Syncs a git repo containing a vim plugin """
    vim_plugin_dir = os.getenv("HOME") + '/dotfiles/config/vim/bundle'
    gitname = gitrepo.split("/")
    if not os.path.exists(vim_plugin_dir):
        cmdstring = "mkdir %s" % vim_plugin_dir
    if not os.path.exists(vim_plugin_dir + "/" + gitname[-1]):
        #print_green("Syncing: %s" % gitname[-1])
        print_message("yellow", "Syncing %s" % gitname[-1])
        cmdstring = "mkdir %s" % vim_plugin_dir + "/" + gitname[-1]
        os.system(cmdstring)
        cmdstring = "git -C %s/ clone %s" % (vim_plugin_dir, gitrepo)
        os.system(cmdstring)

def git_sync(gitrepo, directory):
    if os.path.exists(directory):
        #print_yellow("Syncing " + directory)
        print_message("yellow", "Syncing " + directory)
        cmdstring = "git -C " + directory + " pull origin master"
        os.system(cmdstring)
    else:
        #print_red("Cloning " + directory)
        print_message("yellow", "Cloning " + directory)
        cmdstring = "git clone " + gitrepo + " " + directory
        os.system(cmdstring)


def main():
    # Get sudo privileges
    if elevate_privileges(): sys.exit(1)

    # Update and upgrade apt packages
    print_message("blue", "General Update")
    update_packages()

    # Install initial packages
    print_message("blue", "Installing core packages")
    cmdstring = "sudo apt install -y vim dos2unix git python3-pip"
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

    # Remove standard config files
    if os.path.exists('/etc/skel'):
        basicdotfiles = os.listdir('/etc/skel')
        for basicdotfile in basicdotfiles:
            print_message("red", "Removing " + basicdotfile)
            cmdstring = "rm -rf %s%s" % (homedir, basicdotfile)
            os.system(cmdstring)
    cmdstring = "rm -rf %s.vim/bundle/*" % homedir
    os.system(cmdstring)

    # Actions to perform on WSL. Should improve this to look for wsl.exe
    if os.path.exists('/mnt/c'):
        linkfolder("/Google Drive", "gdrive")
        linkfolder("/Downloads", "downloads")

    # Simlink dotfiles
    for link in links:
        if link not in ignore and not os.path.exists(homedir + '.' + link):
            #print_green("Linking: %s" % link)
            print_message("green", "Linking: %s" % link)
            cmdstring = "ln -s %s%s %s.%s" % (configdir, link, homedir, link)
            os.system(cmdstring)

    # Download git plugins
    if not os.path.exists(configdir + 'vim/bundle'):
        cmdstring = "mkdir %s" % configdir + 'vim/bundle'
        os.system(cmdstring)

    sync_vim_repo('https://github.com/jiangmiao/auto-pairs')
    sync_vim_repo('https://github.com/PProvost/vim-ps1')
    sync_vim_repo('https://github.com/scrooloose/nerdtree')
    sync_vim_repo('https://github.com/Xuyuanp/nerdtree-git-plugin')
    sync_vim_repo('https://github.com/tpope/vim-sensible')
    sync_vim_repo('https://github.com/jistr/vim-nerdtree-tabs')
    sync_vim_repo('https://github.com/pangloss/vim-javascript')
    sync_vim_repo('https://github.com/itchyny/lightline.vim')
    sync_vim_repo('https://github.com/plasticboy/vim-markdown')

    git_sync('git@github.com:rafaelh/update-kali.git', os.getenv("HOME") + '/dotfiles/scripts/update-kali')
    git_sync('git@github.com:rafaelh/recon.git', os.getenv("HOME") + '/dotfiles/scripts/recon')

if __name__ == "__main__":
    main()
