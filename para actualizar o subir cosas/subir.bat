@echo off
cls
echo === Iniciando proceso de subir cambios ===

cd /d "%~dp0..\"

:: Eliminar index.lock si existe
if exist ".git\index.lock" (
    echo Archivo index.lock encontrado. Eliminando para evitar bloqueos...
    del ".git\index.lock"
)

git add .

:msgInput
set /p msg="Escribi el mensaje del commit: "
if "%msg%"=="" (
    echo El mensaje no puede estar vacio, por favor ingresa uno.
    goto msgInput
)

git commit -m "%msg%"
if errorlevel 1 (
    echo No se pudo hacer commit. ¿Hay cambios para commitear?
) else (
    echo Commit realizado con éxito.
)

set /p confirm="¿Queres subir los cambios ahora? (S/N): "
if /i "%confirm%" NEQ "S" (
    echo Operación cancelada.
    pause
    exit /b
)

git push
echo Cambios subidos.

pause
