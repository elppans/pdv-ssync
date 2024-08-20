#!/usr/bin/env bash

function TIni.Get() {
	local config_file="$1"
	local section="$2"
	local key="$3"
	sed -nr "/^\[$section\]/ { :l /^[[:space:]]*${key}[[:space:]]*=/ { s/[^=]*=[[:space:]]*//; p; q;}; /^;/b; n; b l;}" "$config_file"
}
export -f TIni.Get

# Função para atualizar um valor no arquivo INI ou criar o arquivo se não existir
# Exemplo de uso: atualize o valor da chave "versao" da seção "App" no arquivo "config.ini"
# TIni.Set "config.ini" "App" "versao" "2.0"
function TIni.Set {
	local config_file="$1"
	local section="$2"
	local key="$3"
	local new_value="$4"
	ident_keys="1"
	# shellcheck disable=SC2034
	local ident_keys

	declare -A ini_data # Array associativo para armazenar as seções e chaves

	if [[ -f "$config_file" ]]; then
		# Ler o arquivo INI e armazenar as informações em um array associativo
		local current_section=""
		while IFS= read -r line; do
			if [[ "$line" =~ ^\[(.*)\] ]]; then
				current_section="${BASH_REMATCH[1]}"
			elif [[ "$line" =~ ^([^=]+)=(.*) ]]; then
				local current_key="${BASH_REMATCH[1]}"
				local current_value="${BASH_REMATCH[2]}"
				ini_data["$current_section,$current_key"]="$current_value"
			fi
		done <"$config_file"
	fi

	# Atualizar o valor no array associativo
	ini_data["$section,$key"]="$new_value"

	# Reescrever o arquivo INI com as seções e chaves atualizadas
	echo "" >"$config_file"
	local current_section=""
	for section_key in "${!ini_data[@]}"; do
		local section_name="${section_key%,*}"
		local key_name="${section_key#*,}"
		local value="${ini_data[$section_key]}"

		# Verifique se a seção já foi gravada
		if [[ "$current_section" != "$section_name" ]]; then
			echo "" >>"$config_file"
			echo "[$section_name]" >>"$config_file"
			current_section="$section_name"
		fi
		echo "$key_name=$value" >>"$config_file"
	done
	#   TIni.AlignAllSections "$config_file"
	#   big-tini-pretty -q "$config_file"
	TIni.Sanitize "$config_file"
}
export -f TIni.Set

function TIni.Sanitize() {
	local ini_file="$1"
	local tempfile1
	local tempfile2

	# Criar arquivos temporários
	tempfile1=$(mktemp)
	tempfile2=$(mktemp)

	# Remover linhas em branco do arquivo original
	sed '/^$/d' "$ini_file" >"$tempfile1"

	# Consolidar seções usando awk e salvar no segundo arquivo temporário
	awk '
    BEGIN {
        section = ""
    }
    {
        if ($0 ~ /^\[.*\]$/) {
            section = $0
        } else if (section != "") {
            sections[section] = sections[section] "\n" $0
        }
    }
    END {
    for (section in sections) {
        print section sections[section] "\n"
    }
    }
    ' "$tempfile1" >"$tempfile2"

	sed '/^\s*$/d' "$tempfile2" >"$ini_file"

	# colocar uma linha em branco entre as sessoes e remover a primeira linha em branco
	sed -i -e '/^\[/s/\[/\n&/' -e '1{/^[[:space:]]*$/d}' "$ini_file"
	sed -i -e '1{/^[[:space:]]*$/d}' "$ini_file"

	# marcar como executável
	chmod +x "$ini_file"

	# Remover arquivos temporários
	rm "$tempfile1" "$tempfile2"
}
export -f TIni.Sanitize

# Função para remover uma chave de um arquivo de configuração INI
function TIni.Delete() {
	local config_file="$1"
	local section="$2"
	local key="$3"

	# Verifica se o arquivo de configuração existe
	if [ ! -f "$config_file" ]; then
		return 2
	fi

	# Usa sed para remover a chave do arquivo de configuração
	sed -i "/^\[$section\]/,/^$/ { /^\s*$key\s*=/d }" "$config_file"
}
export -f TIni.Delete
