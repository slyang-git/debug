#!/bin/bash

Red='\033[0;31m'
NC='\033[0m'

Color_Text()
{
  echo -e " \e[0;$2m$1\e[0m"
}

Echo_Red()
{
#   echo $(Color_Text "$1" "31")
  printf "${Red}$1${NC}\n"

}

Echo_Green()
{
  echo $(Color_Text "$1" "32")
}

Echo_Yellow()
{
  echo $(Color_Text "$1" "33")
}

Echo_Blue()
{
  echo $(Color_Text "$1" "34")
}


Check_User()
{
    if [ `whoami` != "xiaoju" ]; then
      Echo_Red ""
      exit 1
    fi
}

Press_Start()
{
    Echo_Green "👉 Press any key to start...or Press Ctrl+c to cancel"
    OLDCONFIG=$(stty -g)
    stty -icanon -echo min 1 time 0
    dd count=1 2>/dev/null
    stty ${OLDCONFIG}
}

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

CurrentIP=`ifconfig eth0 | grep inet | awk '{print $2}' | sed -e "s/addr://g"`
