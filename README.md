# Comprehensive Port Vulnerability Scanner for Kali Linux

A professional-grade port scanning and vulnerability detection tool designed for Kali Linux security professionals.

## Features

### 🎯 Core Capabilities
- **Multiple Scan Modes**
  - Quick scan (top 100 ports)
  - Standard scan (top 1000 ports)
  - Full scan (all 65535 ports)
  - Custom port ranges

- **Advanced Detection**
  - Service version detection
  - OS fingerprinting
  - Script-based vulnerability scanning
  - SSL/TLS vulnerability analysis
  - Web service enumeration

- **Vulnerability Analysis**
  - Common misconfiguration detection
  - Service-specific weakness identification
  - CVE/Exploit database lookup
  - Security scoring (0-100)

- **Professional Reporting**
  - Detailed HTML/XML exports
  - Summary reports
  - Vulnerability analysis
  - Remediation recommendations
  - Security score assessment

## Installation

### Quick Start (Automated)
```bash
git clone https://github.com/mrDe4lt/kali-port-scanner.git
cd kali-port-scanner
sudo bash install.sh
```

### Manual Installation
```bash
# Install dependencies
sudo apt-get update
sudo apt-get install -y nmap curl netcat-openbsd openssl

# Optional security tools
sudo apt-get install -y nikto sslscan wpscan hydra

# Make scripts executable
chmod +x port_vuln_scanner.sh advanced_scanner.sh
```

## Usage

### Basic Scan
```bash
./port_vuln_scanner.sh -t 192.168.1.100
```

### Quick Scan (Common Ports)
```bash
./port_vuln_scanner.sh -t 192.168.1.100 -q
```

### Full Scan (All Ports)
```bash
./port_vuln_scanner.sh -t 192.168.1.100 -f
```

### Aggressive Mode
```bash
./port_vuln_scanner.sh -t 192.168.1.100 -a
```

### Specific Ports
```bash
./port_vuln_scanner.sh -t 192.168.1.100 -p 22,80,443,3306
```

### With Verbose Output
```bash
./port_vuln_scanner.sh -t 192.168.1.100 -v
```

### Custom Output Directory
```bash
./port_vuln_scanner.sh -t 192.168.1.100 -o /tmp/my_scan
```

## Advanced Scanner

For extended vulnerability analysis with CVE lookups:

```bash
./advanced_scanner.sh 192.168.1.100
```

Features:
- CVE/Exploit database searching
- Service-specific vulnerability analysis
- Security posture scoring
- Detailed remediation steps

## Command-Line Options

```
USAGE:
    ./port_vuln_scanner.sh -t <target> [OPTIONS]

REQUIRED:
    -t, --target <host>         Target IP address or hostname

OPTIONS:
    -p, --ports <ports>         Specific ports (e.g., 22,80,443 or 1-1000)
                                Default: scan common ports
    -q, --quick                 Quick scan mode (top 100 ports)
    -f, --full                  Full scan mode (all 65535 ports)
    -a, --aggressive            Aggressive scan (OS detection, version detection)
    -v, --verbose               Verbose output
    -o, --output <dir>          Output directory (default: ./port_scan_results_*)
    -h, --help                  Display help message
```

## Output Files

Each scan generates multiple reports:

1. **00_SUMMARY_REPORT.txt** - Executive summary with critical findings
2. **01_nmap_scan.txt** - Full Nmap output
3. **01_nmap_scan.xml** - Structured XML results
4. **02_service_enumeration.txt** - Detailed service information
5. **03_ssl_tls_scan.txt** - SSL/TLS certificate analysis
6. **04_web_scan.txt** - Web server analysis and headers
7. **04_nikto_report.txt** - Nikto web vulnerability scan (if available)
8. **05_vulnerability_analysis.txt** - Common vulnerability assessment

## Vulnerability Categories

### Critical
- Telnet enabled (port 23)
- No encryption on network services
- Default credentials

### High
- FTP enabled (unencrypted file transfer)
- SMB/NetBIOS exposed (ransomware risk)
- Old/unpatched services
- Weak SSL/TLS configuration

### Medium
- Unnecessary services running
- Missing security headers
- Weak authentication mechanisms
- Outdated software versions

### Low
- Information disclosure
- Best practice violations

## Security Scoring

The scanner provides a 0-100 security score:

- **80-100**: Excellent - Low risk
- **60-79**: Good - Moderate risk
- **40-59**: Fair - Significant vulnerabilities
- **0-39**: Poor - Critical vulnerabilities

## Real-World Examples

### Scan an entire network
```bash
./port_vuln_scanner.sh -t 192.168.1.0/24 -q
```

### Scan specific web service ports
```bash
./port_vuln_scanner.sh -t example.com -p 80,443,8080,8443 -a
```

### Database server scan
```bash
./port_vuln_scanner.sh -t db.internal.net -p 3306,5432,1433 -v
```

### Save results to specific location
```bash
./port_vuln_scanner.sh -t 10.0.0.5 -f -o /opt/security/scans/
```

## Legal and Ethical Considerations

⚠️ **IMPORTANT:**

- **Authorization**: Only scan systems you own or have explicit written permission to test
- **Legal**: Unauthorized scanning may violate computer fraud and abuse laws
- **Ethics**: Always operate within legal and ethical boundaries
- **Professional**: Use responsibly in authorized penetration testing engagements

## Requirements

### System Requirements
- Kali Linux (or compatible Debian-based Linux)
- Root/sudo privileges for network scanning
- Minimum 512MB RAM
- Internet connection for CVE database lookups

### Required Software
- Nmap (network mapping)
- Curl (HTTP requests)
- Netcat (network utility)
- OpenSSL (encryption)
- Bash 4+

### Optional Software (Enhanced Features)
- Nikto (web vulnerability scanning)
- SSLScan (SSL/TLS analysis)
- WPScan (WordPress scanning)
- Hydra (brute force)
- Searchsploit (exploit searching)

## Troubleshooting

### "Command not found"
```bash
chmod +x port_vuln_scanner.sh
./port_vuln_scanner.sh -h
```

### "Permission denied"
```bash
sudo ./port_vuln_scanner.sh -t target -q
```

### "Nmap not found"
```bash
sudo apt-get install nmap
```

### "No results"
- Check target is accessible: `ping target`
- Verify no firewall blocking: `traceroute target`
- Try aggressive mode: `-a`
- Check Nmap output directly: `nmap -sV target`

## Performance Tips

1. **Quick Scans**: Use `-q` for initial assessment
2. **Parallel Scanning**: Run multiple instances on different targets
3. **Port Prioritization**: Scan common ports first with `-p 1-1000`
4. **Network Bandwidth**: Use `-T3` (default) for stable networks

## Advanced Usage

### Cron Job for Regular Scanning
```bash
# Add to crontab
0 2 * * 0 /path/to/port_vuln_scanner.sh -t 192.168.1.0/24 -q -o /var/log/security/scans/
```

### Batch Scanning
```bash
for target in 192.168.1.{1..254}; do
    ./port_vuln_scanner.sh -t $target -q &
done
wait
```

### Integration with Other Tools
```bash
# Parse results for further analysis
grep "open" port_scan_results_*/01_nmap_scan.txt | awk '{print $1}' > open_ports.txt
```

## Contributing

Contributions are welcome! Areas for improvement:
- Additional vulnerability checks
- Better CVE database integration
- Enhanced reporting formats
- Performance optimization

## License

MIT License - See LICENSE file for details

## Disclaimer

This tool is provided for educational and authorized security testing purposes only. Users are responsible for ensuring they have proper authorization before scanning any network or system. Unauthorized access to computer systems is illegal.

## Support

For issues and feature requests, please open an issue on GitHub.

## Version History

### v2.0 (Current)
- Advanced CVE analysis
- Improved reporting
- Security scoring
- Multiple scan modes

### v1.0
- Initial release
- Basic port scanning
- Service detection

---

**Last Updated**: 2026-05-16
**Author**: Security Team
**Maintained By**: Community