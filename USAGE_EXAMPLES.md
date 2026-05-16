# Port Vulnerability Scanner - Usage Examples

Comprehensive guide with 50+ real-world examples for the port vulnerability scanner.

## Quick Start

```bash
# Quick scan
./port_vuln_scanner.sh -t 192.168.1.100 -q

# Aggressive scan
./port_vuln_scanner.sh -t example.com -a -v

# Full scan
./port_vuln_scanner.sh -t 10.0.0.5 -f

# Specific ports
./port_vuln_scanner.sh -t target -p 22,80,443,3306
```

## Basic Examples (1-10)

1. **Simple scan**: `./port_vuln_scanner.sh -t 192.168.1.100`
2. **Quick scan**: `./port_vuln_scanner.sh -t 192.168.1.100 -q`
3. **Full scan**: `./port_vuln_scanner.sh -t 192.168.1.100 -f`
4. **Aggressive**: `./port_vuln_scanner.sh -t 192.168.1.100 -a`
5. **Verbose**: `./port_vuln_scanner.sh -t 192.168.1.100 -v`
6. **Custom output**: `./port_vuln_scanner.sh -t 192.168.1.100 -o /tmp/scan`
7. **Hostname scan**: `./port_vuln_scanner.sh -t example.com -q`
8. **Localhost**: `./port_vuln_scanner.sh -t localhost -q`
9. **CIDR notation**: `./port_vuln_scanner.sh -t 192.168.1.0/24 -q`
10. **Range scan**: `./port_vuln_scanner.sh -t 192.168.1.1-50 -q`

## Service-Specific Examples (11-25)

11. **Web servers**: `./port_vuln_scanner.sh -t target -p 80,443,8080,8443`
12. **Databases**: `./port_vuln_scanner.sh -t target -p 3306,5432,1433`
13. **SSH scan**: `./port_vuln_scanner.sh -t target -p 22,2222`
14. **Email**: `./port_vuln_scanner.sh -t target -p 25,110,143,587,993,995`
15. **DNS**: `./port_vuln_scanner.sh -t target -p 53`
16. **VPN**: `./port_vuln_scanner.sh -t target -p 500,1194,1723`
17. **Remote access**: `./port_vuln_scanner.sh -t target -p 3389,5900,22`
18. **File services**: `./port_vuln_scanner.sh -t target -p 21,445,139,2049`
19. **Web aggressive**: `./port_vuln_scanner.sh -t web.local -p 80,443 -a -v`
20. **Database audit**: `./port_vuln_scanner.sh -t db.local -p 3306,5432 -a`

## Batch Operations (26-35)

26. **Multiple targets (serial)**: 
```bash
for ip in 192.168.1.100 192.168.1.101 192.168.1.102; do
    ./port_vuln_scanner.sh -t $ip -q
done
```

27. **Parallel scanning**:
```bash
for ip in 192.168.1.{1..10}; do
    ./port_vuln_scanner.sh -t $ip -q &
done
wait
```

28. **From file list**:
```bash
while read target; do
    ./port_vuln_scanner.sh -t "$target" -q
done < targets.txt
```

29. **Daily cron job**: `0 2 * * * /path/to/scanner.sh -t 192.168.1.0/24 -q`
30. **Weekly full scan**: `0 3 * * 0 /path/to/scanner.sh -t 192.168.1.100 -f`

## Analysis & Reporting (36-45)

36. **Extract open ports**: `grep "open" port_scan_results_*/01_nmap_scan.txt`
37. **Find critical services**: `grep -E "21|23|445" port_scan_results_*/01_nmap_scan.txt`
38. **Generate CSV**: `grep "open" ... | awk '{print $1, $3}'`
39. **Create HTML report**: `nmap -iX results.xml -oH report.html`
40. **Compare scans**: `diff scan1/results.txt scan2/results.txt`

## Advanced Examples (41-50)

41. **Subnet sweep**: `./port_vuln_scanner.sh -t 10.0.0.0/24 -q`
42. **Compliance scan**: `./port_vuln_scanner.sh -t server -f -a -o /opt/compliance/`
43. **Baseline comparison**: Scan before and after changes
44. **Vulnerability dashboard**: Parse multiple results
45. **Integration with CI/CD**: Automated security scanning
46. **Performance tuning**: Use `-q` for large networks
47. **Quiet mode**: `./port_vuln_scanner.sh -t target -q > /dev/null 2>&1`
48. **Audit logging**: `echo "Scan: $target" >> log.txt`
49. **Archive results**: `tar -czf scan_$(date +%Y%m%d).tar.gz results/`
50. **Cleanup old scans**: `find results_* -mtime +30 -exec rm -rf {} \;`

## Tips & Tricks

### Custom Port Lists
```bash
PORTS=$(cat ports.txt)  # Create ports.txt with comma-separated ports
./port_vuln_scanner.sh -t target -p "$PORTS"
```

### Results Summary
```bash
echo "Total Open Ports: $(grep -c open port_scan_results_*/01_nmap_scan.txt)"
echo "Targets Scanned: $(ls -d port_scan_results_* | wc -l)"
```

### Network Assessment
```bash
./port_vuln_scanner.sh -t 192.168.1.0/24 -q
grep "open" port_scan_results_*/01_nmap_scan.txt
cat port_scan_results_*/00_SUMMARY_REPORT.txt
```

---

**More examples available in full documentation**