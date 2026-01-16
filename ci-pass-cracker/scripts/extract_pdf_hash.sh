#!/bin/bash
# Script to extract hash from PDF files
# Usage: ./extract_pdf_hash.sh <pdf_file>

if [ $# -ne 1 ]; then
    echo "Usage: $0 <pdf_file>"
    exit 1
fi

PDF_FILE=$1

if [ ! -f "$PDF_FILE" ]; then
    echo "Error: File does not exist: $PDF_FILE"
    exit 1
fi

# Use pdf2john to extract the hash
/usr/local/bin/pdf2john.pl "$PDF_FILE"