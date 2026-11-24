#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"
node -e "const [m,n]=process.versions.node.split('.').map(Number);if(m<22||(m===22&&n<13))process.exit(1)"
echo 'Abra http://localhost:3000. Mantenha o terminal aberto.'
exec node --env-file-if-exists=.env server.js
