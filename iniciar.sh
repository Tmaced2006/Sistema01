#!/bin/sh
cd "$(dirname "$0")" || exit 1
if ! command -v node >/dev/null 2>&1; then
  echo "O Node.js nao foi encontrado. Instale a versao LTS em nodejs.org e tente de novo."
  exit 1
fi
if [ ! -d node_modules ]; then
  echo "Primeira vez: instalando o que o sistema precisa. Aguarde..."
  npm install --omit=dev || { echo "Nao foi possivel instalar. Confira a internet."; exit 1; }
fi
exec node backend/src/server.js
