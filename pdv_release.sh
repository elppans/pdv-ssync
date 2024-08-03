#!/bin/bash

# shellcheck source=/dev/null
source /usr/share/pdv-shell/pdv_env

# shellcheck disable=SC2154
if [[ -e "$pdvcripto" ]]; then
	source "$pdvcripto"
else
	echo "Falta arquivo de criptografia!"
	 exit 0
fi

# shellcheck disable=SC2154
if [ ! -e "$iponpdv" ]; then
        echo -e "Arquivo \"""$iponpdv""\" nao existe!"
        exit 0
fi

# shellcheck disable=SC2013
# shellcheck disable=SC2154
# shellcheck disable=SC2140
for IP in $(cat "$iponpdv"); do
if ping -c 1 "$IP" >> /dev/null; then
echo -e """$IP"" ON!"
sshpass -p "$senha_criptografada" ssh "$ssh_options" root@"$IP" "grep DISTRIB_RELEASE /etc/lsb-release | cut -f "2" -d "="" || \
sshpass -p "$senha_criptografada" ssh "$ssh_options" user@"$IP" "grep DISTRIB_RELEASE /etc/lsb-release | cut -f "2" -d "="" || \
sshpass -p "$senha_criptografada" ssh "$ssh_options" zanthus@"$IP" "grep DISTRIB_RELEASE /etc/lsb-release | cut -f "2" -d "=""
 else
echo -e """$IP"" OFF!"
fi
done

