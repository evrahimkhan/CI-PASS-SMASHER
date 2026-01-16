#!/bin/bash
set -e

echo "Running unit tests..."

# Test script existence and executability
echo "Testing script permissions..."
test -x ./scripts/detect_and_extract.sh && echo "✓ detect_and_extract.sh is executable"
test -x ./scripts/extract_office_hash.sh && echo "✓ extract_office_hash.sh is executable"
test -x ./scripts/extract_pdf_hash.sh && echo "✓ extract_pdf_hash.sh is executable"
test -x ./scripts/extract_zip_hash.sh && echo "✓ extract_zip_hash.sh is executable"
test -x ./scripts/extract_rar_hash.sh && echo "✓ extract_rar_hash.sh is executable"
test -x ./scripts/send_telegram_notification.sh && echo "✓ send_telegram_notification.sh is executable"
test -x ./scripts/usage_policy_check.sh && echo "✓ usage_policy_check.sh is executable"

# Test basic functionality of detection script
echo "Testing detection script..."
echo "dummy content" > /tmp/test_file.txt
result=$(./scripts/detect_and_extract.sh /tmp/test_file.txt 2>&1 || true)
if [[ "$result" == *"Error"* ]] || [[ "$result" == *"unsupported"* ]]; then
    echo "✓ Detection script correctly rejects unsupported file types"
else
    echo "✗ Detection script should reject unsupported file types"
    exit 1
fi

# Cleanup
rm -f /tmp/test_file.txt

echo "All unit tests passed!"