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

# Verifica se o diretório existe
if [ ! -d "$descanso" ]; then
    echo "O diretório $descanso não existe."
    exit 1
fi

# Verifica se o diretório está vazio
if [ ! "$(ls -A $descanso)" ]; then
    echo "O diretório $descanso está vazio."
    exit 1
fi

for IP in $(cat "$iponpdv"); do
if ping -c 1 "$IP" >> /dev/null; then
echo -e ""$IP" ON!"
# Copia via SSH
#sshpass -p zanthus scp -o StrictHostKeyChecking=no -r /opt/descanso/* root@"$IP":/Zanthus/Zeus/pdvJava/pdvGUI/guiConfigProj/
sshpass -p "$senha_criptografada" rsync $rsync_options "ssh $ssh_options" "$descanso"/ root@"$IP":"$guiconfigproj"/
 else
echo -e ""$IP" OFF!"
fi
done

