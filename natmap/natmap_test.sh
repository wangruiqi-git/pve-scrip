#!/bin/bash

#Directory the script is in (for later use)
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LOGFILE="$SCRIPTDIR/backup.log"
# Provides the 'log' command to simultaneously log to
# STDOUT and the log file with a single command
# NOTE: Use "" rather than \n unless you want a COMPLETELY blank line (no timestamp)
log() {
    # echo -e "$(date -u +%Y-%m-%d-%H%M)" "$1" >> "${LOGFILE}"
    if [ "$2" != "noecho" ]; then
        echo -e "$1"
    fi
}
# "stun.voip.blackberry.com"
#x "stun.miwifi.com"
#x "stun.cdnbye.com"
#x "stun.hitv.com"
# "stun.chat.bilibili.com"
# "stun.douyucdn.cn:18000"
# "fwa.lifesizecloud.com"
# "global.turn.twilio.com"
#y "turn.cloudflare.com"
# "stun.isp.net.au"
# "stun.nextcloud.com"
# "stun.freeswitch.org"
# "stun.voip.blackberry.com"
# "stunserver.stunprotocol.org"
# "stun.sipnet.com"
# "stun.radiojar.com"
# "stun.sonetel.com"
#array=("qq.com" "hao123.com" "sohu.com" "douban.com" "ifeng.com" 
#    "163.com" "iqiyi.com" "4366ga.com" "chsi.com.cn" "eastmoney.com" 
#    "ctrip.com" "sohu.com" "douyu.com" "9377j.com" "7k7k.com"
#    "17173.com" "gamersky.com" "4399.com" "8faa7.com" "faloo.com"
#    "680866.com" "huangye88.com" "diqiuw.com" "dekeego.com" "yiehua.cn"
#    "wixt.net" "080210.com" "4yx.com" "yuekenet.com" "g.wdkud6.com"
#    ) 
array=("github.com" "milkie.cc" "nextcloud.com" "ffmpeg.org")
arr_num=${#array[@]} 
stun_server="stun.voip.blackberry.com"
http_server="baidu.com"

ID=`ps -ef | grep "natmap -s $stun_server -h " | grep "-b 1"| grep -v "baidu" | grep -v "grep" | awk '{print $2}'`
for id in $ID  
do  
    kill -9 $id  
    echo "killed $id"  
done
exit
log " natmap start"
# 0:qbit listen port  1:portainer  2:moviepolit  3:qbitweb  4:pve
# 5:ssh 6:nextcloud 7:iyuu
for n in {0..3} 
do
    arr_indx=$n%$arr_num
    http_server=${array[$arr_indx]}
    num=$((RANDOM % 9 + 10000 + n * 10))
    $SCRIPTDIR/natmap -s $stun_server -b $num -h $http_server -e $SCRIPTDIR/update.sh &
    sleep 1
done

ENDTIME=$(date +%s)
DURATION=$((ENDTIME - STARTTIME))

log "natmap end. cost $DURATION seconds"

