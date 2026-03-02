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