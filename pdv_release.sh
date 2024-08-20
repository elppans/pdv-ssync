#!/usr/bin/bash

# shellcheck source=/dev/null
source /usr/share/pdv-ssync/environment/pdv_env

# shellcheck disable=SC2154
if [ ! -e "$pdvcripto" ]; then
        echo "Falta arquivo de criptografia!"
        exit 0
fi

# shellcheck disable=SC2154
if [ ! -e ""$iponpdv"" ]; then
        echo -e "Arquivo \""""$ip"onpdv""\" nao existe!"
        exit 0
fi

# shellcheck disable=SC2013
# shellcheck disable=SC2154
# shellcheck disable=SC2140
for IP in $(cat "$iponpdv"); do
	if ping -c 1 "$IP" >>/dev/null; then
		echo -e """$IP"" ON!"
                echo "$senha_criptografada"
                echo "$ssh_options"
                exit
		sshpass -p "$senha_criptografada" ssh "$ssh_options" root@"$IP" "cat /etc/canoalinux-release" ||
			sshpass -p "$senha_criptografada" ssh "$ssh_options" user@"$IP" "cat /etc/canoalinux-release" ||
			sshpass -p "$senha_criptografada" ssh "$ssh_options" zanthus@"$IP" "cat /etc/canoalinux-release"
	else
		echo -e """$IP"" OFF!"
	fi
done
