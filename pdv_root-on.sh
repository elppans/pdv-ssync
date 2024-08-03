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
for IP in $(cat "$IPON"); do
if ping -c 1 "$IP" >> /dev/null; then
    echo -e """$IP"" ON!"
    #Ubuntu 16.04
    # shellcheck disable=SC2154
    sshpass -p "$senha_criptografada" ssh "$ssh_options" user@"$IP" "\
printf '%s\n' 'zanthus' | sudo -S sh -c 'echo \"user ALL=(ALL) NOPASSWD: ALL\" >> /etc/sudoers'; \
sudo sed -i '/^PermitRootLogin prohibit-password/!b;/^#PermitRootLogin prohibit-password/b;s/^PermitRootLogin prohibit-password/#PermitRootLogin prohibit-password/' /etc/ssh/sshd_config; \
sudo sh -c 'grep -q \"^PermitRootLogin yes$\" /etc/ssh/sshd_config || echo \"PermitRootLogin yes\" >> /etc/ssh/sshd_config'; \
printf 'zanthus\nzanthus' | sudo -S passwd root;
sudo systemctl restart sshd; \
sudo sed -i '/NOPASSWD/d' /etc/sudoers;" ||
    #Ubuntu 22.04
    sshpass -p zanthus ssh "$ssh_options" zanthus@"$IP" "\
printf '%s\n' 'zanthus' | sudo -S sh -c 'echo \"zanthus ALL=(ALL) NOPASSWD: ALL\" >> /etc/sudoers'; \
sudo sed -i '/pam_pwquality.so/!b;/minlen=7/!s/$/ minlen=7/' /etc/pam.d/common-password; \
sudo sed -i '/pam_pwquality.so/!b;/dictcheck=0/!s/$/ dictcheck=0/' /etc/pam.d/common-password; \
sudo sed -i '/^PermitRootLogin prohibit-password/!b;/^#PermitRootLogin prohibit-password/b;s/^PermitRootLogin prohibit-password/#PermitRootLogin prohibit-password/' /etc/ssh/sshd_config; \
sudo sh -c 'grep -q \"^PermitRootLogin yes$\" /etc/ssh/sshd_config || echo \"PermitRootLogin yes\" >> /etc/ssh/sshd_config'; \
printf 'zanthus\nzanthus' | sudo -S passwd root;
sudo systemctl restart sshd; \
sudo sed -i '/NOPASSWD/d' /etc/sudoers;"
        else
    echo -e """$IP"" OFF!"
fi
done

