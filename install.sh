#!/bin/bash

tmpPath="/tmp/debug"
mkdir -p $tmpPath

wget -crq https://raw.githubusercontent.com/slyang-git/debug/main/lib/lib.sh -O $tmpPath/lib.sh

chmod u+x $tmpPath/*.sh
source $tmpPath/*.sh

usage
Echo_Red "hello"