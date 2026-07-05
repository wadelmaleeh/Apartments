@echo off
echo Starting API Server...
cd /d "%~dp0server"
node index.js
pause
