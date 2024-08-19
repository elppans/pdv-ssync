#!/bin/bash

# shellcheck source=/dev/null
source /opt/pdv-ssync/pdv_env

# shellcheck disable=SC2154
if [ -d "$pdvshelld" ]; then
    echo -e "Configurando links necessarios..."
    ln -sf "$pdvshelld"/pdv_status.sh /usr/bin/pdv-status
    ln -sf "$pdvshelld"/pdv_get-ip.sh /usr/bin/pdv-get-ip
    ln -sf "$pdvshelld"/pdv_release.sh /usr/bin/pdv-release
    ln -sf "$pdvshelld"/pdv_descanso.sh /usr/bin/pdv-descanso
    ln -sf "$pdvshelld"/pdv_FULL-upgrade.sh /usr/bin/pdv-upgrade
    ln -sf "$pdvshelld"/pdv_root-on-ssh.sh /usr/bin/pdv-update-ssh
    chmod +x "$pdvshelld"/*.sh
else
    echo -e "Diretório necessario não existe!"
    exit 1
fi
