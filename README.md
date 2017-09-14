# dotfiles

This is a script to set up all my standard settings on new linux, mac or WSL environments. It isn't intended for anyone else to use, but you are welcome to  do so if you wish.

Clone the repository and then run python3 setup.py to create symlinks in your home directory. This will also create a '~/gitrepos' directory which you should add any local git repositories to. Once you have restarted the terminal environment (or run 'source ~/.bashrc'), you can run 'gitupdate', which will update all repositories in the gitrepos directory, including this one. It will also update the vim plugin directories.

Have fun!
