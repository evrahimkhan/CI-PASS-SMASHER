#!/bin/bash
set -e

echo "Running compliance checks..."

# Check for required documentation
echo "Checking for required documentation..."
test -f SECURITY.md && echo "✓ SECURITY.md exists"
test -f ETHICAL_USE.md && echo "✓ ETHICAL_USE.md exists"

# Check for proper license information
if grep -q "MIT\|Apache\|GPL" README.md; then
    echo "✓ License information found in README"
else
    echo "✗ License information not found in README"
    exit 1
fi

# Check for usage policy in action
if grep -q "usage_policy_check\|compliance" ./docker/entrypoint.sh; then
    echo "✓ Usage policy enforcement found in entrypoint"
else
    echo "✗ Usage policy enforcement not found in entrypoint"
    exit 1
fi

echo "All compliance checks passed!"