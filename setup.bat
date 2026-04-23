@echo off
echo ===============================
echo   Dibeji AI - Site Setup
echo ===============================

echo Logging into Docker Hub...
docker login -u dibejiai

echo Pulling latest collector image...
docker pull dibejiai/dibeji-snmp-client:latest

echo Stopping any existing collector...
docker rm -f dibeji-snmp-client 2>nul

echo Starting collector...
docker run -d ^
  --name dibeji-snmp-client ^
  --restart unless-stopped ^
  --env-file .env ^
  -v "%CD%\config.json:/app/config.json:ro" ^
  dibejiai/dibeji-snmp-client:latest

echo Waiting for startup...
timeout /t 10

echo ===============================
echo   Collector Logs:
echo ===============================
docker logs dibeji-snmp-client --tail 30

echo ===============================
echo   Setup Complete
echo ===============================
pause
