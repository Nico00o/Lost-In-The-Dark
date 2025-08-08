@echo off
cls

echo ================================
echo      INICIO DEL PROCESO GIT     
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
echo       Agregando archivos        
echo ================================
git add .

:msgInput
set /p msg="Escribi el mensaje del commit: "
if "%msg%"=="" (
    echo ERROR: El mensaje no puede estar vacio
    goto msgInput
)

echo.
echo ================================
echo        Realizando commit        
echo ================================
git commit -m "%msg%"
if errorlevel 1 (
    echo No se pudo hacer commit. Hay que verificar cambios
) else (
    echo Commit realizado con exito
)

echo.
set /p confirm="Quieres subir los cambios ahora? (S/N): "
if /i "%confirm%" NEQ "S" (
    echo Operacion cancelada
    pause
    exit /b
)

echo.
echo ================================
echo         Subiendo cambios        
echo ================================
git push

echo.
echo ================================
echo      PROCESO FINALIZADO        
echo ================================

pause
