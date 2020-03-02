#!/usr/bin/env python3

import os

def linkfolder(windowspath, linkname, homedir):
    linkpath = homedir + linkname
    if not os.path.exists(linkpath):
        cmdstring = "ln -s %s %s" % ('/mnt/c/Users/' + os.getenv("USER")
                + windowspath, linkpath)
        os.system(cmdstring)

def sync_vim_repo(gitrepo, gitname, repodir):
    """ Syncs a git repo containing a vim plugin """
    if not os.path.exists(repodir + 'vim/bundle'):
        cmdstring = "mkdir %s" % repodir + 'vim/bundle'
    if not os.path.exists(repodir + 'vim/bundle/' + gitname):
        print("\n\033[1;32;40m>>> \033[1;37;40mSyncing: %s\033[0;37;0m" % gitname)
        cmdstring = "mkdir %s" % repodir + 'vim/bundle/' + gitname
        os.system(cmdstring)
        cmdstring = "git -C %svim/bundle/ clone %s" % (repodir, gitrepo)
        os.system(cmdstring)
    return


def main():
    # Set environment variables
    homedir = os.getenv("HOME") + '/'
    repodir = os.getenv("HOME") + '/dotfiles/config/'
    links = os.listdir(repodir)
    ignore = ['.git', '.gitignore', 'README.md', 'setup.py', 'setup',
            'foxyproxy.json', 'wpscan', 'config']

    # Remove standard config files
    if os.path.exists('/etc/skel'):
        basicdotfiles = os.listdir('/etc/skel')
        for basicdotfile in basicdotfiles:
            cmdstring = "rm -rf %s%s" % (homedir, basicdotfile)
            os.system(cmdstring)
    cmdstring = "rm -rf %s.vim/bundle/*" % homedir
    os.system(cmdstring)

    if os.path.exists('/mnt/c'):
        linkfolder("/Dropbox", "dropbox", homedir)
        linkfolder("/Google Drive", "gdrive", homedir)
        linkfolder("/Downloads", "downloads", homedir)

    # Simlink dotfiles
    for link in links:
        if link not in ignore and not os.path.exists(homedir + '.' + link):
            print("\033[1;32;40m>>> \033[1;37;40mLinking: %s\033[0;37;0m" % link)
            cmdstring = "ln -s %s%s %s.%s" % (repodir, link, homedir, link)
            os.system(cmdstring)

    # Download git plugins
    if not os.path.exists(repodir + 'vim/bundle'):
        cmdstring = "mkdir %s" % repodir + 'vim/bundle'
        os.system(cmdstring)

    sync_vim_repo('https://github.com/jiangmiao/auto-pairs', 'auto-pairs', repodir)
    sync_vim_repo('https://github.com/PProvost/vim-ps1', 'vim-ps1', repodir)
    sync_vim_repo('https://github.com/scrooloose/nerdtree', 'nerdtree', repodir)
    sync_vim_repo('https://github.com/Xuyuanp/nerdtree-git-plugin', 'nerdtree-git-plugin', repodir)
    sync_vim_repo('https://github.com/tpope/vim-sensible', 'sensible-vim', repodir)
    sync_vim_repo('https://github.com/jistr/vim-nerdtree-tabs', 'vim-nerdtree-tabs', repodir)
    sync_vim_repo('https://github.com/pangloss/vim-javascript', 'vim-javascript', repodir)
    sync_vim_repo('https://github.com/itchyny/lightline.vim', 'lightline.vim', repodir)
    sync_vim_repo('https://github.com/plasticboy/vim-markdown', 'vim-markdown', repodir)

if __name__ == "__main__":
    main()