@echo off
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -File ".\renumerar.ps1"
pause