#!/bin/bash
# Script to extract hash from Office files
# Usage: ./extract_office_hash.sh <office_file>

if [ $# -ne 1 ]; then
    echo "Usage: $0 <office_file>"
    exit 1
fi

OFFICE_FILE=$1

if [ ! -f "$OFFICE_FILE" ]; then
    echo "Error: File does not exist: $OFFICE_FILE"
    exit 1
fi

# Use office2john to extract the hash
/usr/local/bin/office2john.pl "$OFFICE_FILE"