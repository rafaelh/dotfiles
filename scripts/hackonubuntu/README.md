# hackonubuntu
I use [update-kali|https://github.com/rafaelh/update-kali] boxes, so it makes sense to start on a similar tool for ubuntu now that I'm using it. Ubuntu makes for a great hardware management base, and it's pretty straight forward to get most hacking tools onto it. Many tools like `gobuster` are available in Ubuntu's apt repositories, but they lag considerably, so my preference is to pull these direct from the source where possible.

## How do you use this?
This script installs the tools I'm likely to use, creates directories, etc. Currently it's set up for my personal use, but with a little modification you can use it too:

* Fork the repo so that you can commit changes to `config.py`, and so the script updates from the right place
* Update `config.py` with your preferences
* Go through `/scripts/` and delete the ones you don't want - they should be self-explanatory.
* Make sure you have the following installed: `python3`, `python3-apt` and `git`.

## Config
The default config can be found in `config.py`. You should updated it to match what you want, otherwise you'll have my preferences used. This script will:

* Perform a general package update
* Install and remove specified packages
* Install specified python modules
* Install specified golang tools
* Set up and remove specified directories
* Sync specified git repos to `~/x`, or a directory you nominate (private repos)
* Sync specified git repos to `/opt`, or a directory you nominate (public repos)
* Run all the scripts in `/scripts`

**Note:** The script will change the ownership of your tools directory, which is `/opt` by default, to your user so that you aren't building with sudo privileges. Change the tools directory if you don't want that to happen.

## Updating Go modules
The Go modules you install will most likely keep on getting worked on, but you'll only get the benefit of those once you update and recompile the associated repository. This takes a long time, so I've added a separate command `update-go-modules` that iterates through updating them.

## Updating Python modules
You can update all python pip modules across the system using `update-python-modules`. Be aware that this may introduce breaking changes for your Python scripts, which is why venv is your friend. Expect to get errors when you run this, since some packages are supplied by the system.

## Scripts
Lastly, this script will run each of the `.sh` or `.py` files in the `scripts` directory. If you add a script to this directory, make sure they can be run multiple times without causing a problem. You can use the following script that installs Google Chrome as a template:

``` sh
#!/bin/bash
GREEN="\033[1;32m"
ENDCOLOR="\e[0m"

# === Exit without proceeding if run in WSL ===
if [ -f /mnt/c/Windows/System32/wsl.exe ]; then
    exit 0
fi

# Check if Chrome is installed
if [ $(sudo dpkg-query -W -f='${Status}' google-chrome-stable 2>/dev/null | grep -c "ok installed") -eq 0 ]
then
    echo -ne $GREEN">>> "$ENDCOLOR; echo "Installing Google Chrome"
    cd ~
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo dpkg -i google-chrome-stable_current_amd64.deb
    rm -rf google-chrome-stable_current_amd64.deb
fi
```
