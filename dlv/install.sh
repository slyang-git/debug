#!/bin/bash

#加载文件
source /tmp/debug/lib/*.sh

# 默认先在机器的home目录下启动dlv，若启动不了，则说明需要安装配置
echo "+------------------------------------------------------+"
echo "|               DLV Installer                          |"
echo "+------------------------------------------------------+"

# 初始化变量
Port="8017"
Need_Upload_Flag=""
ProcessName=""

# 首先检查是否已经启动过dlv server，若已启动则无需再重复启动
PreCheck() {
  pidofdlv=`pgrep -f "dlv attach"`
  if [ ! -z "${pidofdlv}" ]; then
    Echo_Yellow "👉 Dlv Server已经在 ${CurrentIP}:${Port} 运行了，可以查看/tmp/debug/dlv.log日志"
    echo
    exit 0
  fi
}


# 启动DLV Sever
Start_Dlv() {
  ProcessID=$2
  Echo_Green "👉 Dlv Server 监听在: ${CurrentIP}:${Port}, 请前往IDE（Goland、VS Code）完成相应配置" 
  Echo_Green "👉 Dlv Server日志路径: /tmp/debug/dlv.log, 可以通过查看日志进行排查问题"
  Echo_Yellow "🎉🎉🎉 You Are Ready to Go :-), Happy Debugging! 🎉🎉🎉"
  echo ""
  nohup dlv attach ${ProcessID} --listen=:${Port} --headless --accept-multiclient --continue --api-version=2 --log --log-output=rpc,dap,debugger >> /tmp/dlv.log 2>&1 &
}


# 0、检查用户是否为 xiaoju
Check_User

PreCheck

# 1、拉取dlv
Download_Dlv() {
  wget -q https://github.com/slyang-git/debug/raw/main/dlv/dlv -O /tmp/debug/dlv
  chmod u+x /tmp/debug/dlv
}

Download_Dlv

# 先自动识别Go服务名，若未成功识别，则让用户手动输入
# processes=`supervisorctl status | awk '{print $1}'`
# for process in $processes
# do
#   if [ $process = 'cron' ]; then
#     continue
#   else
#     # 兼容dsim环境服务名后缀带-simxxx的问题
#     process=`echo ${process} | sed -e "s/-sim[0-9][0-9][0-9]//g"`
#     # 兼容osim环境服务名后缀带-dsimxxx的问题
#     process=`echo ${process} | sed -e "s/-osim[0-9][0-9][0-9]//g"`
#     # 兼容price-api-hna-sim133这种服务名case（带有hna这种集群信息）
#     process=`echo ${process} | sed -e "s/-hna//g"`
#     # 兼容biz-dds-hna-sim168这种服务名case（前面带有biz-）
#     process=`echo ${process} | sed -e "s/biz-//g"`
#     # 兼容taxi-order-sync-online-sim176 中的online字符串
#     process=`echo ${process} | sed -e "s/-online//g"`

#     ProcessName=$process
#     break
#   fi
# done

if [ -z ${ProcessName} ]; then
  echo
  Echo_Red "👉 未能识别正在运行的Go服务进程, 请自行确认Go服务是否在本机器上运行状态"
  echo
  exit 0
fi

# 让用户确认需要调试的服务名（默认是智能识别，若识别错误，用户自己输入服务名）
Echo_Green "👉 您要调试的Go服务是否是 ${ProcessName}? (y/n):"
read choice
if [ $choice = 'n' ] || [ $choice = 'N' ] || [ $choice = 'no' ]; then
  Echo_Yellow "👉 以下为当前运行状态的进程信息:"
  # ps aux |  awk '{print $2,$11}' | grep xiaoju | grep -v ps | grep -v awk | grep -v grep | grep -v bash
  ps aux |  awk 'BEGIN { printf "%-10s  %-10s  %-30s\n", "User", "PID", "Process" 
                         printf "%-10s  %-10s  %-30s\n", "------", "-------", "-------" }
                { printf "%-10s %-10s  %-30s\n", $1, $2, $11 }' | grep -v root | grep -v nobody | grep -v ps | grep -v awk | grep -v grep | grep -v bash | grep -v su | grep -v COMMAND | grep -v USER

  echo
  read -rp "👉 请输入以上罗列的需要调试的进程PID(只能选一个PID): " ProcessID
  if [ "${ProcessID}" = "" ]; then
    Echo_Red "🔥 Golang服务PID不能为空, 请确认Golang服务名后重新执行"
    echo ""
    exit 1
  fi
fi

# 3、获取Golang服务进程ID
ProcessID=`pidof -s ${ProcessName}`
if [ "${ProcessID}" == "" ]; then
  Echo_Red "🔥 未找到服务 ${ProcessName} 的进程ID, 请确认输入的服务在正常运行状态"
  echo ""
  exit 1
fi
Echo_Green "👉 您要调试的Go服务名为: ${ProcessName}, 进程ID为: ${ProcessID}"

# 5、以attach的方式执行dlv
Start_Dlv ${Port} ${ProcessID}

echo