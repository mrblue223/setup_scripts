#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (use sudo ./script.sh)"
  exit
fi

echo "--- Chromium Automatic Setup for Kali Linux ---"

# 1. Update and Install
echo "[*] Updating package lists and installing Chromium..."
apt update
apt install chromium -y

# 2. Fix for Root User (Common on Kali)
# Chromium prevents running as root for security, but many Kali users 
# operate as root. This adds the necessary flags to the launcher.
echo "[*] Configuring Chromium to allow 'Root' execution..."
FLAG_FILE="/etc/chromium.d/default-flags"

# Create the directory if it doesn't exist
mkdir -p /etc/chromium.d/

# Add flags: no-sandbox (required for root) and user-data-dir
cat <<EOF > $FLAG_FILE
# Flags to allow Chromium to run as root on Kali
export CHROMIUM_FLAGS="\$CHROMIUM_FLAGS --no-sandbox --user-data-dir"
EOF

# 3. Create a Desktop Shortcut (Optional but helpful)
echo "[*] Verifying installation..."
if command -v chromium &> /dev/null; then
    VERSION=$(chromium --version)
    echo "[+] Success! Installed: $VERSION"
else
    echo "[-] Installation failed. Check your internet connection."
    exit 1
fi

echo "--- Setup Complete ---"
echo "You can now launch Chromium from your menu or by typing 'chromium' in terminal."
