#!/bin/bash
# Script to extract hash from ZIP files
# Usage: ./extract_zip_hash.sh <zip_file>

if [ $# -ne 1 ]; then
    echo "Usage: $0 <zip_file>"
    exit 1
fi

ZIP_FILE=$1

if [ ! -f "$ZIP_FILE" ]; then
    echo "Error: File does not exist: $ZIP_FILE"
    exit 1
fi

# Use zip2john to extract the hash
/usr/local/bin/zip2john.pl "$ZIP_FILE"