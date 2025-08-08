@echo off
cls

echo ================================
echo       INICIO DE ACTUALIZACION      
echo ================================

cd /d "%~dp0..\"

if exist ".git\index.lock" (
    echo ================================
    echo  Archivo index.lock detectado  
    echo  Eliminando para evitar bloqueos
    echo ================================
    del ".git\index.lock"
)

echo.
echo ================================
echo          Haciendo git pull        
echo ================================
git pull

echo.
echo ================================
echo       ACTUALIZACION FINALIZADA      
echo ================================

pause
