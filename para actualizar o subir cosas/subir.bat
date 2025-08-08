@echo off
cls

echo ===============================
echo      INICIO DEL PROCESO GIT     
echo ===============================

cd /d "%~dp0..\"

if exist ".git\index.lock" (
    echo --------------------------------
    echo  Archivo index.lock detectado.  
    echo  Eliminando para evitar bloqueos...
    echo --------------------------------
    del ".git\index.lock"
)

echo
echo Agregando archivos...
git add .

:msgInput
set /p msg="Escribí el mensaje del commit: "
if "%msg%"=="" (
    echo ERROR: El mensaje no puede estar vacío.
    goto msgInput
)

echo
echo Realizando commit...
git commit -m "%msg%"
if errorlevel 1 (
    echo No se pudo hacer commit. ¿Hay cambios para commitear?
) else (
    echo Commit realizado con éxito.
)

echo
set /p confirm="¿Querés subir los cambios ahora? (S/N): "
if /i "%confirm%" NEQ "S" (
    echo Operación cancelada.
    pause
    exit /b
)

echo
echo Subiendo cambios...
git push

echo
echo ===============================
echo      PROCESO FINALIZADO       
echo ===============================

pause
