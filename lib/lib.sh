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

CurrentIP=`ifconfig eth0 | grep inet | awk '{print $2}' | sed -e "s/addr://g"`
