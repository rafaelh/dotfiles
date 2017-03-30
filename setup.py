#!/usr/bin/env python
import os

# Set environment variables
homedir = os.getenv("HOME") + '/'
repodir = os.getenv("HOME") + '/dot_lin/'
links = os.listdir(repodir)
ignore = ['.git', 'README.md', 'setup.py', 'setup']

# Remove standard config files
if os.path.exists('/etc/skel'):
    basicdotfiles = os.listdir('/etc/skel')
    for basicdotfile in basicdotfiles:
        cmdstring = "rm -rf %s%s" % (homedir, basicdotfile)
        os.system(cmdstring)

# Simlink dotfiles
for link in links:
    if link not in ignore and not os.path.exists(homedir + '.' + link):
        print "\033[1;32;40m>>> \033[1;37;40mLinking: %s\033[0;37;40m" % link
        cmdstring = "ln -s %s%s %s.%s" % (repodir, link, homedir, link)
        os.system(cmdstring)
        print cmdstring

# Download git plugins
def gitsync(gitrepo, gitname):
    if not os.listdir(repodir + 'vim/bundle/' + gitname):
        print "Syncing %s" % gitname
        cmdstring = "git -C %svim/bundle/ clone %s" % (repodir, gitrepo)
        os.system(cmdstring)
    return;

gitsync('https://github.com/jiangmiao/auto-pairs', 'auto-pairs')
gitsync('https://github.com/ajh17/VimCompletesMe', 'VimCompletesMe')
gitsync('https://github.com/PProvost/vim-ps1', 'vim-ps1')
gitsync('https://github.com/scrooloose/nerdtree', 'nerdtree')
gitsync('https://github.com/Xuyuanp/nerdtree-git-plugin', 'nerdtree-git-plugin')
