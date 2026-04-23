# Dibeji AI — Site Collector Setup

This package installs the Dibeji AI UPS monitoring collector on a customer
site machine. Once installed, the collector automatically reads UPS data
every 60 seconds and sends it to the Dibeji AI cloud platform.

---

## What Is In This Package

```
config.json   — UPS device configuration for this site
.env          — credentials and endpoint configuration
setup.bat     — installation script (Windows)
setup.sh      — installation script (Linux/Mac)
README.md     — this file
```

---

## Before Running Setup

### Step 1 — Connect To Customer Network

Connect your laptop to the customer local network (WiFi or ethernet).
The machine must be on the same network as the UPS devices.

Ping the UPS to confirm connectivity:

Windows PowerShell:
```
ping 10.51.29.30
```

You must get replies before proceeding.
If ping fails — confirm you are on the correct network or get the correct IP.

### Step 2 — Install Docker

If Docker is not already installed on this machine:

Windows 10/11 — Docker Desktop:
```
Download: https://docs.docker.com/desktop/install/windows-install/
Install with default settings
Restart if prompted
Verify: open PowerShell and run: docker --version
```

Windows Server 2019/2022 — Docker Engine:
Open PowerShell as Administrator and run:
```
Install-Module -Name DockerMsftProvider -Repository PSGallery -Force
Install-Package -Name docker -ProviderName DockerMsftProvider -Force
Restart-Computer -Force
```
After restart verify:
```
docker --version
```

### Step 3 — Edit config.json

Open config.json and fill in the correct UPS details for this site:

```json
{
  "poll_interval_seconds": 60,
  "include_discovery_each_cycle": false,
  "ups_devices": [
    {
      "device_id": "Descriptive Name For This UPS",
      "card_ip": "10.51.29.30",
      "snmp_community": "public"
    }
  ]
}
```

For multiple UPS devices at the same site:

```json
{
  "poll_interval_seconds": 60,
  "include_discovery_each_cycle": false,
  "ups_devices": [
    {
      "device_id": "Bank HQ UPS 1",
      "card_ip": "10.51.29.30",
      "snmp_community": "public"
    },
    {
      "device_id": "Bank HQ UPS 2",
      "card_ip": "10.51.29.31",
      "snmp_community": "public"
    }
  ]
}
```

### Step 4 — Confirm .env Is Correct

Open .env and confirm these values are set:

```
PUSH_URL=https://snmp.dibeji.ai/api/v1/telemetry/ups
PUSH_TOKEN=real-token-from-jason
POLL_INTERVAL_SECONDS=60
```

---

## Running The Setup

### Windows

Open PowerShell as Administrator:

```
cd "C:\Users\Administrator\Desktop\dibeji-site-setup"
.\setup.bat
```

When prompted enter the Docker Hub password for dibejiai.
Wait for setup to complete.

### Linux / Mac

```
cd ~/Desktop/dibeji-site-setup
bash setup.sh
```

When prompted enter the Docker Hub password for dibejiai.
Wait for setup to complete.

---

## Verifying The Installation

After setup completes confirm the collector is working.

Check container is running:
```
docker ps
```
You should see dibeji-snmp-client with status Up X minutes.

Check logs:
```
docker logs dibeji-snmp-client --tail 30
```

Success looks like:
```
Remote push: success [200]
Sleeping for 60.0 seconds...
=== Poll cycle #2 ===
```

Message Jason to confirm data appearing in MongoDB for this site.

---

## Possible Problems And Fixes

Problem: Docker not installed
Fix: Install Docker Desktop (Windows 10/11) or Docker Engine (Windows Server)

Problem: ping fails
Fix: Confirm you are on the correct network
     Ask customer IT for the correct UPS IP address
     Ask if SNMP is enabled on the UPS

Problem: setup.bat will not run
Fix: Open PowerShell as Administrator
     Right-click PowerShell then Run as administrator

Problem: Docker permission denied
Fix: Run PowerShell as Administrator
     Or restart Docker Desktop as Administrator

Problem: Pull access denied
Fix: Docker login failed
     Rerun: docker login -u dibejiai
     Then rerun setup.bat

Problem: Remote push failed ConnectTimeout
Fix: Customer network is blocking outbound HTTPS
     Ask IT to whitelist: snmp.dibeji.ai on port 443

Problem: Remote push HTTP 401
Fix: Wrong PUSH_TOKEN in .env
     Get correct token from Jason

Problem: Remote push HTTP 400
Fix: Wrong config.json format or device_id
     Check config.json structure matches the template

Problem: Container runs once and stops
Fix: Check POLL_INTERVAL_SECONDS=60 in .env
     Rerun setup.bat

---

## After Installation

The collector runs automatically in the background.
It will restart automatically if it crashes or if the machine reboots.
No manual intervention needed.

Confirm Docker Desktop is set to start on Windows boot:
Docker Desktop > Settings > General > Start Docker Desktop when you log in

Check status at any time:
```
docker ps
docker logs dibeji-snmp-client --tail 30
```

Stop the collector:
```
docker stop dibeji-snmp-client
```

Start it again:
```
docker start dibeji-snmp-client
```

---

## Updating The Collector

When a new version is released:
```
docker pull dibejiai/dibeji-snmp-client:latest
docker rm -f dibeji-snmp-client
.\setup.bat
```

---

## Support

Contact Jason or the Dibeji AI team for any issues not covered above.
