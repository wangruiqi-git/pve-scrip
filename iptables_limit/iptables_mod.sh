#!/bin/bash
LOGFILE="/root/pve-script/iptables_limit/log4"
sed -i 's/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/$public_ip/g' /root/pve-script/iptables_limit/iptable_limit.sh
