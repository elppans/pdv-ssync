#!/bin/bash
# shellcheck source=/dev/null
source /usr/share/pdv-shell/pdv_env

# IPBancoZM="192.168.15.118"
# DatabaseNameBase="ZeusRetail"
# User="pgadmin"
#Senha="pgadmin"
LJ="$2"
PDV="$4"

case "$1" in
	--all-depur|-adp)
	#-- Select IP PDV todas as lojas (DEPUR)
	#select cod_loja,cod_pdv,ip_pdv from tab_pdv tp order by cod_loja
	# shellcheck disable=SC2154
	psql -p 5432 -h "$IPBancoZM" -d "$DatabaseNameBase" -U "$User" -c "\copy (select cod_loja,cod_pdv,ip_pdv from tab_pdv tp order by cod_loja) to ""$ipdv"" with csv"
	cat "$ipdv"
	;;
	--all|-a)
	#-- Select IP PDV todas as lojas
	#select ip_pdv from tab_pdv tp order by cod_loja
	psql -p 5432 -h "$IPBancoZM" -d "$DatabaseNameBase" -U "$User" -c "\copy (select ip_pdv from tab_pdv tp order by cod_loja) to ""$ipdv"" with csv"
	;;
	--loja|-l)
# Verifica se nenhum argumento foi especificado
if [ -z "$LJ" ]; then
    echo "É necessário especificar o número da loja."
    exit 1
fi

# Verifica se o argumento não é um número
if ! [[ "$LJ" =~ ^[0-9]+$ ]]; then
    echo "O argumento não é um número válido."
    exit 1
fi
case "$3" in
	--pdv|-p)
# Verifica se nenhum argumento foi especificado
if [ -z "$PDV"  ]; then
    echo "É necessário especificar o numero do PDV."
    exit 1
fi
# Verifica se o argumento é um número
if ! [[ "$PDV" =~ ^[0-9]+$ ]]; then
    echo "O argumento não é um número válido."
    exit 1
fi
	#-- Select IP PDV loja e PDV especificos
	#select ip_pdv from tab_pdv tp where cod_loja = '1' and cod_pdv = '7' order by cod_loja
	psql -p 5432 -h "$IPBancoZM" -d "$DatabaseNameBase" -U "$User" -c "\copy (select ip_pdv from tab_pdv tp where cod_loja = ""$LJ"" and cod_pdv = ""$PDV"" order by cod_loja) to '~/ip.txt' with csv"
	exit 0
	;;
	#*)
	#echo "PDV nao especificado, exportando todos os PDVs da loja..."
	#exit 0
	#;;
esac
	#-- Select IP PDV loja especifica
	#select ip_pdv from tab_pdv tp where cod_loja = '1' order by cod_loja
	psql -p 5432 -h "$IPBancoZM" -d "$DatabaseNameBase" -U "$User" -c "\copy (select ip_pdv from tab_pdv tp where cod_loja = ""$LJ"" order by cod_loja) to ""$ipdv"" with csv"
	;;
	--help|-h)
	echo -e \
	"
	--all-depur,-adp
		Select IP PDV todas as lojas (DEPUR)
	--all,-a
		Select IP PDV todas as lojas
	--loja,-l
		Select IP PDV loja especifica
	"
	;;
	*)
	echo "Parametro errado, veja {--help ou -h}!"
	exit 0
	;;
esac
