#!/bin/env bash

# shellcheck source=/dev/null
source /usr/share/pdv-ssync/pdv_env

# Verifica se o comando ssh está disponível
# shellcheck disable=SC2162
if ! command -v ssh &> /dev/null; then
    echo "O comando ssh não está instalado."
    echo "Instale o pacote que contém o ssh para fazer a conexão."
    echo "Pressione qualquer tecla para sair."
    read -n 1 -s
    exit 1
fi

# Verifica se o comando rsync está disponível
# shellcheck disable=SC2162
if ! command -v rsync &> /dev/null; then
    echo "O comando rsync não está instalado."
    echo "Instale o pacote que contém o rsync para fazer a conexão."
    echo "Pressione qualquer tecla para sair."
    read -n 1 -s
    exit 1
fi

# Verifica se o arquivo /etc/os-release existe
if [ -f /etc/os-release ]; then
    # Lê as informações do sistema operacional do arquivo
    . /etc/os-release

    # Verifica se a distribuição é CentOS ou Red Hat e se a versão é 7
    if [[ "$ID" == "centos" || "$ID" == "rhel" ]] && [[ "$VERSION_ID" == "7" ]]; then
        #echo "Este sistema está rodando $NAME $VERSION_ID."

# Verifica se o comando openssl11 está disponível
# shellcheck disable=SC2162
if ! command -v /usr/bin/openssl11 &> /dev/null; then
    echo "O comando openssl11 não está instalado."
    echo "Instale o pacote que contém o openssl11 para fazer a conexão."
    echo "Pressione qualquer tecla para sair."
    read -n 1 -s
    exit 1
else
# Define uma função chamada 'openssl' que chama '/usr/bin/openssl11'
openssl() {
    /usr/bin/openssl11 "$@"
}
fi
    else
        #echo "Este sistema não está rodando CentOS 7 nem Red Hat 7."
        echo " "
    fi
else
    echo "Não foi possível identificar a distribuição do sistema operacional."
fi

# Verifica se o comando openssl está disponível
# shellcheck disable=SC2162
if ! command -v openssl &> /dev/null; then
    echo "O comando openssl não está instalado."
    echo "Instale o pacote que contém o openssl para fazer a conexão."
    echo "Pressione qualquer tecla para sair."
    read -n 1 -s
    exit 1
else
    # Verifica a versão do openssl
    OPENSSL_VERSION=$(openssl version | cut -d" " -f2)
    # Compara a versão do openssl com 1.1.0
    if [[ $(printf '1.1.0\n%s' "$OPENSSL_VERSION" | sort -V | head -n1) != "1.1.0" ]]; then
        echo "A versão do openssl é antiga: $OPENSSL_VERSION"
        echo "Atualize para a versão 1.1.0 ou superior para fazer a conexão."
        echo "Pressione qualquer tecla para sair."
        read -n 1 -s
        exit 1
    fi
fi


mkdir -p ~/.ssh

# Verifica se a chave simétrica já foi gerada e a lê do arquivo
# shellcheck disable=SC2154
if [ ! -e "$encryption_key_file" ]; then
    echo "Chave simétrica não encontrada. Gerando uma nova chave..."
    openssl rand -base64 32 > "$encryption_key_file"
    echo "Chave simétrica gerada e armazenada com segurança."
fi

# Lê a chave simétrica do arquivo
encryption_key=$(cat "$encryption_key_file")

# Verifica se o arquivo de senha criptografada existe
# shellcheck disable=SC2154
# shellcheck disable=SC2162
if [ ! -e "$sshpass_file" ]; then
    echo "Digite a senha:"
    read -s senha
    echo "$senha" | openssl enc -aes-256-cbc -salt -a -pbkdf2 -pass pass:"$encryption_key" -out "$sshpass_file"
    echo "Senha criptografada e armazenada no arquivo."
fi

# Lê a senha criptografada do arquivo
senha_criptografada="$(openssl enc -aes-256-cbc -d -a -pbkdf2 -pass pass:"$encryption_key" -in "$sshpass_file")"
export senha_criptografada
# Não verificar a chave do host, automatizar a gravação da chave do host em cache na primeira conexão e não exibir nenhuma mensagem no terminal relacionada à verificação da chave do host.
ssh_options="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=QUIET"
export ssh_options
# Ajustar as permissões do arquivo sshpass_file e encryption_key_file para que somente o usuário atual possa lê-los e gravá-los de forma segura.
chmod 600 "$sshpass_file"
chmod 600 "$encryption_key_file"
