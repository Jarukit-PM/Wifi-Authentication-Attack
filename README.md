# 🔓 Wi-Fi Authentication Bypass Simulation

A cybersecurity mini project simulating Wi-Fi authentication bypass techniques such as WPA handshake capture, Hashcat-based password cracking, deauthentication, and Evil Twin attacks with a Python + Flask captive portal.

> 🚫 **For Educational Purposes Only. Do not use on unauthorized networks.**

# ⚠️ DISCLAIMER ⚠️

This project is created **strictly for educational and research purposes only**.

By using this repository, you agree that the author is **not responsible** for any misuse or illegal activity carried out with the help of this code or related materials.

> **Do NOT use this toolkit on any network you do not own or do not have explicit permission to test.**

**Any consequences of unauthorized or malicious use are solely the responsibility of the user.**

---

## 🧠 Project Overview

This project demonstrates several real-world Wi-Fi attacks in a virtual lab using Kali Linux on VMware Workstation. The core components include:

- WPA/WPA2 Handshake Capture
- Cracking `.22000` files with **Hashcat**
- Deauthentication Attacks via **aireplay-ng** and **mdk4**
- Evil Twin Attack using `hostapd`, `dnsmasq`, and a **Flask web server** (captive portal)

---
## 🧪 Features

### 🔍 Scanning & Capturing

- Scan nearby Wi-Fi networks
- Lock to specific AP + channel
- Capture WPA/WPA2 handshakes

### 📤 Deauthentication

- Disconnect clients to force reconnection
- Use either:
  - `aireplay-ng` (targeted)
  - `mdk4` (broadcast)

### 🔓 WPA Password Cracking

- Convert `.cap` to `.22000` using `hcxpcapngtool`
- Crack using **Hashcat** with options:
  - Rockyou wordlist
  - Custom wordlist
  - Rule-based (`best64.rule`)
  - Mask-based patterns

### 🎭 Evil Twin Attack

- Fake AP with **hostapd**
- DHCP/DNS redirection with **dnsmasq**
- Captive portal hosted via **Flask** (Python)
- Credential collection to `credentials.txt`

---

## 💡 Flask Captive Portal

When a victim connects to the fake AP, their device is redirected to a login form. Credentials are stored in `evil-twin-attack/credentials.txt`.

> Flask listens on `0.0.0.0:80` to catch captive portal auto-detection on Windows, Android, iOS, etc.

---

## 📸 Screenshots

> ![image](https://github.com/user-attachments/assets/47e6eae8-910c-4ad1-8989-c8fc785351b2)



---

## ⚙️ Environment Setup

| Item                | Details                                    |
|---------------------|---------------------------------------------|
| **Host OS**         | Windows (VMware Workstation)                |
| **Guest OS**        | Kali Linux                                  |
| **Wi-Fi Adapter**   | TP-Link Archer T2U Plus (AC600 USB)         |
| **Wireless Interface** | `wlan0` (monitor mode enabled manually) |
| **Main Script**     | `wifi_attack.sh`                            |

---
## 📂 Project Structure

```
wifi-auth-bypass-simulation/
├── wifi_attack.sh                # Main interactive bash menu
├── evil-twin-attack/
│   ├── start-evil-twin.sh       # Sets up rogue AP and starts server
│   ├── hostapd.conf             # Fake AP configuration
│   ├── dnsmasq.conf             # DHCP & DNS redirect config
│   ├── app.py                   # Flask server (captive portal)
│   ├── templates/
│   │   ├── index.html           # Login form for fake AP
│   │   └── thankyou.html        # Post-submission thank you
│   └── credentials.txt          # Stored captured passwords
├── wordlists/                   # Optional wordlists
└── README.md
```

---
## 🚀 How to Run

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/wifi-auth-bypass-simulation.git
cd wifi-auth-bypass-simulation
```

### 2. Make the Script Executable

```bash
chmod +x wifi_attack.sh
```

### 3. Run the Menu

```bash
./wifi_attack.sh
```

### ✅ Start Here:

1. Choose option `1` to **Setup Wi-Fi Adapter**
2. Choose option `4` to **Enable Monitor Mode**

---

## 📚 References

- [Hashcat Documentation](https://hashcat.net/wiki/)
- [Aircrack-ng Suite](https://www.aircrack-ng.org/)
- [hcxtools](https://github.com/ZerBea/hcxtools)
- [Flask Framework](https://flask.palletsprojects.com/)
- [TP-Link T2U Plus Driver](https://github.com/aircrack-ng/rtl8812au)

---

💻 Created by a 3rd-Year Computer Engineering Student  
Mini Project – Cybersecurity: **Wi-Fi Authentication Bypass Simulation**
