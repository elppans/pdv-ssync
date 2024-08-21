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

# shellcheck disable=SC2013
for IP in $(cat "$IPON"); do
    if ping -c 1 "$IP" >>/dev/null; then
        echo -e "\n$IP ON!"
        # shellcheck disable=SC2154
        "$pdvmod/ssh-keyscan.sh" "$IP" &>>/dev/null
        # Função para executar comandos SSH
        execute_ssh_commands() {
            local USER="$1"
            local PASSWORD="${PASSWORD:-$senha_criptografada}"
            export IP
            export senha_criptografada
            export ssh_options

            sshpass -p ""$senha_criptografada"" ssh ""$ssh_options"" "$USER"@"$IP" "
            echo \"$PASSWORD\" | sudo -S sed -i '/^PermitRootLogin prohibit-password/!b;/^#PermitRootLogin prohibit-password/b;s/^PermitRootLogin prohibit-password/#PermitRootLogin prohibit-password/' /etc/ssh/sshd_config; 
            echo \"$PASSWORD\" | sudo -S sh -c 'grep -q \"^PermitRootLogin yes$\" /etc/ssh/sshd_config || echo \"PermitRootLogin yes\" >> /etc/ssh/sshd_config'; 
            echo \"$PASSWORD\" | sudo -S systemctl restart sshd;
            " 2>>/dev/null
        }
        # Verifica a versão do Ubuntu e executa os comandos apropriados
        if sshpass -p ""$senha_criptografada"" ssh ""$ssh_options"" user@"$IP" "lsb_release -r | grep -q '16.04'" &>>/dev/null; then
            execute_ssh_commands user
        elif sshpass -p ""$senha_criptografada"" ssh ""$ssh_options"" zanthus@"$IP" "lsb_release -r | grep -q '22.04'"; then
            execute_ssh_commands zanthus
        else
            echo "Não foi possível verificar o sistema do IP \"$IP\""
        fi
    else
        echo -e "$IP OFF!"
    fi
done
