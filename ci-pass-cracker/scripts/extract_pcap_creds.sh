#!/bin/bash
# Script to extract potential hashes/credentials from PCAP files
# Usage: ./extract_pcap_creds.sh <pcap_file>

if [ $# -ne 1 ]; then
    echo "Usage: $0 <pcap_file>"
    exit 1
fi

PCAP_FILE=$1

if [ ! -f "$PCAP_FILE" ]; then
    echo "Error: File does not exist: $PCAP_FILE"
    exit 1
fi

# Install tshark if not already present
apt-get update && apt-get install -y tshark || echo "tshark installation failed"

# Extract potential credentials from the PCAP
echo "# Potential credentials found in $PCAP_FILE"
echo "# This is a sample output - actual implementation would parse for specific protocols"

# Look for HTTP Basic Auth
tshark -r "$PCAP_FILE" -Y 'http.authorization' -T fields -e http.authorization 2>/dev/null | head -10

# Look for FTP credentials
tshark -r "$PCAP_FILE" -Y 'ftp.request.command' -T fields -e ftp.request.command -e ftp.request.parameter 2>/dev/null | head -10

# Look for SSH key exchanges (indicating possible key-based auth)
tshark -r "$PCAP_FILE" -Y 'ssh' -T fields -e ssh.host_key_algorithm -e ssh.host_key 2>/dev/null | head -5

# Look for Kerberos tickets (which may contain password hashes)
tshark -r "$PCAP_FILE" -Y 'kerberos' -T fields -e kerberos.CNameString -e kerberos.Realm 2>/dev/null | head -5

echo "# End of PCAP credential extraction"