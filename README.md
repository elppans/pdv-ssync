
---

# pdv-ssync

Este repositório deve ser clonado em "/usr/share".  

```bash
git clone -b <branch> --single-branch https://github.com/elppans/pdv-ssync.git
```
>Substitua <branch> pelo nome do branch que você deseja clonar e <repositório> pela URL do seu repositório.

Após clonar, execute o script "pdv-sfix.sh" para criar os links e diretórios necessários.  
O uso do Script consiste no comando `pdv-sync`.  

## Dependências

- rsync
- sshpass
- openssh
- openssl 1.1.0+

## Atualizar OpenSSL no CentOS 7

### Via pacote (RECOMENDADO):

```bash
sudo yum -y install epel-release
sudo yum install openssl11
whereis openssl11
printf '%s\n' 'alias openssl="/usr/bin/openssl11"' | sudo tee -a /etc/profile
```

### Via source:

Se não for possível instalar o pacote "openssl11" por algum motivo, baixe e instale via source. Recomenda-se a versão 1.1.1, disponível no [link do Source](https://www.openssl.org/source/old/).

## Fontes

- [Como instalar o OpenSSL 1.1 no CentOS/RHEL 7](https://computingforgeeks.com/how-to-install-openssl-1-1-on-centos-rhel-7/)
- [Atualizando CentOS 7 para OpenSSL 1.1.1](https://stackoverflow.com/questions/63508872/upgrading-centos-7-to-openssl-1-1-1-by-yum-install-openssl11)

---

## Opções do Script "pdv-sync":

- `--status`, `-s`:
  - Verifica se o IP do PDV está pingando (ON!) ou não (OFF!) e cria um arquivo com o nome `ip_on.txt`.
- `--versao`, `-v` (OPCIONAL):
  - Adiciona a chave do PDV ao SSH e verifica a versão de cada PDV Online. Depende de "ip_on.txt".
- `--atualizar-ssh`, `-as` (RECOMENDADO):
  - Com a chave adicionada, acessa o PDV e ativa o sudo sem senha, senha do root e acesso SSH com root.
- `--sincronizar-descanso`, `-sd`:
  - Com o acesso SSH usando root ativado, copia o conteúdo de `/opt/descanso` para o PDV em `*/pdvGUI/guiConfigProj`.
- `--atualizacao-total`, `-at` (ALTERNATIVA):
  - Executa diretamente o comando "pdv-upgrade", realizando os 3 comandos necessários na ordem:
    1. `--status`
    2. `--atualizar-ssh`
    3. `--sincronizar-descanso`

**Observações**:

- Execute cada opção na ordem correta, pois uma depende da outra.

---

## Busca por IP:

Para baixar a lista de IPs, execute o parâmetro `--puxar-ip` ou `-pi`. Esse comando depende de acesso ao banco e o comando `psql` deve estar instalado.
Se o Docker estiver instalado, o comando buscará o arquivo "/opt/docker/manager/ZMWSInfo_manager_1.ini" para usar.
Se o Docker NÃO estiver instalado, crie um arquivo em seu `$HOME`:

`$HOME/.local/share/pdv-ssync/ZMWSInfo.env`

O arquivo `ZMWSInfo.env` deve ter o seguinte conteúdo (exemplo):

```bash
export PGHOST=192.168.15.118
export PGUSER=pgadmin
export PGDATABASE=ZeusRetail
```

Para o uso da senha, crie o arquivo de chaves "ZMWSInfo.key" com o seguinte comando:

```bash
openssl rand -base64 32 > "$HOME/.local/share/pdv-ssync/ZMWSInfo.key"
```

Em seguida, gere a senha com o comando:

```bash
read -p "PWD: " PWD && printf "$PWD" | openssl enc -aes-256-cbc -salt -a -pbkdf2 -pass pass:"$HOME/.local/share/pdv-ssync/ZMWSInfo.key" -out "$HOME/.local/share/pdv-ssync/ZMWSInfo.ssl"
```

O conteúdo do "Descanso" do PDV deve ser configurado em "/opt/descanso".

---
