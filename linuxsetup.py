#!/usr/bin/env python3
import os

# Need to detect environment. Assuming WSL/Ubuntu for the moment.

commands = ['apt update',
            'apt upgrade -y',
            'apt install -y nodejs most pydf curl',
            ]

# tlp, tlp-rdw

for command in commands:
    cmdstring = command
    os.system(command)

webdevchoice = input("Install Web development Tools? (N/y)").

if webdevchoice == 'y':
    print("installing webdev tools")

    commands = ['apt install -y apache2',
            'apt install -y mysql-server',
            'service mysql start'
            'mysql_secure_installation',
            ]

    for command in commands:
    cmdstring = command
    os.system(command)

# Need to add lots of conditional stuff
