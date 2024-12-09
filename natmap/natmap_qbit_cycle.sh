#!/bin/bash

#Directory the script is in (for later use)
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LOGFILE="$SCRIPTDIR/backup_cycle.log"
QBIT_PORT_FILE="$SCRIPTDIR/qbit_port"
# Provides the 'log' command to simultaneously log to
# STDOUT and the log file with a single command
# NOTE: Use "" rather than \n unless you want a COMPLETELY blank line (no timestamp)
log() {
    # echo -e "$(date -u +%Y-%m-%d-%H%M)" "$1" >> "${LOGFILE}"
    if [ "$2" != "noecho" ]; then
        echo -e "$1"
    fi
}
echo >$QBIT_PORT_FILE
#echo "">$LOGFILE
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

stun_server="stun.voip.blackberry.com"
http_server="baidu.com"
 
ID=`ps -ef | grep "natmap -s $stun_server -b 3" | grep -v "grep" | awk '{print $2}'`
for id in $ID  
do  
    kill -9 $id  
    echo "killed $id"  
done
# 0:qbit listen port  1:portainer  2:moviepolit  3:qbitweb  4:pve
# 5:ssh 6:nextcloud 7:iyuu
for n in {0..20} 
do
    num=$((RANDOM % 99 + 30000 + n * 100))
    $SCRIPTDIR/natmap -s $stun_server -b $num -h $http_server -e $SCRIPTDIR/update_qbit_cycle.sh &
    sleep 5
done
ENDTIME=$(date +%s)
DURATION=$((ENDTIME - STARTTIME))

log "natmap end. cost $DURATION seconds"

