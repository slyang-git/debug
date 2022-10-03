#!/bin/bash

#加载文件
source /tmp/debug/lib/*.sh

# 默认先在机器的home目录下启动dlv，若启动不了，则说明需要安装配置
echo "+----------------------------------------------+"
echo "|               DLV Installer                  |"
echo "+----------------------------------------------+"

echo 'sssdffffffffff'
# 初始化变量
Port="8017"
Need_Upload_Flag=""
ProcessName=""

# 首先检查是否已经启动过dlv server，若已启动则无需再重复启动
PreCheck() {
  Echo_Red "ssss"
  pidofdlv=`pgrep -f "dlv attach"`
  if [ ! -z "${pidofdlv}" ]; then
    Echo_Yellow "👉 Dlv Server已经在 ${CurrentIP}:${Port} 运行了，可以查看/tmp/debug/dlv.log日志"
    echo
    exit 0
  fi
}

# 1、拉取dlv
Download_Dlv() {
  wget -r --progress=dot https://github.com/slyang-git/debug/raw/main/dlv/dlv -O /tmp/debug/dlv
  chmod u+x /tmp/debug/dlv
}
# 0、检查用户是否为 xiaoju
Check_User

PreCheck

Download_Dlv

if [ -z ${ProcessName} ]; then
  echo
  Echo_Red "👉 未能识别正在运行的Go服务进程, 请自行确认Go服务是否在本机器上运行状态"
  echo
  exit 0
fi


# 3、获取Golang服务进程ID
ProcessID=`supervisorctl pid twitter ${ProcessName}`
if [ "${ProcessID}" == "" ]; then
  Echo_Red "🔥 未找到服务 ${ProcessName} 的进程ID, 请确认输入的服务在正常运行状态"
  echo ""
  exit 1
fi
Echo_Green "👉 您要调试的Go服务名为: ${ProcessName}, 进程ID为: ${ProcessID}"

# 5、以attach的方式执行dlv
Start_Dlv ${Port} ${ProcessID}

echo