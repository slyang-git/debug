#!/bin/bash

# Set USER
USER=${USER:-$(id -u -n)}
HOME="${HOME:-$(getent passwd $USER | cut -d: -f6)}"

TMPPATH="/tmp/debug/lib"
mkdir -p $TMPPATH

wget -q --no-cache --progress=bar "https://raw.githubusercontent.com/slyang-git/debug/main/lib/lib.sh?${RANDOM}" -O $TMPPATH/lib.sh && chmod u+x $TMPPATH/*.sh && source $TMPPATH/*.sh

# install debug tool
set -u

Echo_Green "👉 Start installing debug..."
wget -q https://raw.githubusercontent.com/slyang-git/debug/main/debug -O /tmp/debug/debug \
&& chmod u+x /tmp/debug/debug

export PATH=$PATH:/tmp/debug >> ~/.bashrc

# echo "/tmp/debug" >> $PATH

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

For more information, please visit: https://www.baidu.com/
EOF
}

main() {
     usage
     exec "$SHELL" -l
}





main "$@" || exit 1