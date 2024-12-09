#!/bin/bash
LOGFILE="/root/pve-script/ip6tables_limit/log6"
deliptable()
{
    LINE_NUMBER=$(ip6tables -nvL OUTPUT --line-number | grep "$dst" | head -n 1 | awk '{print $1}')
    #LINE_NUMBER=$(iptables -nvL OUTPUT --line-number | grep "$dst" | head -n 1 | awk '{print $1}')
    if [ "${LINE_NUMBER}" != "" ]; then
       ip6tables -D OUTPUT  $LINE_NUMBER
       #iptables -D OUTPUT  $LINE_NUMBER
    fi
}
addiptable()
{
    nextspeed="$1"
    #echo "iptable add pri:$private_port to pub:$public_port" >> $LOGFILE
    ip6tables -I OUTPUT -d $dst -m hashlimit --hashlimit-above ${nextspeed}kb/s --hashlimit-mode dstip --hashlimit-name out -j DROP
    #  iptables -I OUTPUT -d $dst -m hashlimit --hashlimit-above ${nextspeed}kb/s --hashlimit-mode dstip --hashlimit-name out -j DROP
}
echo "" > $LOGFILE
dst="2409:8a70:513d:8930::18"
#dst="223.65.186.185"
cur_speed="0"
while true
do
  echo `date` >> $LOGFILE
  tmp_total="`iftop  -P -i enp7s0f0  -B -m 120M -t -s 15 |grep "Total send rate:" | awk '{print $5}'`"
  cur_total=$(echo "$tmp_total" | sed 's/.\{2\}$//')
  if [ "`echo "$tmp_total"| grep "MB"`" != "" ]; then
      cur_total=$(echo "scale=0;$cur_total * 1024" | bc)
  fi
  cur_total=`echo "$cur_total" | awk -F '.' '{print $1}'`
  qit_used=$cur_total
  if [ "$cur_total" -gt "$cur_speed" ]; then
      qit_used=$(($cur_total - $cur_speed))
  fi
  echo "qit_used $qit_used" >> $LOGFILE
  if [ "$qit_used" -gt "10000" ]; then
      qit_used="10000"
  fi
  if [ "$qit_used" -lt "3000" ]; then
      qit_used="3000" 
  fi
  next_speed=$(((10001 - $qit_used) / 2000 * 2000))
  if [ "$next_speed" -eq "0" ]; then
      next_speed="100"
  fi
  echo "curtotal:$tmp_total=$cur_total curlim:$cur_speed qbit:$qit_used nextlim:$next_speed " >> $LOGFILE
  if [ "$next_speed" -eq "$cur_speed" ]; then
      sleep 300
      continue 
  fi
  deliptable
  addiptable $next_speed 
  cur_speed=$next_speed
  sleep 180 
done
