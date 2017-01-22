#!/usr/bin/env python
import os

# Symlink dotfiles
homedir = os.getenv("HOME") + '/'
repodir = os.getenv("HOME") + '/dot_lin/'
links = os.listdir(repodir)
ignore = ['.git', 'README.md']

for link in links:
    if link not in ignore:
        print "\033[1;32;40m>>> \033[1;37;40mLinking: %s\033[0;37;40m" % link
        cmdstring = "ln -s %s%s %s.%s" % (homedir, link, repodir, link)
        print cmdstring

# To do
# Add checks to remove existing files if links are already THEre


# Download git plugins

def gitsync( gitrepo ):
    cmdstring = "git -C %svim/bundle/ clone %s" % (repodir, gitrepo)
    os.system(cmdstring)
    return;

print "Syncing vim plugins"
gitsync('https://github.com/jiangmiao/auto-pairs')
gitsync('https://github.com/ajh17/VimCompletesMe')


# To do:
# add 'is directory empty checks' - if os.listdir(work_path) = []:
#
# check if gitrepos is created, creat it if not, and add a 'dot_lin' symlink to
# it
