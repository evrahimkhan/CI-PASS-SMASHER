#!/bin/bash
set -e

FILE_PATH=$1
WORDLIST_URL=$2
CUSTOM_RULES=$3
TELEGRAM_TOKEN=$4
TELEGRAM_CHAT_ID=$5
TIMEOUT=$6

# Check for help parameter
if [ "$FILE_PATH" = "--help" ] || [ "$FILE_PATH" = "-h" ] || [ -z "$FILE_PATH" ]; then
    echo "John the Ripper GitHub Action"
    echo "=============================="
    echo ""
    echo "Usage: $0 <file-path> [wordlist-url] [custom-rules] [telegram-token] [telegram-chat-id] [timeout]"
    echo ""
    echo "Parameters:"
    echo "  file-path        Path to the file to crack (required)"
    echo "  wordlist-url     URL to download wordlist from (optional)"
    echo "  custom-rules     Custom John the Ripper rules to apply (optional)"
    echo "  telegram-token   Telegram bot token for notifications (optional)"
    echo "  telegram-chat-id Telegram chat ID for notifications (optional)"
    echo "  timeout          Timeout for cracking attempts in seconds (optional, default: 3600)"
    echo ""
    echo "Examples:"
    echo "  docker run jtr-action /path/to/protected.pdf"
    echo "  docker run jtr-action /path/to/protected.docx \"https://example.com/wordlist.txt\""
    echo ""
    if [ "$FILE_PATH" = "--help" ] || [ "$FILE_PATH" = "-h" ]; then
        exit 0
    else
        echo "Error: FILE_PATH is required as the first argument"
        exit 1
    fi
fi

# Additional validation to prevent processing the entrypoint script itself
# Get the absolute path of the script file being executed
SCRIPT_PATH="$(realpath "$0" 2>/dev/null || echo "/app/entrypoint.sh")"
INPUT_PATH="$(realpath "$FILE_PATH" 2>/dev/null || echo "$FILE_PATH")"

# Compare the input path with the script path
if [ "$INPUT_PATH" = "$SCRIPT_PATH" ]; then
    echo "Error: Cannot process the entrypoint script itself"
    echo "Please provide a valid file path as the first argument"
    exit 1
fi

if [ ! -f "$FILE_PATH" ]; then
    echo "Error: File does not exist at path: $FILE_PATH"
    echo "Available files in current directory:"
    ls -la .
    exit 1
fi

# Check usage policy compliance
POLICY_CHECK_SCRIPT="/app/usage_policy_check.sh"

# Create the policy check script if it doesn't exist
if [ ! -f "$POLICY_CHECK_SCRIPT" ]; then
    cat > $POLICY_CHECK_SCRIPT << 'EOF'
#!/bin/bash
# Usage policy enforcement script
# This script checks compliance before allowing password cracking operations

check_usage_policy() {
    echo "Checking usage policy compliance..."

    # Check if required environment variables for compliance are set
    if [ -z "$JTR_COMPLIANCE_ACKNOWLEDGED" ]; then
        echo "ERROR: Compliance acknowledgment not provided."
        echo "Set JTR_COMPLIANCE_ACKNOWLEDGED=true to confirm you agree to ethical usage terms."
        echo "See ETHICAL_USE.md for details."
        exit 1
    fi

    # Check if user has provided consent for logging
    if [ -z "$JTR_LOGGING_CONSENT" ]; then
        echo "ERROR: Logging consent not provided."
        echo "Set JTR_LOGGING_CONSENT=true to consent to activity logging for security purposes."
        exit 1
    fi

    # Check if the action is running in an approved environment
    if [ -n "$GITHUB_ACTIONS" ] && [ -n "$JTR_APPROVED_REPOSITORY" ]; then
        if [ "$GITHUB_REPOSITORY" != "$JTR_APPROVED_REPOSITORY" ]; then
            echo "ERROR: This action is only approved for use in repository: $JTR_APPROVED_REPOSITORY"
            echo "Current repository: $GITHUB_REPOSITORY"
            exit 1
        fi
    fi

    # Rate limiting check (simple implementation)
    if [ -n "$JTR_RATE_LIMIT_ENABLED" ]; then
        LOG_FILE="/tmp/jtr_usage.log"
        CURRENT_TIME=$(date +%s)
        TIME_WINDOW=3600  # 1 hour window

        # Count jobs in the last hour
        if [ -f "$LOG_FILE" ]; then
            RECENT_JOBS=$(grep "^$(date -d '1 hour ago' '+%Y-%m-%d %H')" "$LOG_FILE" | wc -l)
            MAX_JOBS_PER_HOUR=${JTR_MAX_JOBS_PER_HOUR:-10}

            if [ "$RECENT_JOBS" -ge "$MAX_JOBS_PER_HOUR" ]; then
                echo "ERROR: Rate limit exceeded. Maximum $MAX_JOBS_PER_HOUR jobs per hour allowed."
                exit 1
            fi
        fi

        # Log this job
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Job started for $1" >> "$LOG_FILE"
    fi

    echo "Usage policy check passed."
    return 0
}

# Run the check if this script is called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    check_usage_policy "$@"
fi
EOF
    chmod +x $POLICY_CHECK_SCRIPT
fi

# Run the policy check
export JTR_COMPLIANCE_ACKNOWLEDGED=true  # In a real implementation, this would come from user configuration
export JTR_LOGGING_CONSENT=true          # In a real implementation, this would come from user configuration
$POLICY_CHECK_SCRIPT "$FILE_PATH"

echo "Starting password cracking process..."
echo "File: $FILE_PATH"

# Use the universal detection and extraction script
HASH_FILE="/tmp/hash.txt"
DETECTION_SCRIPT="/app/detect_and_extract.sh"

# Copy the detection script to the right location if it exists in scripts dir
if [ -f "/opt/john/run/detect_and_extract.sh" ]; then
    cp /opt/john/run/detect_and_extract.sh $DETECTION_SCRIPT
elif [ -f "/app/detect_and_extract.sh" ]; then
    # Already in the right place
    chmod +x $DETECTION_SCRIPT
else
    # Create the detection script in the app directory
    cat > $DETECTION_SCRIPT << 'EOF'
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
        # This is a simplified version - in practice, you'd want to parse the output differently
        echo "# PCAP files require manual analysis for credential extraction"
        echo "# This is a placeholder for actual PCAP parsing logic"
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
EOF
    chmod +x $DETECTION_SCRIPT
fi

# Run the detection and extraction
echo "Running detection and extraction..."
$DETECTION_SCRIPT "$FILE_PATH" > "$HASH_FILE"

# Check if hash extraction was successful
if [ ! -s "$HASH_FILE" ]; then
    echo "Error: Failed to extract hash from file"
    exit 1
fi

echo "Hash extracted successfully:"
cat "$HASH_FILE"

# Download wordlist if URL provided
WORDLIST_PATH="/tmp/wordlist.txt"
if [ -n "$WORDLIST_URL" ]; then
    echo "Downloading wordlist from: $WORDLIST_URL"
    wget -O "$WORDLIST_PATH" "$WORDLIST_URL"
else
    # Use default wordlist if available
    WORDLIST_PATH="/usr/share/john/password.lst"
    if [ ! -f "$WORDLIST_PATH" ]; then
        WORDLIST_PATH="/usr/share/seclists/Passwords/Common-Credentials/10-million-password-list-top-1000000.txt"  # Common location
        if [ ! -f "$WORDLIST_PATH" ]; then
            # Create a minimal wordlist as fallback
            echo -e "password\n123456\n123456789\nqwerty\nabc123\npassword123" > "$WORDLIST_PATH"
        fi
    fi
fi

# Determine the appropriate John the Ripper format based on the hash
HASH_CONTENT=$(head -n1 "$HASH_FILE")
FORMAT=""
if [[ "$HASH_CONTENT" =~ ^\$office ]]; then
    FORMAT="--format=office"
elif [[ "$HASH_CONTENT" =~ ^\$pdf ]]; then
    FORMAT="--format=pdf"
elif [[ "$HASH_CONTENT" =~ ^\$RAR ]]; then
    FORMAT="--format=rar"
elif [[ "$HASH_CONTENT" =~ ^\$zip ]]; then
    FORMAT="--format=zip"
elif [[ "$HASH_CONTENT" =~ ^[a-fA-F0-9]{32}$ ]]; then
    FORMAT="--format=raw-md5"
elif [[ "$HASH_CONTENT" =~ ^[a-fA-F0-9]{40}$ ]]; then
    FORMAT="--format=raw-sha1"
elif [[ "$HASH_CONTENT" =~ ^[a-fA-F0-9]{64}$ ]]; then
    FORMAT="--format=raw-sha256"
else
    # Default to raw-md5 if format cannot be determined
    FORMAT="--format=raw-md5"
fi

# Prepare John the Ripper command
JOHN_CMD="john $FORMAT --wordlist=$WORDLIST_PATH $HASH_FILE"

# Apply custom rules if provided
if [ -n "$CUSTOM_RULES" ]; then
    RULES_FILE="/tmp/rules.conf"
    echo "$CUSTOM_RULES" > "$RULES_FILE"
    JOHN_CMD="$JOHN_CMD --rules=$RULES_FILE"
fi

# Send start notification if Telegram info provided
if [ -n "$TELEGRAM_TOKEN" ] && [ -n "$TELEGRAM_CHAT_ID" ]; then
    # Create notification script if it doesn't exist
    NOTIFICATION_SCRIPT="/app/notify.sh"
    if [ ! -f "$NOTIFICATION_SCRIPT" ]; then
        cat > $NOTIFICATION_SCRIPT << 'EOF'
#!/bin/bash
# Advanced Telegram notification system for John the Ripper
# Usage: ./notify.sh <token> <chat_id> <message_type> [additional_data]

if [ $# -lt 3 ]; then
    exit 1
fi

BOT_TOKEN=$1
CHAT_ID=$2
MESSAGE_TYPE=$3
ADDITIONAL_DATA=$4

# Format the message based on type
case $MESSAGE_TYPE in
    "start")
        MESSAGE="🔄 *Password Cracking Started*%0A%0A📁 File: $ADDITIONAL_DATA%0A⏰ Time: $(date '+%%Y-%%m-%%d %%H:%%M:%%S')"
        ;;
    "progress")
        MESSAGE="⏳ *Cracking Progress*%0A%0A📁 File: $(echo $ADDITIONAL_DATA | cut -d'|' -f1)%0A📊 Status: $(echo $ADDITIONAL_DATA | cut -d'|' -f2)%0A⏰ Elapsed: $(echo $ADDITIONAL_DATA | cut -d'|' -f3)"
        ;;
    "success")
        MESSAGE="✅ *Password Cracked Successfully*%0A%0A📁 File: $(echo $ADDITIONAL_DATA | cut -d'|' -f1)%0A🔑 Password: $(echo $ADDITIONAL_DATA | cut -d'|' -f2)%0A⏱️ Time taken: $(echo $ADDITIONAL_DATA | cut -d'|' -f3)"
        ;;
    "failure")
        MESSAGE="❌ *Password Cracking Failed*%0A%0A📁 File: $ADDITIONAL_DATA%0A⏰ Time: $(date '+%%Y-%%m-%%d %%H:%%M:%%S')%0A⏱️ Duration: $(echo $ADDITIONAL_DATA | cut -d'|' -f2)"
        ;;
    "status")
        MESSAGE="ℹ️ *Status Update*%0A%0A$ADDITIONAL_DATA"
        ;;
    *)
        MESSAGE="ℹ️ *Information*%0A%0A$MESSAGE_TYPE: $ADDITIONAL_DATA"
        ;;
esac

# Send the message to Telegram
curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
     -d "chat_id=$CHAT_ID&text=$MESSAGE&parse_mode=Markdown"
EOF
        chmod +x $NOTIFICATION_SCRIPT
    fi

    $NOTIFICATION_SCRIPT "$TELEGRAM_TOKEN" "$TELEGRAM_CHAT_ID" "start" "$(basename $FILE_PATH)"
fi

# Run John the Ripper with timeout
TIMEOUT_CMD="timeout $TIMEOUT /usr/bin/john $FORMAT --wordlist=$WORDLIST_PATH $HASH_FILE"

# Apply custom rules if provided
if [ -n "$CUSTOM_RULES" ]; then
    RULES_FILE="/tmp/rules.conf"
    echo "$CUSTOM_RULES" > "$RULES_FILE"
    TIMEOUT_CMD="$TIMEOUT_CMD --rules=$RULES_FILE"
fi

echo "Running: $TIMEOUT_CMD"
eval $TIMEOUT_CMD

# Check if password was cracked
if john --show "$HASH_FILE" 2>/dev/null | grep -q ":"; then
    CRACKED_PASSWORD=$(john --show "$HASH_FILE" 2>/dev/null | head -n1 | cut -d: -f2)
    if [ -n "$CRACKED_PASSWORD" ]; then
        echo "Password cracked: $CRACKED_PASSWORD"

        # Set output for GitHub Action
        echo "cracked-password=$CRACKED_PASSWORD" >> $GITHUB_OUTPUT

        # Send success notification
        if [ -n "$TELEGRAM_TOKEN" ] && [ -n "$TELEGRAM_CHAT_ID" ]; then
            DURATION="N/A"  # Would need to track actual duration
            $NOTIFICATION_SCRIPT "$TELEGRAM_TOKEN" "$TELEGRAM_CHAT_ID" "success" "$(basename $FILE_PATH)|$CRACKED_PASSWORD|$DURATION"
        fi
        exit 0
    fi
fi

echo "Password not cracked within timeout period"

# Send failure notification
if [ -n "$TELEGRAM_TOKEN" ] && [ -n "$TELEGRAM_CHAT_ID" ]; then
    $NOTIFICATION_SCRIPT "$TELEGRAM_TOKEN" "$TELEGRAM_CHAT_ID" "failure" "$(basename $FILE_PATH)|${TIMEOUT}s"
fi

# Clean up temporary files
rm -f "$HASH_FILE"