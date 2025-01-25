#!/bin/bash


network_info ()
{
names=$(ls /sys/class/net | grep -v ^lo$)
ips=$(ip addr show | grep 'inet ' | grep -v ' lo$' | awk '{print $2}')
macs=$(ip addr show | grep link/ | grep -v loopback | awk '{print $2}')
interfacestatus=$(ip addr show | grep 'state UP\|state DOWN\|state UNKNOWN' | grep -v ' lo:' | awk '{print $9}')
gateway=$(ip route | grep default | awk '{print $3}')
amount=$(ip addr show | grep 'inet ' | grep -v ' lo$' | wc -l)

for (( i = 0 ; i < $amount ; i++ )); do
  interfaces+="$(
  echo "Interface:   ${names[$i]}"
  echo "IP-address:  ${ips[$i]}"
  echo "Gateway:     $gateway"
  echo "MAC:         ${macs[$i]}"
  echo "Status:      ${interfacestatus[$i]}\n\n"
  )"
done

  dialog --title "Network Information" \
         --no-collapse \
         --msgbox "Computer name: $(hostname)\n\
         \n${interfaces//$'\n'/\\n}" 18 40
}

network_info