#!/usr/bin/env python3
import os

# Need to detect environment

commands = ['apt update',
            'apt upgrade -y',
            'apt install -y nodejs most pydf apache2',
            'apt install -y mysql-server',
            'service mysql start'
            'mysql_secure_installation',
            ]

# tlp, tlp-rdw

for command in commands:
    cmdstring = command
    os.system(command)

# Need to add lots of conditional stuff
