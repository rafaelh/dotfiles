#!/bin/bash
set -Eeuo pipefail
trap "echo -e \"\033[1;31m[!] \e[0mScript error occured in $0 on line $LINENO.\"" ERR

myfunc()
{
	# foo doesn't exist
	foo
}

myfunc
echo "bar"
