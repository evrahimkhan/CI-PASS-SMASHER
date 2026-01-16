#!/bin/bash
# Advanced Telegram notification system for John the Ripper
# Usage: ./send_telegram_notification.sh <token> <chat_id> <message_type> [additional_data]

if [ $# -lt 3 ]; then
    echo "Usage: $0 <bot_token> <chat_id> <message_type> [additional_data]"
    echo "Message types: start, progress, success, failure, status"
    exit 1
fi

BOT_TOKEN=$1
CHAT_ID=$2
MESSAGE_TYPE=$3
ADDITIONAL_DATA=$4

# Format the message based on type
case $MESSAGE_TYPE in
    "start")
        MESSAGE="🔄 *Password Cracking Started*\n\n📁 File: $ADDITIONAL_DATA\n⏰ Time: $(date '+%Y-%m-%d %H:%M:%S')"
        ;;
    "progress")
        MESSAGE="⏳ *Cracking Progress*\n\n📁 File: $(echo $ADDITIONAL_DATA | cut -d'|' -f1)\n📊 Status: $(echo $ADDITIONAL_DATA | cut -d'|' -f2)\n⏰ Elapsed: $(echo $ADDITIONAL_DATA | cut -d'|' -f3)"
        ;;
    "success")
        MESSAGE="✅ *Password Cracked Successfully*\n\n📁 File: $(echo $ADDITIONAL_DATA | cut -d'|' -f1)\n🔑 Password: $(echo $ADDITIONAL_DATA | cut -d'|' -f2)\n⏱️ Time taken: $(echo $ADDITIONAL_DATA | cut -d'|' -f3)"
        ;;
    "failure")
        MESSAGE="❌ *Password Cracking Failed*\n\n📁 File: $ADDITIONAL_DATA\n⏰ Time: $(date '+%Y-%m-%d %H:%M:%S')\n⏱️ Duration: $(echo $ADDITIONAL_DATA | cut -d'|' -f2)"
        ;;
    "status")
        MESSAGE="ℹ️ *Status Update*\n\n$ADDITIONAL_DATA"
        ;;
    *)
        MESSAGE="ℹ️ *Information*\n\n$MESSAGE_TYPE: $ADDITIONAL_DATA"
        ;;
esac

# Send the message to Telegram
curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
     -d "chat_id=$CHAT_ID&text=$MESSAGE&parse_mode=Markdown"