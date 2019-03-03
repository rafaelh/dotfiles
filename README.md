# dotfiles

This is a script to set up all my standard commandline settings. I primarily use it on WSL or Chromebook environments, but I've used it on Mac and Linux as well. Theoretically these should behave the same, but in practice they differ in the details. I didn't write this with other people using it in mind, but you are welcome to do so if you wish.

Clone the repository and then run python setup.py to create symlinks in your home directory.

Things to note:
* Scripts are located in the dotfiles/bin directory, which is symlinked to ~/.bin
* Setup will erase your vim plugins directory, and will sync a new set. After that you can run 'vimupdate' to iterate through them and pull the latest code
* If you symlink this to root as well, it should provide you with a similar setup, tweaked for admin access

Have fun!
