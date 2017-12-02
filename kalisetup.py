#!/usr/bin/env python3
import os

# Need to detect environment. Assuming WSL/Ubuntu for the moment.

commands = ['apt update',
            'apt upgrade -y',
            'apt install -y most pydf curl',
            'curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg',
            'mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg'
            'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
            'apt update && apt install code'
            ]

# tlp, tlp-rdw

for command in commands:
    cmdstring = command
    os.system(command)

choice = input("Install Web development Tools? (N/y)").
if choice == 'y':
    print("installing webdev tools")

    commands = ['apt install -y apache2',
            'apt install -y mysql-server',
            'service mysql start'
            'mysql_secure_installation',
            ]

    for command in commands:
    cmdstring = command
    os.system(command)

choice = input("Install nodejs? (n/y)").
if choice == 'y':
    print("installing nodejs")

    commands = ['curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -',
            'sudo apt install -y nodejs'
            ]

    for command in commands:
    cmdstring = command
    os.system(command)



    for command in commands:
    cmdstring = command
    os.system(command)

# Need to add lots of conditional stuff
