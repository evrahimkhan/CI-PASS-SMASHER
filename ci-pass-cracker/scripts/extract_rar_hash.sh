#!/bin/bash
# Script to extract hash from RAR files
# Usage: ./extract_rar_hash.sh <rar_file>

if [ $# -ne 1 ]; then
    echo "Usage: $0 <rar_file>"
    exit 1
fi

RAR_FILE=$1

if [ ! -f "$RAR_FILE" ]; then
    echo "Error: File does not exist: $RAR_FILE"
    exit 1
fi

# Use rar2john to extract the hash
/usr/local/bin/rar2john "$RAR_FILE"