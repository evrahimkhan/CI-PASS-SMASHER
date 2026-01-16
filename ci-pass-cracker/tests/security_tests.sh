#!/bin/bash
set -e

echo "Running security tests..."

# Test policy enforcement
echo "Testing compliance policy..."
if ./scripts/usage_policy_check.sh test_file 2>&1 | grep -q "ERROR"; then
    echo "✓ Policy enforcement works when compliance not acknowledged"
else
    echo "✗ Policy enforcement failed"
    exit 1
fi

# Test with compliance acknowledged
export JTR_COMPLIANCE_ACKNOWLEDGED=true
export JTR_LOGGING_CONSENT=true
if ./scripts/usage_policy_check.sh test_file 2>&1 | grep -q "passed"; then
    echo "✓ Policy check passes when properly configured"
else
    echo "✗ Policy check should pass when properly configured"
    exit 1
fi

echo "All security tests passed!"