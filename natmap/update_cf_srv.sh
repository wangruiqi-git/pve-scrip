#!/bin/sh

# Natter/NATMap
public_ip=$1   #223.65.186.182
public_port=$2 #2601
private_ip=$6  #"192.168.2.198"  
private_port=$4 #41010
protocol=$5
casenum=$(( ${private_port}/1000 ))
LOGFILE="/root/pve-script/natmap/backup_cf.log"
appport=""

# Cloudflare
zone_id="f"
email="f"
global="f"
a_id="f"
rulesets_id="f"
rule_id=""
external_domain=""
root_domain="f.com"

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
    external_domain="pve"
    rule_id="0"
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
    external_domain="nc"
    rule_id="1"
    echo "nextcloud($appport) Update http://$public_ip:$public_port  " >> $LOGFILE
  ;;
  47)
    sleep 14
    appport="8780"
    echo "iyuu($appport) Update http://$public_ip:$public_port  " >> $LOGFILE
  ;;
  *)
      exit
  ;;
esac
    
# Use iptables to forward traffic.
LINE_NUMBER=$(iptables -t nat -nvL PREROUTING --line-number | grep :$appport | head -n 1 | awk '{print $1}')
if [ "${LINE_NUMBER}" != "" ]; then
    iptables -t nat -D PREROUTING $LINE_NUMBER
fi
iptables -t nat -I PREROUTING -p tcp --dport $private_port -j DNAT --to-destination $private_ip:$appport
iptables -t nat -nvL PREROUTING --line-number | grep ${private_port} >> $LOGFILE

if [ "x${external_domain}" = "x" ]; then
    exit
fi
curl --request PATCH \
     --url https://api.cloudflare.com/client/v4/zones/${zone_id}/rulesets/${rulesets_id}/rules/${rule_id} \
     --header "Content-Type: application/json" \
     --header "X-Auth-Email: ${email}"  \
     --header "X-Auth-Key: ${global}" \
     --data '{
             "action": "redirect",
             "description": "'"${external_domain}"'",
             "expression": "(http.host eq \"'"${external_domain}"'.'"${root_domain}"'\")",
             "action_parameters": {
                 "from_value": {
                     "preserve_query_string": true,
                     "status_code": 301,
                     "target_url": {
                         "expression": "concat(\"http://'"${root_domain}"':'"$public_port"'\", http.request.uri.path)"
                     }
                 }
             }
     }'
exit
echo -e "Update A Record."
# Update A Record.
curl --request PATCH \
     --url https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records/${a_id} \
     --header "Content-Type: application/json" \
     --header "X-Auth-Email: ${email}"  \
     --header "X-Auth-Key: ${global}" \
     --data '{
             "type": "A",
             "name": "'"${root_domain}"'",
             "content": "'"${public_ip}"'"
             }'
 
