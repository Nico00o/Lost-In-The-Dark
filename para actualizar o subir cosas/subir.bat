@echo off
cd /d "%~dp0..\"
git add .
set /p msg="Escrib� el mensaje del commit: "
git commit -m "%msg%"
git push
pause
