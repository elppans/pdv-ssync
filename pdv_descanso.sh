#!/usr/bin/bash

# shellcheck source=/dev/null
source /usr/share/pdv-ssync/environment/pdv_env

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

# Verifica se o diretório existe
# shellcheck disable=SC2154
if [ ! -d "$descanso" ]; then
    echo "O diretório $descanso não existe."
    exit 1
fi

# Verifica se o diretório está vazio
if [ ! "$(ls -A "$descanso")" ]; then
    echo "O diretório $descanso está vazio."
    exit 1
fi

# shellcheck disable=SC2013
for IP in $(cat "$iponpdv"); do
    if ping -c 1 "$IP" >>/dev/null; then
        echo -e """$IP"" ON!"
        # shellcheck disable=SC2154
        "$pdvmod/ssh-keyscan.sh" """$IP""" &>>/dev/null
        # Copia via SSH
        #sshpass -p zanthus scp -o StrictHostKeyChecking=no -r /opt/descanso/* root@"$IP":/Zanthus/Zeus/pdvJava/pdvGUI/guiConfigProj/
        # shellcheck disable=SC2154
        echo -e "senha_criptografada=$senha_criptografada"
        echo -e "rsync_options=$rsync_options"
        echo -e "ssh_options=$ssh_options" 
        echo -e "descanso=$descanso"
        echo -e "IP=$IP"
        echo -e "guiconfigproj=$guiconfigproj"
        exit
        sshpass -p "$senha_criptografada" rsync "$rsync_options" ssh "$ssh_options" "$descanso"/ root@"$IP":"$guiconfigproj"/
    else
        echo -e """$IP"" OFF!"
    fi
done
