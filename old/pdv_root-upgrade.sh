#!/usr/bin/bash

# shellcheck source=/dev/null
source /usr/share/pdv-ssync/environment/pdv_env

# shellcheck disable=SC2154
if [ ! -e "$pdvcripto" ]; then
    echo "Falta arquivo de criptografia!"
    exit 0
fi

# shellcheck disable=SC2154
if [ ! -e "$iponpdv" ]; then
    echo -e "Arquivo \"""$iponpdv""\" nao existe!"
    exit 0
fi

# shellcheck disable=SC2154
rm -rf "$iponupgradepdv"

# shellcheck disable=SC2013
for IP in $(cat "$iponpdv"); do
if ping -c 1 "$IP" >> /dev/null; then
echo -e """$IP"" ON!"
#sshpass -p "$senha_criptografada" ssh $ssh_options root@"$IP" "grep '^root:' /etc/passwd" 2>> /dev/null || \
# shellcheck disable=SC2154
sshpass -p "$senha_criptografada" ssh "$ssh_options" root@"$IP" "grep -q '^PermitRootLogin yes' /etc/ssh/sshd_config" 2>> /dev/null || \

echo -e """$IP""" | tee -a "$iponupgradepdv" && \

if [ -e "$iponupgradepdv" ]; then
export IPON="$iponupgradepdv"
fi

 else
echo -e """$IP"" OFF!"
fi
done


if [[ "$IPON" = "$iponupgradepdv" ]]; then
# shellcheck disable=SC2154
source "$pdvrooton"
fi

