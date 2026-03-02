# 📖 Guia de Setup: NVM e Node.js sem Privilégios de Administrador

Este tutorial descreve a configuração do **Node Version Manager (NVM)** no Windows utilizando a abordagem *No-Install* combinada com Junções de Diretório. Isso permite o controle total das versões do Node.js e NPM sem acionar o UAC (User Account Control) do Windows.

## 🎯 Pré-requisitos

- Acesso ao terminal padrão do Windows (CMD/PowerShell) e ao **Git Bash**.
- Permissão de escrita na própria pasta de usuário (`C:\Users\flavio.lessa`).

---

## Passo 1: Preparação do Diretório e Arquivos Base

A arquitetura das pastas deve ser isolada na raiz do seu usuário para evitar conflitos de permissão.

1. Baixe o arquivo `nvm-noinstall.zip` no [repositório oficial](https://github.com/coreybutler/nvm-windows/releases).
2. Extraia o conteúdo para a pasta raiz do NVM: `C:\Users\flavio.lessa\nvm`.
3. Dentro desta pasta, crie um arquivo chamado **`settings.txt`** com a seguinte configuração exata:

Plaintext

`root: C:\Users\flavio.lessa\nvm
path: C:\Users\flavio.lessa\nvm\nodejs
arch: 64
proxy: none`

---

## Passo 2: O Motor de Automação (Bypass de Admin)

O comando padrão `nvm use` exige administrador para criar *Symlinks*. Para contornar isso, utilizaremos um script Batch nativo que executa um *Directory Junction* (`mklink /j`), permitido para usuários comuns.

1. Na pasta `C:\Users\flavio.lessa\nvm`, crie um arquivo chamado **`use-node.bat`**.
2. Cole o código fonte abaixo e salve:

Snippet de código

```bash
@echo off
setlocal enabledelayedexpansion

:: Mapeamento de Diretorios
set "NVM_ROOT=C:\Users\flavio.lessa\nvm"
set "NODEJS_LINK=%NVM_ROOT%\nodejs"

if "%~1"=="" (
    echo [ERRO] Informe a versao. Exemplo: use-node.bat 16.20.2
    echo.
    echo Versoes instaladas:
    dir /b /ad "%NVM_ROOT%\v*"
    goto :eof
)

:: Normalizacao de Input (aceita "16" ou "v16")
set "VER_INPUT=%~1"
set "TARGET_VER=v%VER_INPUT:v=%"

if not exist "%NVM_ROOT%\%TARGET_VER%" (
    echo [ERRO] A pasta %NVM_ROOT%\%TARGET_VER% nao existe.
    goto :eof
)

echo [INFO] Trocando versao para %TARGET_VER%...

:: Limpeza agressiva do link anterior
if exist "%NODEJS_LINK%" (
    rmdir /s /q "%NODEJS_LINK%"
)

:: Cria a Juncao de Diretorio (Sem necessidade de Admin)
mklink /j "%NODEJS_LINK%" "%NVM_ROOT%\%TARGET_VER%"

if %errorlevel% equ 0 (
    echo [SUCESSO] Link atualizado para %TARGET_VER%
    "%NODEJS_LINK%\node.exe" -v
) else (
    echo [ERRO] Falha ao criar a juncao. Verifique os caminhos.
)
```

---

## Passo 3: Mapeamento de Variáveis no Windows (Escopo do Usuário)

Para que o sistema operacional encontre os executáveis de qualquer pasta, precisamos registrar os caminhos no `Path` do seu perfil.

1. Pressione `Win + R`, digite `rundll32.exe sysdm.cpl,EditEnvironmentVariables` e dê Enter.
2. Em **Variáveis de Usuário**, crie duas novas variáveis:
    - **NVM_HOME** `C:\Users\flavio.lessa\nvm`
    - **NVM_SYMLINK** `C:\Users\flavio.lessa\nvm\nodejs`
3. Localize a variável **Path** (ainda nas Variáveis de Usuário), clique em **Editar** e adicione:
    - `%NVM_HOME%`
    - `%NVM_SYMLINK%`
4. Clique em **OK** para fechar e salvar.

---

## Passo 4: Integração com o Git Bash (MINGW64)

O Git Bash simula um ambiente Linux e possui seu próprio mapeamento interno de rotas. Precisamos "ensinar" a ele onde os binários do Windows estão alocados.

1. Abra o **Git Bash** na raiz de qualquer projeto (ex: `fundodebolsa/angular`).
2. Execute o comando abaixo para injetar os caminhos no seu perfil do Bash:

Bash

```bash
echo 'export PATH=$PATH:/c/Users/flavio.lessa/nvm:/c/Users/flavio.lessa/nvm/nodejs' >> ~/.bash_profile
```

1. Recarregue o perfil na sessão atual para aplicar as mudanças imediatamente:

Bash

```bash
source ~/.bash_profile
```

---

## Passo 5: Validação e Fluxo de Trabalho (Workflow)

Seu ambiente está pronto. O fluxo de trabalho diário seguirá este padrão:

**1. Instalar uma nova versão:***(Baixa a versão diretamente para a pasta do NVM)*

Bash

```bash
nvm install 16.20.2
```

**2. Ativar a versão instalada:***(Aciona o nosso script de automação e faz a ponte)*

Bash

```bash
use-node.bat 16.20.2
```

**3. Validar o ambiente:***(Confirma se o motor V8 e o gerenciador de pacotes estão respondendo)*

Bash

```bash
node -v
npm -v
```

> [!TIP]
**Dica de Infraestrutura:** Se em algum momento o `npm install` de um projeto falhar por cache corrompido ao trocar de versões, sempre rode `npm cache clean --force` antes de tentar reinstalar as dependências (`node_modules`).
>
