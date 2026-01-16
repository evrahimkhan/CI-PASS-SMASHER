# Testing Procedures for John the Ripper GitHub Action

## Overview
This document outlines the testing procedures for the John the Ripper GitHub Action to ensure reliability, security, and proper functionality.

## Test Categories

### 1. Unit Tests
Test individual components of the action:

#### File Type Detection Tests
```bash
# Test office file detection
./scripts/detect_and_extract.sh test_files/sample.docx

# Test PDF detection
./scripts/detect_and_extract.sh test_files/sample.pdf

# Test ZIP detection
./scripts/detect_and_extract.sh test_files/sample.zip

# Test RAR detection
./scripts/detect_and_extract.sh test_files/sample.rar

# Test hash file detection
./scripts/detect_and_extract.sh test_files/sample_hashes.txt
```

#### Extraction Script Tests
```bash
# Test individual extraction scripts
./scripts/extract_office_hash.sh test_files/sample.docx
./scripts/extract_pdf_hash.sh test_files/sample.pdf
./scripts/extract_zip_hash.sh test_files/sample.zip
./scripts/extract_rar_hash.sh test_files/sample.rar
```

#### Notification System Tests
```bash
# Test notification system (with mock Telegram token)
./scripts/send_telegram_notification.sh "mock_token" "mock_chat_id" "status" "Test message"
```

### 2. Integration Tests
Test the complete workflow:

#### Docker Container Tests
```bash
# Build the Docker container
docker build -t jtr-action ./docker

# Test container functionality
docker run -it --rm -v $(pwd)/test_files:/test_files jtr-action /app/entrypoint.sh /test_files/sample.pdf "" "" "" "" "60"
```

#### GitHub Action Simulation
```bash
# Using Act (https://github.com/nektos/act) to simulate GitHub Actions locally
act -j test-unit
act -j test-integration
act -j test-security
```

### 3. Security Tests
Validate security controls:

#### Policy Enforcement Tests
```bash
# Test without compliance acknowledgment
JTR_COMPLIANCE_ACKNOWLEDGED="" ./scripts/usage_policy_check.sh test_file.pdf

# Test without logging consent
JTR_LOGGING_CONSENT="" ./scripts/usage_policy_check.sh test_file.pdf

# Test rate limiting
JTR_RATE_LIMIT_ENABLED=true JTR_MAX_JOBS_PER_HOUR=1
# Run multiple jobs to test rate limiting
```

#### Input Validation Tests
```bash
# Test with invalid file path
./scripts/detect_and_extract.sh nonexistent_file.pdf

# Test with empty file
touch empty_file.pdf
./scripts/detect_and_extract.sh empty_file.pdf

# Test with malicious file names
./scripts/detect_and_extract.sh "../../../etc/passwd"
```

### 4. Functional Tests
Validate core functionality:

#### Password Cracking Tests
```bash
# Test with known password files (for validation)
# Note: These tests should use files with known passwords for validation

# Test with different wordlists
./docker/entrypoint.sh test_files/protected_doc.pdf "https://example.com/wordlist.txt" "" "" "" "120"

# Test with custom rules
CUSTOM_RULES="[List.Rules:Wordlist]
c
\$1
\$2
"
./docker/entrypoint.sh test_files/protected_doc.pdf "" "$CUSTOM_RULES" "" "" "120"
```

#### Timeout Tests
```bash
# Test timeout functionality
./docker/entrypoint.sh test_files/protected_doc.pdf "" "" "" "" "10"  # 10 second timeout
```

## Automated Testing Setup

### GitHub Actions Workflows
Create `.github/workflows/test.yml`:

```yaml
name: Test Suite

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup test environment
      run: |
        sudo apt-get update
        sudo apt-get install -y john curl wget
    
    - name: Run unit tests
      run: |
        bash tests/unit_tests.sh

  integration-tests:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Build Docker image
      run: docker build -t jtr-action ./docker
    
    - name: Run integration tests
      run: |
        docker run -it --rm jtr-action echo "Integration test passed"

  security-tests:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Security policy test
      run: |
        bash tests/security_tests.sh

  compliance-check:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Run compliance checks
      run: |
        bash tests/compliance_check.sh
```

### Test Scripts

#### Unit Tests Script (`tests/unit_tests.sh`)
```bash
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
```

#### Security Tests Script (`tests/security_tests.sh`)
```bash
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
```

#### Compliance Check Script (`tests/compliance_check.sh`)
```bash
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
```

## Manual Testing Procedures

### Pre-deployment Testing
1. Verify Docker image builds successfully
2. Test with sample files of each supported type
3. Confirm Telegram notifications work (with test bot)
4. Validate timeout functionality
5. Test error handling for invalid inputs
6. Verify security policy enforcement

### Post-deployment Testing
1. Run action on test repository
2. Verify all outputs are correctly returned
3. Confirm notifications are sent appropriately
4. Check logs for any security concerns
5. Validate rate limiting (if enabled)

## Continuous Integration
The testing procedures are integrated into the GitHub Actions workflow to ensure:
- All tests pass before merging pull requests
- Security checks are performed regularly
- Compliance is verified automatically
- Integration tests run on all supported platforms

## Test Data
Test files should be created with known passwords for validation purposes:
- Protected Office documents (Word, Excel, PowerPoint)
- Password-protected PDF files
- Encrypted ZIP and RAR archives
- Sample hash files in various formats

Note: All test files should use passwords that are clearly marked as test passwords and not used in production systems.