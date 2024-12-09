#!/bin/bash
QBIT_PORT="/root/pve-script/natmap/qbit_port"
LOGFILE="/root/pve-script/natmap/qbitlog"
port_pri=($(awk -F ',' '{print $1}' $QBIT_PORT))
port_pub=($(awk -F ',' '{print $2}' $QBIT_PORT))
deliptable()
{
    LINE_NUMBER=$(iptables -t nat -nvL PREROUTING --line-number | grep "tcp dpt:3" | head -n 1 | awk '{print $1}')
    while  [ "${LINE_NUMBER}" != "" ]
    do
       iptables -t nat -D PREROUTING $LINE_NUMBER
       LINE_NUMBER=$(iptables -t nat -nvL PREROUTING --line-number | grep "tcp dpt:3" | head -n 1 | awk '{print $1}')
    done
    LINE_NUMBER=$(ip6tables -t nat -nvL PREROUTING --line-number | grep "tcp dpt:" | head -n 1 | awk '{print $1}')
    while  [ "${LINE_NUMBER}" != "" ]
    do
       ip6tables -t nat -D PREROUTING $LINE_NUMBER
       LINE_NUMBER=$(ip6tables -t nat -nvL PREROUTING --line-number | grep "tcp dpt:" | head -n 1 | awk '{print $1}')
    done
}
addiptable()
{
    public_port=${port_pub[$1]}
    echo "working at pri:${port_pri[$1]} to pub:${port_pub[$1]}" >> $LOGFILE
    for private_port in "${port_pri[@]}"
    do
        #echo "iptable add pri:$private_port to pub:$public_port" >> $LOGFILE
        iptables  -t nat -I PREROUTING -p tcp --dport $private_port -j DNAT --to-destination $qb_web_host:$public_port
    done
    
    for public_port_it in "${port_pub[@]}"
    do
        #echo "ip6table add $public_port_it to $public_port" >> $LOGFILE
        ip6tables -t nat -I PREROUTING -p tcp --dport $public_port_it -j DNAT --to-destination [$localipv6]:$public_port
    done
}
i=0
private_ip=""
qb_web_host=$private_ip
qb_web_port=""
qb_username=""
qb_password=""
echo "" > $LOGFILE
while true
do
  echo `date` >> $LOGFILE
  localipv6=`cat /root/pve-script/ddns-dynv6/.dynv6.addr6 | cut -d '/' -f 1`
  i=$[$i+1]
  arr_num=${#port_pri[@]}
  num=$(($i%$arr_num))
  deliptable
  addiptable $num 

  # Update qBittorrent listen port.
  qb_cookie=$(curl -s -i --header "Referer: https://$qb_web_host:$qb_web_port" --data "username=$qb_username&password=$qb_password" http://$qb_web_host:$qb_web_port/api/v2/auth/login | grep -i set-cookie | cut -c13-48)
  curl -X POST -b "$qb_cookie" -d 'json={"listen_port":"'$public_port'"}' "http://$qb_web_host:$qb_web_port/api/v2/app/setPreferences"
  sleep 720 
done
