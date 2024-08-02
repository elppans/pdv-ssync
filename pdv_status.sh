#!/bin/bash

. /usr/share/pdv-shell/pdv_env

rm -rf "$iponpdv" >> /dev/null
rm -rf "$ipoffpdv" >> /dev/null

for IP in $(cat "$ipdv"); do
if ping -c 1 "$IP" >> /dev/null; then
	echo -e ""$IP" ON!"
	echo -e ""$IP"" | tee -a "$iponpdv" >> /dev/null
 else
	echo -e ""$IP" OFF!"
	echo -e ""$IP"" | tee -a "$ipoffpdv" >> /dev/null
fi
done

