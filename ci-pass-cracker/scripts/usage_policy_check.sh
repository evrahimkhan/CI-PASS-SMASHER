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