#!/bin/bash

# ==============================================================================
# SCRIPT NAME:  Media-Integrity-Repair-Suite (MIRS)
# AUTHOR:       Sammy Majorique Gaston Roy
# VERSION:      1.1.0
# DATE:         March 09, 2026
# DESCRIPTION:  A specialized diagnostic and remediation utility designed for 
#               Kali Linux systems to resolve VA-API (Hardware Acceleration) 
#               conflicts and PipeWire-PulseAudio synchronization failures.
# ==============================================================================

# --- WARNING & LEGAL DISCLAIMER ---
# WARNING: This script modifies user group memberships and restarts core 
# system-level media services. Running this script will temporarily interrupt 
# all active audio/video streams. Use with caution in production environments.
# ==============================================================================

# --- CONFIGURATION & STYLING ---
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo -e "${BLUE}${BOLD}====================================================${NC}"
echo -e "${BLUE}${BOLD}   MEDIA-INTEGRITY-REPAIR-SUITE (MIRS) v1.1.0       ${NC}"
echo -e "${BLUE}${BOLD}   Developer: Sammy Majorique Gaston Roy            ${NC}"
echo -e "${BLUE}${BOLD}====================================================${NC}"

# --- ROOT PRIVILEGE CHECK ---
if [[ $EUID -ne 0 ]]; then
   echo -e "${YELLOW}[!] Note: Certain diagnostic scans require sudo privileges.${NC}"
fi

# --- PHASE 1: PERMISSION AUDIT ---
echo -e "\n${BOLD}[PHASE 1] Hardware Access & Log Permissions${NC}"
REQUIRED_GROUPS=("video" "render" "systemd-journal")
CURRENT_GROUPS=$(groups $USER)

for group in "${REQUIRED_GROUPS[@]}"; do
    if [[ $CURRENT_GROUPS == *"$group"* ]]; then
        echo -e "  ${GREEN}[PASS]${NC} User identifies with group: $group"
    else
        echo -e "  ${RED}[FAIL]${NC} Missing group: $group. Executing remediation..."
        sudo usermod -aG "$group" "$USER"
        echo -e "         -> Membership updated. (Reboot required for full effect)"
    fi
done

# --- PHASE 2: LOG-BASED HEURISTIC ANALYSIS ---
echo -e "\n${BOLD}[PHASE 2] Heuristic Error Detection (Last 100 Events)${NC}"
# Scan for "Host is down" (Socket failure) or "underrun" (A/V Sync failure)
LOG_DATA=$(sudo journalctl -n 100 --no-pager | grep -iE "failed to connect client|Host is down|underrun|va_openDriver")

if [[ ! -z "$LOG_DATA" ]]; then
    echo -e "  ${YELLOW}[DETECTED] Critical events found in system journal:${NC}"
    echo "$LOG_DATA" | tail -n 5 | sed 's/^/    | /'
    
    if [[ $LOG_DATA == *"Host is down"* ]]; then
        echo -e "  ${BLUE}[LOGIC] Identification: PipeWire/Pulse Protocol Mismatch detected.${NC}"
        ACTION_REQUIRED="RESET_STACK"
    fi
else
    echo -e "  ${GREEN}[PASS]${NC} No critical media-layer exceptions detected."
fi

# --- PHASE 3: SERVICE REMEDIATION ---
echo -e "\n${BOLD}[PHASE 3] Audio-Video Sync Stack Reset${NC}"
echo -e "  -> Terminating zombie PipeWire/WirePlumber instances..."
systemctl --user stop pipewire pipewire-pulse wireplumber 2>/dev/null
killall -9 pipewire pipewire-pulse wireplumber 2>/dev/null

echo -e "  -> Purging stale communication sockets in /run/user/..."
rm -rf /run/user/$(id -u)/pulse /run/user/$(id -u)/pipewire

echo -e "  -> Reinitializing unified media services..."
systemctl --user start pipewire wireplumber pipewire-pulse
echo -e "  ${GREEN}[SUCCESS]${NC} Media services synchronized."

# --- PHASE 4: ENVIRONMENT HARDENING ---
echo -e "\n${BOLD}[PHASE 4] Deployment Recommendations${NC}"
echo -e "  To optimize Firefox performance on Intel Hardware (Kali 6.6+):"
echo -e "  ${YELLOW}COMMAND:${NC} export MOZ_DISABLE_RDD_SANDBOX=1 && LIBVA_DRIVER_NAME=iHD firefox"

# Optional: Suggest permanent Alias
if ! grep -q "alias fix-media" ~/.zshrc; then
    echo -e "\n  ${BLUE}[SUGGESTION]${NC} Add this alias to your shell profile (~/.zshrc):"
    echo -e "  alias fix-media='export MOZ_DISABLE_RDD_SANDBOX=1 && LIBVA_DRIVER_NAME=iHD firefox'"
fi

echo -e "\n${BLUE}${BOLD}====================================================${NC}"
echo -e "   Diagnostic Complete. System Ready.                "
echo -e "${BLUE}${BOLD}====================================================${NC}"
