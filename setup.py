#!/usr/bin/env python3
""" Sets up a linux environment with the dotfiles in this repo """

import logging
import os
import sys
from datetime import datetime


def elevate_privileges():
    """ Gets sudo privileges and returns the current date """
    status = os.system("sudo date; echo")
    return status


def update_packages(operating_system: str) -> None:
    """ Do a general update of the system packages """
    logging.info("🔵 General Package Update")
    if operating_system in ["Windows", "Debian-based"]:
        cmdseries = ['sudo apt update',
                    'sudo apt full-upgrade -y',
                    'sudo apt autoremove -y']
        for cmdstring in cmdseries: os.system(cmdstring)
    if operating_system == "Archlinux":
        os.system("yay -Syyu")


def install_core_packages(operating_system: str) -> None:
    """ Install essential packages that didn't come by default """
    logging.info("🔵 Installing Core Packages")
    if operating_system in ["Windows", "Debian-based"]:
        cmdstring = "sudo apt install -y vim dos2unix git python3-pip python3-apt pwgen most \
            bash-completion most mtools net-tools grc meld pydf tldr tree wget"
        os.system(cmdstring)
    if operating_system == "Archlinux":
        cmdstring = "sudo apt install -y vim dos2unix git pwgen most 7zip arch-wiki-docs aspell-en \
            bandit btop go go-tools gopls gparted grc meld pydf mtools net-tools screen tmux rsync \
            tldr tree wget"
        os.system(cmdstring)


def sync_git_repo(gitrepo, repo_collection_dir) -> None:
    """ Sync the specified git repository """
    repo_name = gitrepo.split("/")[-1].lower()
    if os.path.exists(repo_collection_dir + repo_name):
        logging.info(f"🔄 Syncing {repo_name}: ")
        sys.stdout.flush()
        cmdstring = "git -C " + repo_collection_dir + repo_name + " pull"
        os.system(cmdstring)
    else:
        logging.info(f"⬇️ Cloning {repo_name}: ")
        cmdstring = f"git clone {gitrepo} {repo_collection_dir}{repo_name}"
        os.system(cmdstring)


def main() -> None:
    # Configure logging
    logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")

    # Determine OS (or exit)
    operating_system = "Unknown"
    if os.path.exists("/mnt/c/Windows/System32/wsl.exe"): operating_system = "Windows"
    if os.path.exists("/etc/pacman.conf"): operating_system = "Archlinux"
    if os.path.exists("/usr/bin/apt"): operating_system = "Debian-based"
    if operating_system == "Unknown":
        logging.error("❌ Could not determine operating system")
        sys.exit(1)

    # Get sudo privileges
    if elevate_privileges(): sys.exit(1)

    # Set directory & file variables
    homedir =        f"{os.getenv("HOME")}/"
    configdir =      f"{homedir}dotfiles/config/"
    vim_plugin_dir = f"{configdir}vim/bundle/"
    links =          os.listdir(configdir)

    ignore = ['.git', '.gitignore', 'README.md', 'setup.py', 'setup', 'wpscan', 'config',
              'gitconfig-personal', 'gitconfig-work']

    dirs_to_remove = ['Pictures', 'Templates', 'Videos', 'Documents', 'Public', 'Music']


    # Update system and install core packages
    update_packages(operating_system)
    install_core_packages(operating_system)


    # Install fonts
    try:
        cmdseries = [f"sudo cp {homedir}/dotfiles/fonts/*.ttf /usr/share/fonts",
                     "sudo fc-cache -f -v"]
        for cmdstring in cmdseries: os.system(cmdstring)
        logging.info("🟢 Fonts installed successfully")
    except Exception as e:
        logging.error(f"❌ Failed to install fonts: {str(e)}")

    # Remove directories I don't use
    for dir in dirs_to_remove:
        if os.path.exists(homedir + dir) and not os.path.islink(homedir + dir):
            try:
                os.rmdir(homedir + dir)
                logging.info("✂️ Removed: %s" % dir)
            except Exception as e:
                logging.error("❌ Failed to remove {}: {}".format(dir, str(e)))

    # Remove standard config files
    if os.path.exists('/etc/skel'):
        basicdotfiles = os.listdir('/etc/skel')
        for basicdotfile in basicdotfiles:
            target = homedir + basicdotfile
            if os.path.exists(target) and not os.path.islink(target) and not os.path.isdir(target):
                try:
                    os.remove(target)
                    logging.info("✂️ Removed: %s" % basicdotfile)
                except Exception as e:
                    logging.error("❌ Failed to remove {}: {}".format(basicdotfile, str(e)))

    # Simlink dotfiles
    for link in links:
        if link not in ignore and not os.path.exists(homedir + '.' + link):
            try:
                os.link("{}{}".format(configdir, link), "{}.{}".format(homedir, link))
                logging.info("🟢 Linked: %s" % link)
            except Exception as e:
                logging.error("❌ Failed to link {}: {}".format(link, str(e)))

    # Download git plugins
    if not os.path.exists(configdir + 'vim/bundle'):
        try:
            os.makedirs(configdir + 'vim/bundle')
            logging.info("🟢 Created directory: %s" % (configdir))
        except Exception as e:
            logging.error("❌ Failed to create directory {}: {}".format(configdir, str(e)))


    sync_git_repo('https://github.com/jiangmiao/auto-pairs', vim_plugin_dir)
    sync_git_repo('https://github.com/PProvost/vim-ps1', vim_plugin_dir)
    sync_git_repo('https://github.com/scrooloose/nerdtree', vim_plugin_dir)
    sync_git_repo('https://github.com/Xuyuanp/nerdtree-git-plugin', vim_plugin_dir)
    sync_git_repo('https://github.com/tpope/vim-sensible', vim_plugin_dir)
    sync_git_repo('https://github.com/jistr/vim-nerdtree-tabs', vim_plugin_dir)
    sync_git_repo('https://github.com/pangloss/vim-javascript', vim_plugin_dir)
    sync_git_repo('https://github.com/itchyny/lightline.vim', vim_plugin_dir)
    sync_git_repo('https://github.com/plasticboy/vim-markdown', vim_plugin_dir)


if __name__ == "__main__":
    main()
