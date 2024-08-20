#!/bin/bash
#red=$(tput bold)$(tput setaf 196)
#green=$(tput bold)$(tput setaf 2)
#pink=$(tput setaf 5)

#export PS4='${red}${0##*/}${green}[$FUNCNAME]${pink}[$LINENO]${reset} '
#set -x

# shellcheck source=/dev/null
source /usr/share/pdv-ssync/environment/pdv_env
source /usr/share/pdv-ssync/environment/lib.sh

# shellcheck disable=SC2154
mkdir -p "$pdvshelletc"
# shellcheck disable=SC2059
printf "$PATH" >"$pdvshelletc/pdv-ssync.path"

# shellcheck disable=SC2154
if [ -f "$ZMWSInfoEtc" ]; then
	source "$ZMWSInfoEtc" &>>/dev/null
else
	if [ -f "$ZMWSInfoFile" ]; then
		PGHOST=$(TIni.Get "$ZMWSInfoFile" 'INFOZMWS' 'IPBancoZM')
		PGUSER=$(TIni.Get "$ZMWSInfoFile" 'GERAL' 'User')
		PGPASSWORD=$(TIni.Get "$ZMWSInfoFile" 'GERAL' 'Passwd')
		PGDATABASE=$(TIni.Get "$ZMWSInfoFile" 'POSTGRESQL' 'DatabaseNameBase')

		# Removendo quebras de linha, tabulações e retorno de carro usando substituição de padrões
		PGHOST="${PGHOST//$'\n'/}"
		PGHOST="${PGHOST//$'\r'/}"
		PGHOST="${PGHOST//$'\t'/}"

		PGUSER="${PGUSER//$'\n'/}"
		PGUSER="${PGUSER//$'\r'/}"
		PGUSER="${PGUSER//$'\t'/}"

		PGDATABASE="${PGDATABASE//$'\n'/}"
		PGDATABASE="${PGDATABASE//$'\r'/}"
		PGDATABASE="${PGDATABASE//$'\t'/}"

		PGPASSWORD="${PGPASSWORD//$'\n'/}"
		PGPASSWORD="${PGPASSWORD//$'\r'/}"
		PGPASSWORD="${PGPASSWORD//$'\t'/}"

		cat >"$ZMWSInfoEtc" <<-EOF
			export PGHOST=$PGHOST
			export PGUSER=$PGUSER
			export PGPASSWORD=$PGPASSWORD
			export PGDATABASE=$PGDATABASE
		EOF

		#echo -e "PATH=$(cat $pdvshelletc/pdv-ssync.path)" | tee -a "$ZMWSInfoFile"
		#grep -v "[\#|\[|\|\<|\>|\{|\}|\(|\)]" "$ZMWSInfoFile" > "$ZMWSInfoEtc"
		#grep -E '^(DatabaseNameBase|IPBancoZM|Passwd|User)=' "$ZMWSInfoEtc" > "$ZMWSInfoEtc"_clean
		#mv -f "$ZMWSInfoEtc"_clean "$ZMWSInfoEtc"
		#sed -i 's/User/PGUSER/' "$ZMWSInfoEtc"
		#sed -i 's/Passwd/PGPASSWORD/' "$ZMWSInfoEtc"
		#sed -i 's/IPBancoZM/PGHOST/' "$ZMWSInfoEtc"
		#sed -i 's/DatabaseNameBase/PGDATABASE/' "$ZMWSInfoEtc"

		source "$ZMWSInfoEtc" >/dev/null 2>&1
	else
		echo "Não foi possível verificar variáveis..."
		echo -e "Arquivo \"$ZMWSInfoFile\" não existe!"
		exit 1
	fi
fi

# Verifica se a chave simétrica já foi gerada
# shellcheck disable=SC2154
if [ ! -e "$zencryption_key_file" ]; then
	openssl rand -base64 32 >"$zencryption_key_file"
fi

# Verifica se o conteúdo da chave simétrica foi gerada
if [ -s "$zencryption_key_file" ]; then
	# Lê a chave simétrica do arquivo
	zencryption_key=$(cat "$zencryption_key_file")
else
	openssl rand -base64 32 >"$zencryption_key_file"
	if [ ! -s "$zencryption_key_file" ]; then
		echo "Erro na leitura da chave!"
		exit 1
	fi
	zencryption_key=$(cat "$zencryption_key_file")
fi

# Verifica se o arquivo de senha criptografada NÃO existe e gera
# shellcheck disable=SC2154
if [ ! -e "$zsshpass_file" ]; then
	#echo "Digite a senha:"
	#read -s senha
	echo "$PGPASSWORD" | openssl enc -aes-256-cbc -salt -a -pbkdf2 -pass pass:"$zencryption_key" -out "$zsshpass_file"
	echo "Senha criptografada e armazenada no arquivo."
fi

# Verifica novamente se o arquivo de senha criptografada NÃO existe e dá um aviso e sai
if [ ! -f "$zsshpass_file" ]; then
	echo "Arqivo \"$zsshpass_file\" não foi gerado!"
	exit 1
fi

# Lê a senha criptografada do arquivo
# shellcheck disable=SC2155
export PGPASSWORD="$(openssl enc -aes-256-cbc -d -a -pbkdf2 -pass pass:"$zencryption_key" -in "$zsshpass_file")"
sed -i '/PGPASSWORD/d' "$ZMWSInfoEtc"
#grep -qxF 'export PGUSER' "$ZMWSInfoEtc" || echo 'export PGUSER' >> "$ZMWSInfoEtc"
#grep -qxF 'export PGPASSWORD' "$ZMWSInfoEtc" || echo 'export PGPASSWORD' >> "$ZMWSInfoEtc"
#grep -qxF 'export PGDATABASE' "$ZMWSInfoEtc" || echo 'export PGDATABASE' >> "$ZMWSInfoEtc"
#grep -qxF 'export PGHOST' "$ZMWSInfoEtc" || echo 'export PGHOST' >> "$ZMWSInfoEtc"
