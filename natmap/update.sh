#!/bin/sh

# Natter/NATMap
public_ip=$1   #223.65.186.182
public_port=$2 #2601
private_ip=$6  #"192.168.2.198"  
private_port=$4 #41010
protocol=$5
casenum=$(( ${private_port}/1000 ))
LOGFILE="/root/pve-script/natmap/backup.log"
LOGFILE2="/root/pve-script/natmap/backup_qbit5w.log"
qbitbranch="false"
appport=""
echo `date` >> $LOGFILE
case ${casenum} in
  41)
    sleep 2 
    appport="9443"
    echo "portainer($appport) Update https://$public_ip:$public_port " >> $LOGFILE
  ;;
  42)
    sleep 4
    appport="3000"
    echo "moviepolit($appport) Update http://$public_ip:$public_port " >> $LOGFILE
  ;;
  43)
    sleep 6
    appport="8080"
    echo "qbitweb($appport) Update http://$public_ip:$public_port " >> $LOGFILE
  ;;
  44)
    sleep 8
    appport="8006"
    echo "pve($appport) Update https://$public_ip:$public_port " >> $LOGFILE
  ;;
  45)
    sleep 10
    appport="22"
    echo "ssh($appport) Update $public_ip:$public_port " >> $LOGFILE
  ;;
  46)
    sleep 12
    appport="7680"
    echo "nextcloud($appport) Update http://$public_ip:$public_port  " >> $LOGFILE
    echo "$public_ip" >  /root/pve-script/iptables_limit/public_ip
    echo "$public_ip:$public_port" > /root/pve-script/iptables_limit/public_ipport
  ;;
  47)
    sleep 14
    appport="8780"
    echo "iyuu($appport) Update http://$public_ip:$public_port  " >> $LOGFILE
  ;;
  50)
    #echo "qbit: $public_ip:$public_port  $private_ip:$private_port" >> $LOGFILE
    qbitbranch="true"
  ;;
  *)
      exit
  ;;
esac
if [ "xfalse" = "x${qbitbranch}" ]; then
    # Use iptables to forward traffic.
    LINE_NUMBER=$(iptables -t nat -nvL PREROUTING --line-number | grep :$appport | head -n 1 | awk '{print $1}')
    if [ "${LINE_NUMBER}" != "" ]; then
        iptables -t nat -D PREROUTING $LINE_NUMBER
    fi
    iptables -t nat -I PREROUTING -p tcp --dport $private_port -j DNAT --to-destination $private_ip:$appport
    iptables -t nat -nvL PREROUTING --line-number | grep ${private_port} >> $LOGFILE
    echo "Done." >> $LOGFILE
    exit
fi

# qBittorrent.
qb_web_host=$private_ip
qb_web_port=""
qb_username=""
qb_password=""
echo `date` >>  $LOGFILE2
echo "Update qBittorrent listen port to ($public_ip:$public_port)..." >> $LOGFILE2

# Update qBittorrent listen port.
qb_cookie=$(curl -s -i --header "Referer: https://$qb_web_host:$qb_web_port" --data "username=$qb_username&password=$qb_password" http://$qb_web_host:$qb_web_port/api/v2/auth/login | grep -i set-cookie | cut -c13-48)
curl -X POST -b "$qb_cookie" -d 'json={"listen_port":"'$public_port'"}' "http://$qb_web_host:$qb_web_port/api/v2/app/setPreferences"

#echo "Update iptables..."

# Use iptables to forward traffic.
#LINE_NUMBER=$(iptables -t nat -nvL PREROUTING --line-number | grep ${private_port} | head -n 1 | awk '{print $1}')
echo "deleteing old iptable:"
echo `iptables -t nat -nvL PREROUTING --line-number | grep "tcp dpt:50"`
LINE_NUMBER=$(iptables -t nat -nvL PREROUTING --line-number | grep "tcp dpt:50" | head -n 1 | awk '{print $1}')
if [ "${LINE_NUMBER}" != "" ]; then
    iptables -t nat -D PREROUTING $LINE_NUMBER
fi
iptables -t nat -I PREROUTING -p tcp --dport $private_port -j DNAT --to-destination $qb_web_host:$public_port
iptables -t nat -nvL PREROUTING --line-number | grep ${private_port} >> $LOGFILE2
echo "Done." >> $LOGFILE2

