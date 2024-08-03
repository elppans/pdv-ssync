#!/bin/bash

# shellcheck source=/dev/null
source /usr/share/pdv-ssync/pdv_env

# shellcheck disable=SC2154
rm -rf "$iponpdv" >> /dev/null
# shellcheck disable=SC2154
rm -rf "$ipoffpdv" >> /dev/null

# shellcheck disable=SC2013
# shellcheck disable=SC2154
for IP in $(cat "$ipdv"); do
if ping -c 1 "$IP" >> /dev/null; then
	echo -e """$IP"" ON!"
	echo -e """$IP""" | tee -a "$iponpdv" >> /dev/null
 else
	echo -e """$IP"" OFF!"
	echo -e """$IP""" | tee -a "$ipoffpdv" >> /dev/null
fi
done

