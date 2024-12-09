#!/bin/bash

#Directory the script is in (for later use)
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LOGFILE="$SCRIPTDIR/backup_qbit5w.log"
# Provides the 'log' command to simultaneously log to
# STDOUT and the log file with a single command
# NOTE: Use "" rather than \n unless you want a COMPLETELY blank line (no timestamp)
log() {
    # echo -e "$(date -u +%Y-%m-%d-%H%M)" "$1" >> "${LOGFILE}"
    if [ "$2" != "noecho" ]; then
        echo -e "$1"
    fi
}
#echo "">$LOGFILE
echo `date` > $LOGFILE
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

ID=`ps -ef | grep "natmap -s $stun_server -h $http_server -b 5" | grep -v "grep" | awk '{print $2}'`
for id in $ID  
do  
    kill -9 $id  
    echo "killed $id"  
done
log " natmap start"
# 0:qbit listen port  1:portainer  2:moviepolit  3:qbitweb  4:pve
# 5:ssh 6:nextcloud 7:iyuu
for n in {0..0} 
do
    num=$((RANDOM % 999 + 50000 + n * 1000))
    $SCRIPTDIR/natmap -s $stun_server -h $http_server -b $num -e $SCRIPTDIR/update.sh &
    sleep 5
done
ENDTIME=$(date +%s)
DURATION=$((ENDTIME - STARTTIME))

log "natmap end. cost $DURATION seconds"

