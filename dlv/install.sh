#!/bin/bash

#下载库文件
curl -sSfL https://git.xiaojukeji.com/yangshuanglong/sim-debug/raw/master/lib/download_reuire_file.sh | bash

#加载文件
source /home/xiaoju/bin/tool-lib/*.sh

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

Check_Need_Upload_Custom_File()
{
  read -rp "👉 (测试功能)请确定是否需要上传自定义二进制文件 [Y/N] (default:N): " Need_Upload_Flag
}


# 0、检查用户是否为 xiaoju
Check_User

PreCheck

# 1、拉取dlv
Download_Dlv() {
  wget -q https://git.xiaojukeji.com/yangshuanglong/sim-debug/raw/master/dlv/dlv -O /home/xiaoju/bin/dlv
  chmod u+x /home/xiaoju/bin/dlv
}

Download_Dlv

# 先自动识别Go服务名，若未成功识别，则让用户手动输入
processes=`supervisorctl status | awk '{print $1}'`
for process in $processes
do
  if [ $process = 'cron' ]; then
    continue
  elif [ $process = 'dnsmasq' ]; then
    continue
  elif [ $process = 'proftpd' ]; then
    continue
  elif [ $process = 'common-go' ]; then
    ProcessName='common'
    break
  elif [[ "$process" == *"pre-sale-core"* ]]; then
    ProcessName='mamba'
  else
    # 兼容dsim环境服务名后缀带-simxxx的问题
    process=`echo ${process} | sed -e "s/-sim[0-9][0-9][0-9]//g"`
    # 兼容osim环境服务名后缀带-dsimxxx的问题
    process=`echo ${process} | sed -e "s/-osim[0-9][0-9][0-9]//g"`
    # 兼容price-api-hna-sim133这种服务名case（带有hna这种集群信息）
    process=`echo ${process} | sed -e "s/-hna//g"`
    # 兼容biz-dds-hna-sim168这种服务名case（前面带有biz-）
    process=`echo ${process} | sed -e "s/biz-//g"`
    # 兼容taxi-order-sync-online-sim176 中的online字符串
    process=`echo ${process} | sed -e "s/-online//g"`

    ProcessName=$process
    break
  fi
done

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
  # 罗列xiaoju账号下当前所有运行状态的进程信息
  Echo_Yellow "👉 以下为所有xiaoju账号下当前运行状态的进程信息:"
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

if [ $choice = 'y' ]; then
  # 判断机器是否开启流量录制功能，若开启，需要在服务名后添加后缀-recorder
  if [[ -z ${DIDIENV_DDCLOUD_TRAFFIC_RECORD} && ${DIDIENV_DDCLOUD_TRAFFIC_RECORD} == "on" ]]; then
    ProcessName="${ProcessName}-recorder"
  fi

  # 3、获取Golang服务进程ID
  ProcessID=`pidof -s ${ProcessName}`
  if [ "${ProcessID}" == "" ]; then
    Echo_Red "🔥 未找到服务 ${ProcessName} 的进程ID, 请确认输入的服务在正常运行状态"
    echo ""
    exit 1
  fi
  Echo_Green "👉 您要调试的Go服务名为: ${ProcessName}, 进程ID为: ${ProcessID}"
fi

# 5、以attach的方式执行dlv
Start_Dlv ${Port} ${ProcessID}

echo