#!/bin/sh

# Natter/NATMap
public_ip=$1   #223.65.186.182
public_port=$2 #2601
private_ip=$6  #"192.168."  
private_port=$4 #41010
protocol=$5
LOGFILE="/root/pve-script/natmap/backup_cycle.log"
QBIT_PORT_FILE="/root/pve-script/natmap/qbit_port"
echo "$private_port,$public_port">>$QBIT_PORT_FILE 
#LINE_NUMBER=$(iptables -t nat -nvL PREROUTING --line-number | grep "tcp dpt:40" | head -n 1 | awk '{print $1}')
#if [ "${LINE_NUMBER}" != "" ]; then
#    iptables -t nat -D PREROUTING $LINE_NUMBER
#fi
 
