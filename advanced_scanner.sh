#!/bin/bash

################################################################################
# Advanced Port Vulnerability Scanner with CVE/Exploit Analysis
# Description: Extended vulnerability detection with database searches
# Author: Mr D4LT
# Date: 2026-05-16
################################################################################

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

OUTPUT_DIR="./advanced_scan_$(date +%Y%m%d_%H%M%S)"
TARGET=""

################################################################################
# CVE Lookup Function
################################################################################
lookup_cves() {
    local service=$1
    local version=$2
    local output_file="$OUTPUT_DIR/cve_analysis.txt"
    
    echo -e "${BLUE}[*] Looking up CVEs for $service $version...${NC}"
    
    if command -v searchsploit &> /dev/null; then
        {
            echo "=== CVE/Exploit Search Results ==="
            echo "Service: $service"
            echo "Version: $version"
            echo ""
            searchsploit $service $version || echo "No exploits found"
        } | tee -a "$output_file"
    else
        echo -e "${YELLOW}[!] searchsploit not found, skipping CVE lookup${NC}"
    fi
}

################################################################################
# Service-Specific Analysis
################################################################################
analyze_service() {
    local service=$1
    local port=$2
    local target=$3
    local output_file="$OUTPUT_DIR/service_analysis.txt"
    
    echo -e "${BLUE}[*] Analyzing $service on port $port...${NC}"
    
    case $service in
        ssh)
            {
                echo "=== SSH Analysis ==="
                timeout 5 ssh -v $target 2>&1 | head -20 || true
                echo ""
                echo "[*] SSH Security Recommendations:"
                echo "    - Disable root login"
                echo "    - Use key-based authentication"
                echo "    - Change default SSH port"
                echo "    - Disable password authentication"
            } | tee -a "$output_file"
            ;;
        http|https)
            {
                echo "=== HTTP(S) Analysis ==="
                timeout 5 curl -I -v "$service://$target" 2>&1 | grep -E "Server|X-|Content-" || true
                echo ""
                echo "[*] Web Server Security Recommendations:"
                echo "    - Update web server software"
                echo "    - Disable unnecessary HTTP methods"
                echo "    - Configure security headers"
                echo "    - Enable HTTPS/TLS"
            } | tee -a "$output_file"
            ;;
        ftp)
            {
                echo "=== FTP Analysis ==="
                echo "[!] CRITICAL: FTP transmits credentials in plaintext"
                echo "[*] Recommendations:"
                echo "    - Disable FTP immediately"
                echo "    - Use SFTP instead"
                echo "    - Use SSH keys for authentication"
            } | tee -a "$output_file"
            ;;
    esac
}

################################################################################
# Security Scoring
################################################################################
calculate_security_score() {
    local nmap_file="${1:-}"
    local score=100
    
    if [ ! -f "$nmap_file" ]; then
        echo "0"
        return
    fi
    
    # Deduct points for dangerous services
    grep -q "21/tcp.*open" "$nmap_file" && score=$((score - 15))
    grep -q "23/tcp.*open" "$nmap_file" && score=$((score - 30))
    grep -q "445/tcp.*open" "$nmap_file" && score=$((score - 10))
    grep -q "3389/tcp.*open" "$nmap_file" && score=$((score - 10))
    grep -q "3306/tcp.*open" "$nmap_file" && score=$((score - 8))
    grep -q "5432/tcp.*open" "$nmap_file" && score=$((score - 8))
    
    # Check for old services
    grep -q "OpenSSH_[4-6]" "$nmap_file" && score=$((score - 20))
    grep -q "Apache/2\.[0-2]" "$nmap_file" && score=$((score - 15))
    
    # Ensure score doesn't go below 0
    [ $score -lt 0 ] && score=0
    
    echo $score
}

################################################################################
# Generate Advanced Report
################################################################################
generate_advanced_report() {
    local target=$1
    local nmap_file="${2:-}"
    local output_file="$OUTPUT_DIR/ADVANCED_REPORT.txt"
    
    {
        echo "╔═══════════════════════════════════════════════════════════════════════════╗"
        echo "║       ADVANCED SECURITY ANALYSIS REPORT                      ║"
        echo "╚═══════════════════════════════════════════════════════════════════════════╝"
        echo ""
        echo "Target:       $target"
        echo "Scan Date:    $(date)"
        echo ""
        
        local score=0
        if [ -f "$nmap_file" ]; then
            score=$(calculate_security_score "$nmap_file")
        fi
        
        echo "═══════════════════════════════════════════════════════════════════════════"
        echo "SECURITY SCORE: $score/100"
        echo "═══════════════════════════════════════════════════════════════════════════"
        echo ""
        
        if [ $score -ge 80 ]; then
            echo -e "${GREEN}[+] EXCELLENT - Low risk environment${NC}"
        elif [ $score -ge 60 ]; then
            echo -e "${YELLOW}[!] GOOD - Moderate risk, some improvements recommended${NC}"
        elif [ $score -ge 40 ]; then
            echo -e "${YELLOW}[!] FAIR - Significant vulnerabilities detected${NC}"
        else
            echo -e "${RED}[!] POOR - Critical vulnerabilities present${NC}"
        fi
        
        echo ""
        echo "═══════════════════════════════════════════════════════════════════════════"
        echo "DETAILED FINDINGS"
        echo "═══════════════════════════════════════════════════════════════════════════"
        echo ""
        
        if [ -f "$nmap_file" ]; then
            echo "Open Services:"
            grep "open" "$nmap_file" | head -20
            echo ""
        fi
        
        echo "═══════════════════════════════════════════════════════════════════════════"
        echo "REMEDIATION STEPS"
        echo "═══════════════════════════════════════════════════════════════════════════"
        echo ""
        echo "Priority 1 (Immediate):"
        echo "  1. Identify and close unnecessary open ports"
        echo "  2. Disable legacy protocols (Telnet, FTP, SMTP)"
        echo "  3. Update all services to latest versions"
        echo ""
        echo "Priority 2 (Short-term):"
        echo "  1. Implement firewall rules"
        echo "  2. Enable SSL/TLS for all services"
        echo "  3. Implement intrusion detection"
        echo ""
        echo "Priority 3 (Long-term):"
        echo "  1. Implement WAF (Web Application Firewall)"
        echo "  2. Regular vulnerability scanning"
        echo "  3. Security awareness training"
        echo ""
        
    } | tee "$output_file"
}

################################################################################
# Main
################################################################################
main() {
    echo -e "${CYAN}"
    cat << "EOF"
╔════════════════════════════════════════════════════════════════════════════╗
║      ADVANCED PORT VULNERABILITY SCANNER v2.0                 ║ AUTHOR
║            Enhanced CVE & Exploit Analysis                    ║ Mr D4LT
╚════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    TARGET="${1:-}"
    
    if [ -z "$TARGET" ]; then
        echo -e "${RED}[!] Usage: $0 <target>${NC}"
        exit 1
    fi
    
    mkdir -p "$OUTPUT_DIR"
    
    echo -e "${CYAN}[*] Starting advanced vulnerability analysis of $TARGET${NC}"
    echo -e "${CYAN}[*] Results saved to: $OUTPUT_DIR${NC}"
    echo ""
    
    # Run initial nmap scan
    local nmap_output="$OUTPUT_DIR/nmap_initial.txt"
    nmap -sV -O "$TARGET" -o "$nmap_output"
    
    # Generate advanced report
    generate_advanced_report "$TARGET" "$nmap_output"
    
    echo -e "${GREEN}[+] Advanced analysis complete!${NC}"
}

main "$@"
