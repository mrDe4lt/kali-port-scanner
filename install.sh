#!/bin/bash

################################################################################
# Installation Script for Port Vulnerability Scanner
# Description: Automated setup and dependency installation
# Author: Security Team
# Date: 2026-05-16
################################################################################

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

################################################################################
# Display banner
################################################################################
display_banner() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
╔════════════════════════════════════════════════════════════════════════════╗
║  Port Vulnerability Scanner - Installation Script             ║
║                    for Kali Linux                              ║
╚════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

################################################################################
# Check if running as root
################################################################################
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}[!] This script must be run as root${NC}"
        echo -e "${YELLOW}[*] Run: sudo $0${NC}"
        exit 1
    fi
}

################################################################################
# Install dependencies
################################################################################
install_dependencies() {
    echo -e "${BLUE}[*] Installing required packages...${NC}"
    
    apt-get update
    apt-get install -y \
        nmap \
        curl \
        netcat-openbsd \
        openssl \
        git \
        vim \
        python3 \
        python3-pip
    
    echo -e "${GREEN}[+] Required packages installed${NC}"
}

################################################################################
# Install optional tools
################################################################################
install_optional_tools() {
    echo -e "${BLUE}[*] Installing optional security tools...${NC}"
    
    local tools=("nikto" "sslscan" "wpscan" "hydra" "searchsploit")
    
    for tool in "${tools[@]}"; do
        echo -e "${YELLOW}[*] Installing $tool...${NC}"
        apt-get install -y "$tool" 2>/dev/null || echo -e "${YELLOW}[!] $tool installation skipped${NC}"
    done
    
    echo -e "${GREEN}[+] Optional tools installation completed${NC}"
}

################################################################################
# Setup scanner
################################################################################
setup_scanner() {
    echo -e "${BLUE}[*] Setting up scanner scripts...${NC}"
    
    # Make scripts executable
    chmod +x port_vuln_scanner.sh
    chmod +x advanced_scanner.sh
    
    # Create symbolic link for easy access
    ln -sf "$(pwd)/port_vuln_scanner.sh" /usr/local/bin/port-scan
    ln -sf "$(pwd)/advanced_scanner.sh" /usr/local/bin/port-scan-advanced
    
    echo -e "${GREEN}[+] Scanner setup completed${NC}"
    echo -e "${GREEN}[+] You can now use 'port-scan' and 'port-scan-advanced' commands${NC}"
}

################################################################################
# Verify installation
################################################################################
verify_installation() {
    echo -e "${BLUE}[*] Verifying installation...${NC}"
    
    local failed=0
    
    for tool in nmap curl nc openssl; do
        if command -v "$tool" &> /dev/null; then
            echo -e "${GREEN}[+] $tool: OK${NC}"
        else
            echo -e "${RED}[-] $tool: FAILED${NC}"
            failed=$((failed + 1))
        fi
    done
    
    if [ $failed -eq 0 ]; then
        echo -e "${GREEN}[+] All dependencies verified successfully${NC}"
    else
        echo -e "${RED}[!] Some dependencies failed verification${NC}"
    fi
}

################################################################################
# Main
################################################################################
main() {
    display_banner
    check_root
    
    echo -e "${YELLOW}This will install the Port Vulnerability Scanner and its dependencies.${NC}"
    echo ""
    read -p "Continue? (y/n) " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}[*] Installation cancelled${NC}"
        exit 1
    fi
    
    install_dependencies
    echo ""
    
    read -p "Install optional security tools? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_optional_tools
    fi
    echo ""
    
    setup_scanner
    echo ""
    
    verify_installation
    echo ""
    
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  Installation completed successfully!                         ║${NC}"
    echo -e "${GREEN}║                                                              ║${NC}"
    echo -e "${GREEN}║  Quick start:                                                ║${NC}"
    echo -e "${GREEN}║    port-scan -t 192.168.1.100 -q                           ║${NC}"
    echo -e "${GREEN}║                                                              ║${NC}"
    echo -e "${GREEN}║  For help:                                                   ║${NC}"
    echo -e "${GREEN}║    port-scan -h                                             ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
}

main "$@"