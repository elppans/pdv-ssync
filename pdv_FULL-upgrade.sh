#!/usr/bin/bash

# /usr/bin/pdv-descanso -> /usr/share/pdv-ssync/pdv_descanso.sh
# /usr/bin/pdv-getip -> /usr/share/pdv-ssync/pdv_get-ip.sh
# /usr/bin/pdv-release -> /usr/share/pdv-ssync/pdv_release.sh
# /usr/bin/pdv-status -> /usr/share/pdv-ssync/pdv_status.sh
# /usr/bin/pdv-update-ssh -> /usr/share/pdv-ssync/pdv_root-on-ssh.sh
# /usr/bin/pdv-upgrade -> /usr/share/pdv-ssync/pdv_FULL-upgrade.sh

if [ -n "$#" ]; then
	pdv-getip "$@"
fi

pdv-status
pdv-update-ssh
pdv-descanso
