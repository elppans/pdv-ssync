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

IPON=${IPON:-$iponpdv}
export ssh_options="${ssh_options} -t"

if [ ! -e "$IPON" ]; then
    echo -e "Arquivo \"""$IPON""\" nao existe!"
    exit 0
fi

# Função para executar comandos SSH
execute_ssh_commands() {
    local IP=$1
    local USER=$2
    local PASSWORD=$3
    local SSH_OPTIONS=$4

    sshpass -p "$PASSWORD" ssh ""$SSH_OPTIONS"" "$USER@$IP" "lsb_release -a"
}

# shellcheck disable=SC2013
for IP in $(cat "$IPON"); do
    if ping -c 1 "$IP" >>/dev/null; then
        echo -e "\n$IP ON!"
        # shellcheck disable=SC2154
        "$pdvmod/ssh-keyscan.sh" "$IP" &>>/dev/null
        execute_ssh_pdv16() {
            export IP
            export senha_criptografada
            export ssh_options

            sshpass -p ""$senha_criptografada"" ssh ""$ssh_options"" user@"$IP" "echo OKOK"
        }

        execute_ssh_pdv22() {
            export IP
            export senha_criptografada
            export ssh_options
            
            execute_ssh_commands "$IP" "zanthus" ""$senha_criptografada"" ""$ssh_options""
        }
        # Verifica a versão do Ubuntu e executa os comandos apropriados
        if sshpass -p ""$senha_criptografada"" ssh ""$ssh_options"" user@"$IP" "lsb_release -r | grep -q '16.04'"; then
            execute_ssh_pdv16
            # echo "Ubuntu 16"
            # exit
        elif sshpass -p ""$senha_criptografada"" ssh ""$ssh_options"" zanthus@"$IP" "lsb_release -r | grep -q '22.04'"; then
            execute_ssh_pdv22
        else
            echo "Não foi possível verificar o sistema do IP \"$IP\""
        fi
    else
        echo -e "$IP OFF!"
    fi
done
