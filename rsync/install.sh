#!/bin/bash

set -u

curl -s https://git.xiaojukeji.com/yangshuanglong/sim-debug/raw/master/lib/download_require_file.sh | bash
source /home/xiaoju/bin/tool-lib/*.sh

echo "+--------------------------------------------------------+"
echo "|                    debug rsync                         |"
echo "+--------------------------------------------------------+"
echo "|          Manual 👉 https://z.didi.cn/rsync             |"
echo "+--------------------------------------------------------+"
echo ""

Check_User

Start_Rsync() {
  # 杀掉dlv进程，否则会导致重启进程时卡死
  pkill dlv

  rm -rf ${WorkPath}/rsync.pid

  Echo_Green "👉 正在启动rsync server服务..."
  rsync --daemon --config=${WorkPath}/rsync.conf

  Echo_Green "✅ 成功启动rsync server服务, 监听在: ${CurrentIP}:${ListenPort}"
  echo
  Echo_Green "👉 请按如下步骤在你【本地机器】上编译Go服务和上传编译后的Go二进制文件："
  Echo_Yellow "    1) 编译Go服务: GOOS=linux GOARCH=amd64 go build -gcflags=all='-N -l' -o ${ProcessName}"
  Echo_Yellow "    2) 上传编译后的Go二进制文件: rsync -avzP --port 8014 ${ProcessName} xiaoju@${CurrentIP}::xiaoju"
  echo
}

Stop_Rsync() {
  pkill rsync & Echo_Green "👋 rsync service stopped, bye~"
  exit 0
}

WorkPath=''
ListenPort=8014
ProcessName=''

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
  elif [ $process = 'kms-agent' ]; then
    continue
  elif [ $process = 'common-go' ]; then
    ProcessName='common'
    break
  elif [ $process = 'goapi' ]; then
    OriginalProcessName=${process}
    ProcessName='horizons'
    break
  elif [[ "$process" == *"pre-sale-core"* ]]; then
    OriginalProcessName=${process}
    ProcessName='mamba'
  else
    OriginalProcessName=${process}
    # 兼容dsim环境服务名后缀带-simxxx的问题
    process=`echo ${process} | sed -e "s/-sim[0-9][0-9][0-9]//g"`
    # 兼容osim环境服务名后缀带-dsimxxx的问题
    process=`echo ${process} | sed -e "s/-osim[0-9][0-9][0-9]//g"`
    # 兼容price-api-hna-sim133这种服务名case（带有hna这种集群信息）
    process=`echo ${process} | sed -e "s/-hna//g"`

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
    # 兼容passenger-center-go-pre 中末尾带pre字符串
    process=`echo ${process} | sed -e "s/-pre//g"`
    # 兼容compensation-hnb 中末尾的 -hnb字符串
    process=`echo ${process} | sed -e "s/-hnb//g"`

    ProcessName=$process
    break
  fi
done

WorkPath="/home/xiaoju/${ProcessName}/bin"
Echo_Green "👉 经系统识别，您要调试的Go服务为: ${ProcessName} "


# generate rsync.conf
Echo_Green "👉 应用程序目录：${WorkPath}"
mkdir -p ${WorkPath}
echo "address=${CurrentIP}
port=8014
log file=${WorkPath}/rsync.log
pid file=${WorkPath}/rsync.pid
use chroot = no
[xiaoju]
path=${WorkPath}
read only=no
max connections=0" > ${WorkPath}/rsync.conf

Start_Rsync


# 增加识别Ctrl + C事件
trap Stop_Rsync SIGINT


### Set initial time of file
# 兼容pbd-flow服务
if [ $ProcessName = 'pbd-flow' ]; then
  ProcessName='pbd_flow'
fi
LTIME=`stat -c %Z ${WorkPath}/${ProcessName}`
Echo_Green "👉 持续监测Go应用程序二进制文件: ${WorkPath}/${ProcessName} 的变化"

# 持续检测服务二进制文件的变化，若文件发送变更，则立即重启服务，让最新的代码生效
while true    
do
  ATIME=`stat -c %Z ${WorkPath}/${ProcessName}`

  if [[ "${ATIME}" != "${LTIME}" ]]
  then   
      # 杀掉dlv进程，否则会导致重启进程时卡死 
      pkill dlv
      Echo_Green "👉 发现 ${WorkPath}/${ProcessName} 文件发生变更，准备重启该服务..."
      # supervisorctl restart ${OriginalProcessName}
      supervisorctl stop $OriginalProcessName && supervisorctl start $OriginalProcessName
      status=$?
      [ $status -eq 0 ] && echo "✅ 服务重启成功" || echo "❌ 服务重启失败"

      # 上面先把dlv server kill掉了，这里重新启动
      ProcessID=`pidof ${ProcessName}`
      nohup dlv attach ${ProcessID} --listen=:8017 --headless --accept-multiclient --continue --api-version=2 --log --log-output=rpc,dap,debugger >> /tmp/dlv.log 2>&1 &
      Echo_Green "👉 持续监测Go应用程序: ${WorkPath}/${ProcessName} 的变化，若有变更将自动重启服务"
      LTIME=$ATIME
  fi
  sleep 2
done
