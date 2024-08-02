#!/bin/bash

if [ ! -z "$#" ]; then
	pdv-getip "$@"
fi

pdv-status
pdv-update-ssh
pdv-descanso

