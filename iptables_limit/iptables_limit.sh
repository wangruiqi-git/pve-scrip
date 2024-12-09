#!/bin/bash
LOGFILE="/root/pve-script/iptables_limit/log4"
WORKDIR="/root/pve-script/iptables_limit"
deliptable()
{
    #LINE_NUMBER=$(ip6tables -nvL OUTPUT --line-number | grep "$dst_done" | head -n 1 | awk '{print $1}')
    LINE_NUMBER=$(iptables -nvL OUTPUT --line-number | grep "$dst_old" | head -n 1 | awk '{print $1}')
    if [ "${LINE_NUMBER}" != "" ]; then
       #ip6tables -D OUTPUT  $LINE_NUMBER
       iptables -D OUTPUT  $LINE_NUMBER
    fi
}
addiptable()
{
    nextspeed="$1"
    #echo "iptable add pri:$private_port to pub:$public_port" >> $LOGFILE
    #ip6tables -I OUTPUT -d $dst -m hashlimit --hashlimit-above ${nextspeed}kb/s --hashlimit-mode dstip --hashlimit-name out -j DROP
    iptables -I OUTPUT -d $dst -m hashlimit --hashlimit-above ${nextspeed}kb/s --hashlimit-mode dstip --hashlimit-name out -j DROP
    if [ "x$dst" != "x$dst_old" ]; then
        echo $dst >  $WORKDIR/public_ip_old
    fi
}
redeploy_container()
{
    if [ "x$ipport" != "x$ipport_old" ]; then
        docker container stop d-zhuxian
        sleep 10
        docker container rm d-zhuxian
        sleep 10
        url="http://$ipport/index.php/s/kEKPfQZ2s7pKNjy/download/DJI_0072.MP4"
        docker run -d  --name=d-zhuxian --net=host  -e url=$url developer024/networkdownload
        echo $ipport >  $WORKDIR/public_ipport_old
        echo "redepoly old$dst_old new$dst old$ipport_old new$ipport" >> $LOGFILE
        
    fi
}
#dst="2409:8a70:513d:8930:be24:11ff:feaf:3f04"
cur_speed="10"
count="0"
while true
do
  dst_old=`cat $WORKDIR/public_ip_old`
  dst=`cat $WORKDIR/public_ip`
  ipport_old=`cat $WORKDIR/public_ipport_old`
  ipport=`cat $WORKDIR/public_ipport`
  echo `date` >> $LOGFILE
  tmp_total="`iftop  -P -i enp7s0f0  -B -m 120M -t -s 30 |grep "Total send rate:" | awk '{print $5}'`"
  cur_total=$(echo "$tmp_total" | sed 's/.\{2\}$//')
  if [ "`echo "$tmp_total"| grep "MB"`" != "" ]; then
      cur_total=$(echo "scale=0;$cur_total * 1024" | bc)
  fi
  cur_total=`echo "$cur_total" | awk -F '.' '{print $1}'`
#################################  
  if [ "$cur_total" -lt "$cur_speed" ]; then
      echo "err sleep " >> $LOGFILE
      cur_speed="10"
      sleep 200
      continue
  fi
  qit_ori=$(($cur_total - $cur_speed))
  qit_mod=$qit_ori
  if [ "$qit_ori" -gt "8000" ]; then
      qit_mod="8000"
  fi
##################################
  next_speed=$(((8001 - $qit_mod) / 2000 * 2000 + 1000))
  if [ "$next_speed" -lt "1001" ] && [ "$cur_speed" -lt "1001" ] ; then
      next_speed=$cur_speed  
      if [ "$qit_ori" -lt "8001" ]; then
          next_speed="2000"
      fi
      if [ "$count" -gt "4" ] && [ "$qit_ori" -gt "12000" ]; then
          next_speed=$(($cur_speed - 100))
      fi
  fi
####################################
  if [ "$next_speed" -lt "299" ]; then
      next_speed=300
  fi
  if [ "$next_speed" -gt "8000" ]; then
      next_speed=8000
  fi
####################################
  echo "curtotal:$tmp_total=$cur_total curlim:$cur_speed qbit:$qit_ori nextlim:$next_speed cnt:$count" >> $LOGFILE
###################################
  if [ "$next_speed" -eq "$cur_speed" ]; then
      count=$(($count + 1))
      sleep 210
      continue 
  fi
####################################
  deliptable
  addiptable $next_speed
  redeploy_container
  cur_speed=$next_speed
  count="0"

  sleep 90 
done
