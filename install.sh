#!/bin/bash

tmpPath="/tmp/debug/lib"
mkdir -p $tmpPath

wget -r -S -d --no-cache --progress=bar "https://raw.githubusercontent.com/slyang-git/debug/main/lib/lib.sh?${RANDOM}" -O $tmpPath/lib.sh

chmod u+x $tmpPath/*.sh
source $tmpPath/*.sh

# install debug tool
set -u

Echo_Green "👉 Start installing debug..."
mkdir -p /home/xiaoju/bin
wget -q https://raw.githubusercontent.com/slyang-git/debug/main/debug -O /tmp/debug/debug \
&& chmod u+x /tmp/debug/debug

Echo_Green "🎉 Debug installed successfully!"


usage() {
cat 1>&2 <<EOF
       __     __               
  ____/ /__  / /_  __  ______ _
 / __  / _ \/ __ \/ / / / __  /
/ /_/ /  __/ /_/ / /_/ / /_/ / 
\__,_/\___/_.___/\__,_/\__, /  
                      /____/   

debug is a tool for setup and running Go/PHP/Java/Python/C++ debugger.

Usage:
debug [flag] [command]

[Flags]
-h, --help  Show this help message.

Available Commands:
-------------------
dlv      setup dlv debugger for Go. 
xdebug   setup xdebug debugger for PHP. 
upload   upload PHP source files to remote host  
rsync    setup rsyc server for sync go binary file.
dbgp     setup xdebug dbgpProxy for PHP.

For more information, please visit: 
EOF
}

usage
