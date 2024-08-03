#!/bin/bash

# shellcheck source=/dev/null
source /usr/share/pdv-shell/pdv_env

# shellcheck disable=SC2154
if [[ -e "$pdvcripto" ]]; then
	. "$pdvcripto"
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
# shellcheck disable=SC2154
for IP in $(cat "$IPON"); do
if ping -c 1 "$IP" >> /dev/null; then
    echo -e "\n""$IP"" ON!"
    #Ubuntu 16.04
    sshpass -p "$senha_criptografada" ssh "$ssh_options" user@"$IP" "\
echo ""$senha_criptografada"" | sudo -S sed -i '/^PermitRootLogin prohibit-password/!b;/^#PermitRootLogin prohibit-password/b;s/^PermitRootLogin prohibit-password/#PermitRootLogin prohibit-password/' /etc/ssh/sshd_config; \
echo ""$senha_criptografada"" | sudo -S sh -c 'grep -q \"^PermitRootLogin yes$\" /etc/ssh/sshd_config || echo \"PermitRootLogin yes\" >> /etc/ssh/sshd_config'; \
echo ""$senha_criptografada"" | sudo -S systemctl restart sshd;" ||
    #Ubuntu 22.04
    sshpass -p zanthus ssh "$ssh_options" zanthus@"$IP" "\
printf ""$senha_criptografada"" | sudo -S sed -i '/^PermitRootLogin prohibit-password/!b;/^#PermitRootLogin prohibit-password/b;s/^PermitRootLogin prohibit-password/#PermitRootLogin prohibit-password/' /etc/ssh/sshd_config; \
printf ""$senha_criptografada"" | sudo -S sh -c 'grep -q \"^PermitRootLogin yes$\" /etc/ssh/sshd_config || echo \"PermitRootLogin yes\" >> /etc/ssh/sshd_config'; \
printf ""$senha_criptografada"" | sudo -S systemctl restart sshd;"
        else
    echo -e """$IP"" OFF!"
fi
done

