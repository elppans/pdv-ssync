#!/bin/bash

if [ -n "$#" ]; then
	pdv-getip "$@"
fi

pdv-status
pdv-update-ssh
pdv-descanso

