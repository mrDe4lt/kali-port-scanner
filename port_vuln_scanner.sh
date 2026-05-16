#!/bin/bash

################################################################################
# Comprehensive Port Vulnerability Scanner for Kali Linux
# Description: Advanced port scanning and vulnerability detection tool
# Author: Security Team
# Date: 2026-05-16
################################################################################

set -euo pipefail

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Global variables
TARGET=""
PORTS=""
OUTPUT_DIR="./port_scan_results_$(date +%Y%m%d_%H%M%S)"
VERBOSE=false
FULL_SCAN=false
QUICK_SCAN=false
AGGRESSIVE=false
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

################################################################################
# Function: Display banner
################################################################################
display_banner() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════════════════════╗
║                                                                           ║
║          COMPREHENSIVE PORT VULNERABILITY SCANNER v2.0                   ║
║                         for Kali Linux                                    ║
║                                                                           ║
║  Advanced security scanning with multiple vulnerability detection        ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

################################################################################
# Function: Display usage
################################################################################
usage() {
    cat << EOF
${YELLOW}USAGE:${NC}
    $0 -t <target> [OPTIONS]

${YELLOW}REQUIRED:${NC}
    -t, --target <host>         Target IP address or hostname

${YELLOW}OPTIONS:${NC}
    -p, --ports <ports>         Specific ports (e.g., 22,80,443 or 1-1000)
                                Default: scan common ports
    -q, --quick                 Quick scan mode (top 100 ports)
    -f, --full                  Full scan mode (all 65535 ports)
    -a, --aggressive            Aggressive scan (OS detection, version detection)
    -v, --verbose               Verbose output
    -o, --output <dir>          Output directory (default: ./port_scan_results_*)
    -h, --help                  Display this help message

${YELLOW}EXAMPLES:${NC}
    # Quick scan of common ports
    $0 -t 192.168.1.100 -q

    # Scan specific ports with aggressive mode
    $0 -t example.com -p 22,80,443,3306 -a

    # Full scan with verbose output
    $0 -t 10.0.0.50 -f -v

    # Scan network range
    $0 -t 192.168.1.0/24 -q

EOF
    exit 0
}

################################################################################
# Function: Check prerequisites
################################################################################
check_prerequisites() {
    echo -e "${BLUE}[*] Checking prerequisites...${NC}"
    
    local missing_tools=()
    
    # Check for required tools
    for tool in nmap nc timeout curl; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    # Optional tools
    for tool in nikto wpscan hydra searchsploit sslscan; do
        if ! command -v "$tool" &> /dev/null; then
            echo -e "${YELLOW}[!] Optional tool '$tool' not found${NC}"
        fi
    done
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        echo -e "${RED}[!] Missing required tools: ${missing_tools[*]}${NC}"
        echo -e "${YELLOW}[*] Please install them with: apt-get install ${missing_tools[*]}${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}[+] All prerequisites met${NC}"
}

################################################################################
# Function: Validate IP/Hostname
################################################################################
validate_target() {
    local target=$1
    
    # Check if it's a valid IP or hostname
    if [[ $target =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}(/[0-9]{1,2})?$ ]] || \
       [[ $target =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$ ]]; then
        return 0
    else
        echo -e "${RED}[!] Invalid target format: $target${NC}"
        return 1
    fi
}

################################################################################
# Function: Create output directory
################################################################################
create_output_dir() {
    if [ ! -d "$OUTPUT_DIR" ]; then
        mkdir -p "$OUTPUT_DIR"
        echo -e "${GREEN}[+] Output directory created: $OUTPUT_DIR${NC}"
    fi
}

################################################################################
# Function: Run basic Nmap scan
################################################################################
nmap_scan() {
    local target=$1
    local ports=$2
    local output_file="$OUTPUT_DIR/01_nmap_scan.txt"
    
    echo -e "${BLUE}[*] Running Nmap scan...${NC}"
    
    local nmap_opts="-sV -sC -O --version-intensity 9"
    
    if [ "$QUICK_SCAN" = true ]; then
        nmap_opts="$nmap_opts --top-ports 100"
    elif [ "$FULL_SCAN" = true ]; then
        nmap_opts="$nmap_opts -p-"
    elif [ -n "$ports" ]; then
        nmap_opts="$nmap_opts -p $ports"
    else
        nmap_opts="$nmap_opts --top-ports 1000"
    fi
    
    if [ "$AGGRESSIVE" = true ]; then
        nmap_opts="$nmap_opts -A -T4"
    else
        nmap_opts="$nmap_opts -T3"
    fi
    
    if [ "$VERBOSE" = true ]; then
        nmap_opts="$nmap_opts -v"
    fi
    
    eval "nmap $nmap_opts $target | tee $output_file"
    
    # Also save XML output for further processing
    eval "nmap $nmap_opts -oX $OUTPUT_DIR/01_nmap_scan.xml $target" 2>/dev/null
    
    echo -e "${GREEN}[+] Nmap scan completed. Results saved to $output_file${NC}"
}

################################################################################
# Function: Service enumeration
################################################################################
service_enumeration() {
    local target=$1
    local output_file="$OUTPUT_DIR/02_service_enumeration.txt"
    
    echo -e "${BLUE}[*] Performing service enumeration...${NC}"
    
    {
        echo "=== Service Enumeration Report ==="
        echo "Target: $target"
        echo "Date: $(date)"
        echo ""
        
        # Extract open ports from nmap results
        local open_ports=$(grep "open" "$OUTPUT_DIR/01_nmap_scan.txt" | grep -oP '^\d+' | head -20)
        
        for port in $open_ports; do
            echo "=== Port $port ==="
            timeout 5 nc -zv $target $port 2>&1 || true
            timeout 5 bash -c "cat < /dev/null > /dev/tcp/$target/$port && echo 'TCP connection successful'" 2>/dev/null || true
            echo ""
        done
    } | tee "$output_file"
    
    echo -e "${GREEN}[+] Service enumeration completed${NC}"
}

################################################################################
# Function: SSL/TLS vulnerability scan
################################################################################
ssl_scan() {
    local target=$1
    local output_file="$OUTPUT_DIR/03_ssl_tls_scan.txt"
    
    echo -e "${BLUE}[*] Scanning SSL/TLS vulnerabilities...${NC}"
    
    if command -v sslscan &> /dev/null; then
        sslscan "$target:443" > "$output_file" 2>&1 || true
        echo -e "${GREEN}[+] SSL/TLS scan completed with sslscan${NC}"
    else
        echo -e "${YELLOW}[!] sslscan not installed, skipping SSL/TLS detailed scan${NC}"
        
        # Fallback to openssl
        {
            echo "=== SSL/TLS Information (openssl) ==="
            echo "Target: $target"
            echo ""
            timeout 5 openssl s_client -connect "$target:443" -showcerts 2>/dev/null | grep -A 20 "subject=" || true
        } | tee "$output_file"
    fi
}

################################################################################
# Function: Web service scanning
################################################################################
web_service_scan() {
    local target=$1
    local output_file="$OUTPUT_DIR/04_web_scan.txt"
    
    echo -e "${BLUE}[*] Scanning web services...${NC}"
    
    # Check if port 80 or 443 is open
    local has_http=false
    
    if grep -q "80/tcp.*open" "$OUTPUT_DIR/01_nmap_scan.txt" 2>/dev/null; then
        has_http=true
    elif grep -q "443/tcp.*open" "$OUTPUT_DIR/01_nmap_scan.txt" 2>/dev/null; then
        has_http=true
    fi
    
    if [ "$has_http" = true ]; then
        {
            echo "=== Web Service Information ==="
            echo "Target: $target"
            echo "Date: $(date)"
            echo ""
            
            # Try HTTP
            if grep -q "80/tcp.*open" "$OUTPUT_DIR/01_nmap_scan.txt" 2>/dev/null; then
                echo "=== HTTP Headers (Port 80) ==="
                timeout 5 curl -I "http://$target" 2>/dev/null || echo "Connection failed"
                echo ""
                
                echo "=== HTTP Robots.txt ==="
                timeout 5 curl "http://$target/robots.txt" 2>/dev/null || echo "Not found"
                echo ""
            fi
            
            # Try HTTPS
            if grep -q "443/tcp.*open" "$OUTPUT_DIR/01_nmap_scan.txt" 2>/dev/null; then
                echo "=== HTTPS Headers (Port 443) ==="
                timeout 5 curl -I -k "https://$target" 2>/dev/null || echo "Connection failed"
                echo ""
            fi
        } | tee "$output_file"
        
        # Run Nikto if available
        if command -v nikto &> /dev/null; then
            echo -e "${BLUE}[*] Running Nikto web server scanner...${NC}"
            nikto -host "$target" -o "$OUTPUT_DIR/04_nikto_report.txt" 2>/dev/null || true
        fi
    else
        echo -e "${YELLOW}[!] No web services detected${NC}"
    fi
    
    echo -e "${GREEN}[+] Web service scan completed${NC}"
}

################################################################################
# Function: Common vulnerability checks
################################################################################
vulnerability_checks() {
    local target=$1
    local output_file="$OUTPUT_DIR/05_vulnerability_analysis.txt"
    
    echo -e "${BLUE}[*] Analyzing for common vulnerabilities...${NC}"
    
    {
        echo "=== Vulnerability Analysis Report ==="
        echo "Target: $target"
        echo "Date: $(date)"
        echo ""
        
        echo "=== Common Open Ports Analysis ==="
        grep "open" "$OUTPUT_DIR/01_nmap_scan.txt" | head -30
        echo ""
        
        echo "=== Service Version Analysis ==="
        grep -A 1 "open" "$OUTPUT_DIR/01_nmap_scan.txt" | grep -E "ssh|http|ftp|smtp|pop|imap" | head -20
        echo ""
        
        echo "=== Potential Vulnerabilities ==="
        
        # Check for FTP
        if grep -q "21/tcp.*open" "$OUTPUT_DIR/01_nmap_scan.txt"; then
            echo "[!] FTP (Port 21) is open - Potential for unencrypted transmission"
        fi
        
        # Check for Telnet
        if grep -q "23/tcp.*open" "$OUTPUT_DIR/01_nmap_scan.txt"; then
            echo "[!] Telnet (Port 23) is open - Highly vulnerable, unencrypted"
        fi
        
        # Check for HTTP
        if grep -q "80/tcp.*open" "$OUTPUT_DIR/01_nmap_scan.txt"; then
            echo "[!] HTTP (Port 80) is open - Unencrypted web traffic"
        fi
        
        # Check for SMB
        if grep -q "445/tcp.*open" "$OUTPUT_DIR/01_nmap_scan.txt"; then
            echo "[!] SMB (Port 445) is open - Potential for ransomware/exploitation"
        fi
        
        # Check for RDP
        if grep -q "3389/tcp.*open" "$OUTPUT_DIR/01_nmap_scan.txt"; then
            echo "[!] RDP (Port 3389) is open - Potential brute force target"
        fi
        
        # Check for MySQL
        if grep -q "3306/tcp.*open" "$OUTPUT_DIR/01_nmap_scan.txt"; then
            echo "[!] MySQL (Port 3306) is open - Check for public access"
        fi
        
        # Check for MSSQL
        if grep -q "1433/tcp.*open" "$OUTPUT_DIR/01_nmap_scan.txt"; then
            echo "[!] MSSQL (Port 1433) is open - Check for weak credentials"
        fi
        
        echo ""
        echo "=== Operating System Detection ==="
        grep -A 5 "OS details:" "$OUTPUT_DIR/01_nmap_scan.txt" || echo "OS detection unavailable"
        
    } | tee "$output_file"
    
    echo -e "${GREEN}[+] Vulnerability analysis completed${NC}"
}

################################################################################
# Function: Generate summary report
################################################################################
generate_summary_report() {
    local target=$1
    local output_file="$OUTPUT_DIR/00_SUMMARY_REPORT.txt"
    
    echo -e "${BLUE}[*] Generating summary report...${NC}"
    
    {
        echo "╔═══════════════════════════════════════════════════════════════╗"
        echo "║         PORT VULNERABILITY SCANNER - SUMMARY REPORT          ║"
        echo "╚═══════════════════════════════════════════════════════════════╝"
        echo ""
        echo "Target:          $target"
        echo "Scan Date:       $(date)"
        echo "Scan Mode:       $([ "$QUICK_SCAN" = true ] && echo "Quick" || ([ "$FULL_SCAN" = true ] && echo "Full" || echo "Standard"))"
        echo "Aggressive:      $AGGRESSIVE"
        echo ""
        echo "═══════════════════════════════════════════════════════════════"
        echo "OPEN PORTS SUMMARY"
        echo "═══════════════════════════════════════════════════════════════"
        echo ""
        
        local open_count=$(grep -c "open" "$OUTPUT_DIR/01_nmap_scan.txt" || echo "0")
        echo "Total Open Ports: $open_count"
        echo ""
        echo "Port Details:"
        grep "open" "$OUTPUT_DIR/01_nmap_scan.txt" | head -50
        echo ""
        
        echo "═══════════════════════════════════════════════════════════════"
        echo "CRITICAL FINDINGS"
        echo "═══════════════════════════════════════════════════════════════"
        echo ""
        
        local critical=0
        
        if grep -q "23/tcp.*open" "$OUTPUT_DIR/01_nmap_scan.txt"; then
            echo "[CRITICAL] Telnet enabled - Immediate action required"
            ((critical++))
        fi
        
        if grep -q "21/tcp.*open" "$OUTPUT_DIR/01_nmap_scan.txt"; then
            echo "[HIGH] FTP enabled - Consider replacing with SFTP/SSH"
            ((critical++))
        fi
        
        if grep -q "445/tcp.*open" "$OUTPUT_DIR/01_nmap_scan.txt"; then
            echo "[HIGH] SMB/NetBIOS exposed - Verify firewall rules"
            ((critical++))
        fi
        
        echo ""
        echo "═══════════════════════════════════════════════════════════════"
        echo "GENERATED REPORTS"
        echo "═══════════════════════════════════════════════════════════════"
        echo ""
        ls -lh "$OUTPUT_DIR"/ | tail -n +2 | awk '{print $9, "(" $5 ")"}'
        echo ""
        echo "═══════════════════════════════════════════════════════════════"
        echo "RECOMMENDATIONS"
        echo "═══════════════════════════════════════════════════════════════"
        echo ""
        echo "1. Close unnecessary open ports using firewall rules"
        echo "2. Update all services to latest secure versions"
        echo "3. Use encryption (SSL/TLS) for all network communications"
        echo "4. Implement strong authentication mechanisms"
        echo "5. Consider implementing IDS/IPS systems"
        echo "6. Regularly update and patch systems"
        echo "7. Run vulnerability assessments periodically"
        echo ""
        
    } | tee "$output_file"
    
    echo -e "${GREEN}[+] Summary report generated${NC}"
}

################################################################################
# Function: Main execution
################################################################################
main() {
    display_banner
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -t|--target)
                TARGET="$2"
                shift 2
                ;;
            -p|--ports)
                PORTS="$2"
                shift 2
                ;;
            -q|--quick)
                QUICK_SCAN=true
                shift
                ;;
            -f|--full)
                FULL_SCAN=true
                shift
                ;;
            -a|--aggressive)
                AGGRESSIVE=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -o|--output)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            -h|--help)
                usage
                ;;
            *)
                echo -e "${RED}[!] Unknown option: $1${NC}"
                usage
                ;;
        esac
    done
    
    # Validate required parameters
    if [ -z "$TARGET" ]; then
        echo -e "${RED}[!] Target is required${NC}"
        usage
    fi
    
    if ! validate_target "$TARGET"; then
        exit 1
    fi
    
    # Check prerequisites
    check_prerequisites
    
    # Create output directory
    create_output_dir
    
    # Verify both quick and full can't be set
    if [ "$QUICK_SCAN" = true ] && [ "$FULL_SCAN" = true ]; then
        echo -e "${YELLOW}[!] Cannot use both --quick and --full. Using --full${NC}"
    fi
    
    echo -e "${CYAN}[*] Starting comprehensive port vulnerability scan of $TARGET${NC}"
    echo -e "${CYAN}[*] Results will be saved to: $OUTPUT_DIR${NC}"
    echo ""
    
    # Run all scans
    nmap_scan "$TARGET" "$PORTS"
    echo ""
    
    service_enumeration "$TARGET"
    echo ""
    
    ssl_scan "$TARGET"
    echo ""
    
    web_service_scan "$TARGET"
    echo ""
    
    vulnerability_checks "$TARGET"
    echo ""
    
    generate_summary_report "$TARGET"
    echo ""
    
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  Scan completed successfully!                                 ║${NC}"
    echo -e "${GREEN}║  Results saved to: $OUTPUT_DIR${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
}

# Run main function
main "$@"