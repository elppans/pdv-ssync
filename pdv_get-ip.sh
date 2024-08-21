#!/bin/bash
# shellcheck source=/dev/null
# shellcheck disable=SC2154

#set -x
#set -e
#rm -v ~/.local/share/pdv-ssync/ZMWSInfo.env

source /usr/share/pdv-ssync/environment/pdv_env
source "$pdvshelld"/modulos/pdv_zmwsinfo.sh
source "$HOME"/.local/share/pdv-ssync/ZMWSInfo.env
source "$pdvshelld"/environment/lib.sh

OPTIONS_BD="${OPTIONS_BD:-$1}"
LJ="${LJ:-$2}"
NUMPDV="${NUMPDV:-$3}"
PDV="${PDV:-$4}"
TIni.Set "$pdvshelld/ini/pdv.ini" 'ambiente' 'ipdv' "$HOME/ip.txt"
#TIni.Set "$pdvshelld/ini/pdv.ini" 'sincronizacao' 'descanso' "/opt/descanso"
ipdv=$(TIni.Get "$pdvshelld/ini/pdv.ini" 'ambiente' 'ipdv')
export ipdv
#export descanso=$(TIni.Get "$pdvshelld/ini/pdv.ini" 'sincronizacao' 'descanso')
#TIni.Delete "$pdvshelld/ini/pdv.ini" 'sincronizacao' 'descanso'

case "${OPTIONS_BD,,}" in
--all-depur | -adp)
	#-- Select IP PDV todas as lojas (DEPUR)
	#select cod_loja,cod_pdv,ip_pdv from tab_pdv tp order by cod_loja
	psql -c "\copy (select cod_loja,cod_pdv,ip_pdv from tab_pdv tp order by cod_loja) to ""$ipdv"" with csv"
	#cat "$ipdv"
	exit 0
	;;
--all | -a)
	#-- Select IP PDV todas as lojas
	#select ip_pdv from tab_pdv tp order by cod_loja
	psql -c "\copy (select ip_pdv from tab_pdv tp order by cod_loja) to ""$ipdv"" with csv"
	exit 0
	;;
--loja | -l)
	# Verifica se nenhum argumento foi especificado
	if [[ -z "$LJ" ]]; then
		echo "É necessário especificar o número da loja."
		exit 1
	fi

	# Verifica se o argumento não é um número
	if ! [[ "$LJ" =~ ^[0-9]+$ ]]; then
		echo "O argumento não é um número válido."
		exit 1
	fi
	case "$NUMPDV" in
	--pdv | -p)
		# Verifica se nenhum argumento foi especificado
		if [[ -z "$PDV" ]]; then
			echo "É necessário especificar o numero do PDV."
			exit 1
		fi
		# Verifica se o argumento é um número
		if ! [[ "$PDV" =~ ^[0-9]+$ ]]; then
			echo "O argumento não é um número válido."
			exit 1
		fi
		#-- Select IP PDV loja e PDV especificos
		#select ip_pdv from tab_pdv tp where cod_loja = '1' and cod_pdv = '7'
		if psql -c "\copy (select ip_pdv from tab_pdv tp where cod_loja = ""$LJ"" and cod_pdv = ""$PDV"") to ""$ipdv"" with csv"; then
			exit 0
		else
			exit 1
		fi
		;;
		# *)
		#echo "PDV nao especificado, exportando todos os PDVs da loja..."
		#exit 0
		# ;;
	esac
	#-- Select IP PDV loja especifica
	#select ip_pdv from tab_pdv tp where cod_loja = '1' order by cod_pdv
	if psql -c "\copy (select ip_pdv from tab_pdv tp where cod_loja = ""$LJ"" order by cod_pdv) to ""$ipdv"" with csv"; then
		exit 0
	else
		exit 1
	fi
	;;
--loja-ecf | -le)
	# Verifica se o argumento não é um número
	if ! [[ "$LJ" =~ ^[0-9]+$ ]]; then
		echo "O argumento não é um número válido."
		exit 1
	fi
	#-- Select IP PDV loja especifica
	#select cod_loja,cod_pdv,ip_pdv from tab_pdv tp where cod_loja = '1' order by cod_pdv
	if psql -c "\copy (select cod_loja,cod_pdv,ip_pdv from tab_pdv tp where cod_loja = ""$LJ"" order by cod_pdv) to ""$ipdv"" with csv"; then
		exit 0
	else
		exit 1
	fi
	;;
--help | -h)
	echo -e \
		"
	--all-depur,-adp
		Select IP de PDVs de todas as lojas (DEPUR)
	--all,-a
		Select IP de PDVs de todas as lojas
	--loja,-l
		Select IP de PDVs de uma loja especifica
	--loja-ecf,-le
		Select IP e ECF de PDVs de uma loja especifica
	--pdv,-p
		Select IP de PDV especificando um ECF especifico
		Usar com {--loja,-l}
	"
	exit 0
	;;

*)
	echo "Parametro errado, veja {--help ou -h}!"
	exit 0
	;;
esac
