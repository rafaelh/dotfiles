#!/usr/bin/env python3
import os

# Need to detect environment

commands = ['apt-get update',
            'apt-get upgrade -y',
            'apt-get install -y nodejs most',
            'apt-get install -y mysql-server',
            'service mysql start'
            'mysql_secure_installation',
            ]

for command in commands:
    cmdstring = command
    os.system(command)

# Need to add lots of conditional stuff
