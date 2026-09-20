@echo off
setlocal
cd /d "%~dp0"

echo.
echo Iniciando atualizador do Fantasy Sandbox...
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0updater\update.ps1"
set "EXITCODE=%ERRORLEVEL%"

echo.
if not "%EXITCODE%"=="0" (
  echo O atualizador terminou com erro ^(codigo %EXITCODE%^).
  echo Leia a mensagem acima antes de fechar esta janela.
)

pause
exit /b %EXITCODE%
