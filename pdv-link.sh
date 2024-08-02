#!/bin/bash

if [ -d /usr/share/pdv-shell ]; then
echo -e "Diretorio pdv-shell OK..."
ln -sf /usr/share/pdv-shell/pdv_status.sh /usr/bin/pdv-status
ln -sf /usr/share/pdv-shell/pdv_release.sh /usr/bin/pdv-release
ln -sf /usr/share/pdv-shell/pdv_descanso.sh /usr/bin/pdv-descanso
ln -sf /usr/share/pdv-shell/pdv_FULL-upgrade.sh /usr/bin/pdv-upgrade
ln -sf /usr/share/pdv-shell/pdv_root-on-ssh.sh /usr/bin/pdv-update-ssh
else
echo -e "Diretório pdv-shell não existe!"
exit 1
fi
