#!/bin/bash

usage() {
    cat 1>&2 <<EOF
       __     __               
  ____/ /__  / /_  __  ______ _
 / __  / _ \/ __ \/ / / / __  /
/ /_/ /  __/ /_/ / /_/ / /_/ / 
\__,_/\___/_.___/\__,_/\__, /  
                      /____/   
  

debug is a tool for setup and running Go/PHP debugger.

Usage:
debug [flag] [command]

[Flags]
-h, --help  Show this help message.

Available Commands:
-------------------
dlv      setup dlv debugger for Go. 
xdebug   setup xdebug debugger for PHP. 
upload   upload PHP source files to SIM host  
rsync    setup rsyc server for sync go binary file.
dbgp     setup xdebug dbgpProxy for PHP.

For more information, please visit
EOF
}

usage