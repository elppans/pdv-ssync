#!/bin/bash

export pdvcripto="/usr/share/pdv-shell/pdv_cripto.sh"

if [[ -e "$pdvcripto" ]]; then
	. "$pdvcripto"
else
	echo "Falta arquivo de criptografia!"
	 exit 0
fi

if [ ! -e "$iponpdv" ]; then
        echo -e "Arquivo \""$iponpdv"\" nao existe!"
        exit 0
fi

for IP in $(cat "$iponpdv"); do
if ping -c 1 "$IP" >> /dev/null; then
echo -e ""$IP" ON!"
sshpass -p "$senha_criptografada" ssh $ssh_options root@"$IP"
 else
echo -e ""$IP" OFF!"
fi
done

