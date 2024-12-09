#!/bin/sh -e
hostname=""
device="vmbr0"
token=""

WORKDIR=/root/pve-script/ddns-dynv6
file=${WORKDIR}/.dynv6.addr6
#logfile=${WORKDIR}/dynv6.log
logfile=/dev/null
[ -e $file ] && old=`cat $file`


#if [ `ls -l $logfile | awk '{print $5}' | grep -v "^$"` -gt $((10*100)) ];then
#rm $logfile
#fi
echo "===start====">>$logfile
date >>$logfile
if [ -z "$hostname" -o -z "$token" ]; then
  echo "Usage: token=<your-authentication-token> [netmask=64] $0 your-name.dynv6.net [device]">>$logfile
  exit 1
fi

if [ -z "$netmask" ]; then
  netmask=128
fi

if [ -n "$device" ]; then
  device="dev $device"
fi
address=$(ip -6 addr list scope global $device| grep -v " fd" | sed -n 's/.*inet6 \([0-9a-f:]\+\).*/\1/p' | head -n 1)

if [ -e /usr/bin/curl ]; then
  bin="curl -fsS"
elif [ -e /usr/bin/wget ]; then
  bin="wget -O-"
else
  echo "neither curl nor wget found">>$logfile
  exit 1
fi

if [ -z "$address" ]; then
  echo "no IPv6 address found">>$logfile
  exit 1
fi

# address with netmask
current=$address/$netmask
echo "$current">>$logfile

if [ "$old" = "$current" ]; then
  echo "IPv6 address unchanged">>$logfile
  exit
fi

# send addresses to dynv6
$bin "https://dynv6.com/api/update?hostname=$hostname&ipv6=$current&token=$token"
# $bin "https://ipv4.dynv6.com/api/update?hostname=$hostname&ipv4=auto&token=$token"

# save current address
echo $current > $file
echo $current
