#!/bin/bash
set -Eeuo pipefail
trap "echo -e \"\033[1;31m[!] \e[0m Script error occured.\"" ERR

myfunc()
{
	# foo doesn't exist
	foo
}

myfunc
echo "bar"
