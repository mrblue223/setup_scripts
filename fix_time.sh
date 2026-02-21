#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root (use sudo)"
  exit
fi

echo "--- Kali Linux Time Sync Fix ---"

# 1. Force enable NTP (Network Time Protocol)
echo "[*] Enabling NTP service..."
timedatectl set-ntp true

# 2. Restart the systemd-timesyncd service to force a sync
echo "[*] Restarting time synchronization daemon..."
systemctl restart systemd-timesyncd

# 3. Wait a few seconds for the handshake to happen
echo "[*] Waiting for synchronization..."
sleep 5

# 4. Check status and output result
SYNC_STATUS=$(timedatectl status | grep "System clock synchronized" | awk '{print $4}')

if [ "$SYNC_STATUS" == "yes" ]; then
    echo -e "\n[+] SUCCESS: Your clock is now synchronized!"
    timedatectl status | grep "Local time"
else
    echo -e "\n[!] FAILED: Automatic sync failed. Pushing clock forward 1 minute manually..."
    # Manual fallback to bypass "Not Yet Valid" certificate errors
    CURRENT_TIME=$(date -u -d "+1 minute" +"%Y-%m-%d %H:%M:%S")
    timedatectl set-ntp false
    timedatectl set-time "$CURRENT_TIME"
    echo "[+] Clock manually set to $CURRENT_TIME UTC."
fi

echo "--- Process Complete ---"
