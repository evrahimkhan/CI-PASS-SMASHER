#!/bin/bash
# Universal file type detection and hash extraction script
# Usage: ./detect_and_extract.sh <file_path>

if [ $# -ne 1 ]; then
    echo "Usage: $0 <file_path>"
    exit 1
fi

FILE_PATH=$1

if [ ! -f "$FILE_PATH" ]; then
    echo "Error: File does not exist: $FILE_PATH"
    exit 1
fi

# Get file extension
FILE_EXT="${FILE_PATH##*.}"
FILE_EXT=${FILE_EXT,,}  # Convert to lowercase

echo "Detecting file type for: $FILE_PATH"
echo "File extension: $FILE_EXT"

case $FILE_EXT in
    doc|docx|xls|xlsx|ppt|pptx)
        echo "Detected Microsoft Office file"
        if command -v office2john.pl &> /dev/null; then
            office2john.pl "$FILE_PATH"
        else
            echo "Error: office2john.pl not found"
            exit 1
        fi
        ;;
    pdf)
        echo "Detected PDF file"
        if command -v pdf2john.pl &> /dev/null; then
            pdf2john.pl "$FILE_PATH"
        else
            echo "Error: pdf2john.pl not found"
            exit 1
        fi
        ;;
    zip)
        echo "Detected ZIP file"
        if command -v zip2john.pl &> /dev/null; then
            zip2john.pl "$FILE_PATH"
        else
            echo "Error: zip2john.pl not found"
            exit 1
        fi
        ;;
    rar)
        echo "Detected RAR file"
        if command -v rar2john &> /dev/null; then
            rar2john "$FILE_PATH"
        else
            echo "Error: rar2john not found"
            exit 1
        fi
        ;;
    pcap|pcapng)
        echo "Detected PCAP file"
        # For PCAP files, we extract potential credentials rather than a single hash
        ./extract_pcap_creds.sh "$FILE_PATH"
        ;;
    txt|hash|sha1|sha256|md5)
        echo "Detected hash file - assuming raw hash format"
        cat "$FILE_PATH"
        ;;
    *)
        echo "Unknown file type: $FILE_EXT"
        echo "Attempting to determine file type with 'file' command..."
        file_result=$(file --mime-type "$FILE_PATH" | awk '{print $2}' | tr -d ';')
        echo "MIME type detected: $file_result"
        
        case $file_result in
            application/msword|application/vnd.openxmlformats-officedocument*)
                echo "Detected Office file by MIME type"
                if command -v office2john.pl &> /dev/null; then
                    office2john.pl "$FILE_PATH"
                else
                    echo "Error: office2john.pl not found"
                    exit 1
                fi
                ;;
            application/pdf)
                echo "Detected PDF by MIME type"
                if command -v pdf2john.pl &> /dev/null; then
                    pdf2john.pl "$FILE_PATH"
                else
                    echo "Error: pdf2john.pl not found"
                    exit 1
                fi
                ;;
            application/zip)
                echo "Detected ZIP by MIME type"
                if command -v zip2john.pl &> /dev/null; then
                    zip2john.pl "$FILE_PATH"
                else
                    echo "Error: zip2john.pl not found"
                    exit 1
                fi
                ;;
            application/x-rar-compressed)
                echo "Detected RAR by MIME type"
                if command -v rar2john &> /dev/null; then
                    rar2john "$FILE_PATH"
                else
                    echo "Error: rar2john not found"
                    exit 1
                fi
                ;;
            *)
                echo "Unsupported file type: $file_result"
                exit 1
                ;;
        esac
        ;;
esac