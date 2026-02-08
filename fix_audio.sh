#!/bin/bash

# Define colors for better readability
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting Audio Services Automation...${NC}"

# 1. Restarting core Pipewire services
echo -e "Step 1: Restarting Pipewire and Wireplumber..."
systemctl --user restart pipewire wireplumber
if [ $? -eq 0 ]; then echo -e "${GREEN}✓ Done.${NC}"; fi

# 2. Enabling services for persistence after reboot
echo -e "Step 2: Enabling services..."
systemctl --user enable pipewire pipewire-pulse wireplumber
if [ $? -eq 0 ]; then echo -e "${GREEN}✓ Done.${NC}"; fi

# 3. Handling PulseAudio 
# NOTE: If you are using Pipewire, you usually want PulseAudio DISABLED.
# But here is the automation for your specific requested commands:
echo -e "Step 3: Managing PulseAudio..."
systemctl --user enable pulseaudio
systemctl --user restart pulseaudio
if [ $? -eq 0 ]; then echo -e "${GREEN}✓ Done.${NC}"; fi

echo -e "${YELLOW}Audio services have been cycled!${NC}"
