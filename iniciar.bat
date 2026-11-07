@echo off
chcp 65001 >nul
cd /d "%~dp0"
where node >nul 2>nul
if errorlevel 1 (
  echo O Node.js nao foi encontrado. Instale a versao LTS em nodejs.org e tente de novo.
  pause
  exit /b 1
)
if not exist node_modules (
  echo Primeira vez: instalando o que o sistema precisa. Aguarde...
  call npm install --omit=dev
  if errorlevel 1 (
    echo Nao foi possivel instalar. Confira a internet e tente de novo.
    pause
    exit /b 1
  )
)
node backend\src\server.js
pause
