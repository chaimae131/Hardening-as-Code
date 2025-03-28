#!/bin/bash

# Define colors for styling
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
RESET='\033[0m'


function ipv4() {
echo "------------------------------------------------------------"		

echo "Hardening IPv4 Network"

# Sysctl configuration file
SYSCTL_FILE="/etc/sysctl.d/99-anssi-hardening.conf"

# Creating or overwriting the configuration file
echo "Changing security settings to enhance IPv4 protection"
cat <<EOF > $SYSCTL_FILE

# Mitigating the JIT kernel bounce
net.core.bpf_jit_harden=2

# No routing between interfaces
net.ipv4.ip_forward=0

# Consider network source 127/8 as invalid
net.ipv4.conf.all.accept_local=0

# Reject ICMP redirect packets
net.ipv4.conf.all.accept_redirects=0
net.ipv4.conf.default.accept_redirects=0
net.ipv4.conf.all.secure_redirects=0
net.ipv4.conf.default.secure_redirects=0

# Disable shared media
net.ipv4.conf.all.shared_media=0
net.ipv4.conf.default.shared_media=0

# Reject source routing headers
net.ipv4.conf.all.accept_source_route=0
net.ipv4.conf.default.accept_source_route=0

# Strict ARP table management
net.ipv4.conf.all.arp_filter=1
net.ipv4.conf.all.arp_ignore=2

# Reject packets with 127/8 source/destination addresses
net.ipv4.conf.all.route_localnet=0

# Ignore gratuitous ARP
net.ipv4.conf.all.drop_gratuitous_arp=1

# Strict packet filtering based on source interface
net.ipv4.conf.default.rp_filter=1
net.ipv4.conf.all.rp_filter=1

# Disable ICMP redirect packet sending
net.ipv4.conf.default.send_redirects=0
net.ipv4.conf.all.send_redirects=0

# Ignore malformed ICMP responses
net.ipv4.icmp_ignore_bogus_error_responses=1

# Increase ephemeral port range
net.ipv4.ip_local_port_range=32768 65535

# Enable RFC 1337 to avoid TIME_WAIT attack
net.ipv4.tcp_rfc1337=1

# Enable SYN cookies to prevent SYN flood attacks
net.ipv4.tcp_syncookies=1
EOF

# Apply the security settings immediately
echo "Applying network security settings..."
sysctl -p $SYSCTL_FILE >/dev/null 2>&1

# Completion message
echo "IPv4 Network Hardening successfully completed!"
echo "------------------------------------------------------------"		
}
function ipv6(){
echo "Hardening IPv6 Network"

# Function to check if GRUB 2 is used
is_grub2() {
    if grub-install --version 2>/dev/null | grep -q "GRUB 2"; then
        return 0
    else
        return 1
    fi
}

# If GRUB 2 is detected
if is_grub2; then
    echo "GNU GRUB 2 detected. Modifying /etc/default/grub..."

    GRUB_CONFIG="/etc/default/grub"

    # Add or modify the ipv6.disable=1 option
    if grep -q "GRUB_CMDLINE_LINUX" $GRUB_CONFIG; then
        sed -i 's/GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="\1 ipv6.disable=1"/' $GRUB_CONFIG
    else
        echo 'GRUB_CMDLINE_LINUX="ipv6.disable=1"' >> $GRUB_CONFIG
    fi

    # Update GRUB configuration
    echo "Updating GRUB..."
    update-grub > /dev/null 2>&1
    echo "IPv6 disabled via GRUB. Please restart your system to apply the changes."
else
    echo "GRUB 2 not detected. Disabling IPv6 via /etc/sysctl.conf..."

    # Add the parameters to disable IPv6
    echo "net.ipv6.conf.all.disable_ipv6=1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.default.disable_ipv6=1" >> /etc/sysctl.conf

    # Apply the changes immediately
    sysctl -p > /dev/null 2>&1
    echo "IPv6 disabled via sysctl.conf. No restart required."
fi

echo "------------------------------------------------------------"
}

function stack(){
echo "Configuring compilation options for the network stack"
configure_network() {
    echo "net.ipv6.conf.all.disable_ipv6=1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.default.disable_ipv6=1" >> /etc/sysctl.conf
    sysctl -p
}
echo "Network settings configured. No restart is necessary."
echo "------------------------------------------------------------"
}

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}This script must be run as root!${RESET}"
    exit 1
else
    while true; do
        echo -e "${BLUE}***********************************************************${RESET}"
        echo -e "${bLUE}*                  Network Script Menu                    *${RESET}"
        echo -e "${BLUE}***********************************************************${RESET}"
        echo -e "${WHITE}* 1) Harden IPv4 parameters                              *${RESET}"
        echo -e "${WHITE}* 2) Harden IPv6 parameters                              *${RESET}"           
        echo -e "${WHITE}* 3) Configure network stack compilation options         *${RESET}" 
        echo -e "${WHITE}* 4) Exit                                                *${RESET}"                             
        echo -e "${BLUE}***********************************************************${RESET}"
        echo -e "\nPlease select an option: "
        read choice
        case $choice in
            1) ipv4 ;;
            2) ipv6 ;;
            3) stack ;;
            4) echo -e "${CYAN}[INFO] Exiting the script...${RESET}"
               exit ;;
            *) echo -e "${RED}Invalid option. Please try again.${RESET}" ;;
        esac
        echo -e "\nPress any key to return to the menu..."
        read -n 1 -s
    done
fi
