@echo off
setlocal
cd /d "%~dp0"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0updater\update.ps1"
set "EXITCODE=%ERRORLEVEL%"

echo.
if not "%EXITCODE%"=="0" (
  echo O atualizador terminou com erro ^(codigo %EXITCODE%^).
  echo Nenhuma atualizacao incompleta deve ter sido aplicada.
)

pause
exit /b %EXITCODE%
