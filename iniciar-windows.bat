@echo off
cd /d "%~dp0"
where node >nul 2>&1
if errorlevel 1 (
  echo Instale Node.js 22.13 ou superior em https://nodejs.org/pt-br/download
  pause
  exit /b 1
)
node -e "const [m,n]=process.versions.node.split('.').map(Number);if(m<22||(m===22&&n<13))process.exit(1)"
if errorlevel 1 (
  echo Atualize o Node.js para 22.13 ou superior.
  pause
  exit /b 1
)
echo.
echo LONG NIGHT - Abra http://localhost:3000 depois que o servidor iniciar.
echo Mantenha esta janela aberta. Nao precisa executar npm install.
echo.
node --env-file-if-exists=.env server.js
pause
