#!/bin/bash

# Sprint Planning Workflow Script - Final Version
# This script implements the sprint-planning workflow by extracting epics and stories
# from epic files and generating/updating the sprint status file

set -e

# Load configuration
CONFIG_FILE="_bmad/bmm/config.yaml"

# Parse YAML configuration (basic parser for simple key-value pairs)
load_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Error: Config file not found at $CONFIG_FILE"
        exit 1
    fi
    
    IMPLEMENTATION_ARTIFACTS=$(grep "implementation_artifacts:" "$CONFIG_FILE" | cut -d '"' -f 2)
    if [ -z "$IMPLEMENTATION_ARTIFACTS" ]; then
        IMPLEMENTATION_ARTIFACTS=$(grep "implementation_artifacts:" "$CONFIG_FILE" | cut -d ':' -f 2 | xargs)
    fi
    
    PLANNING_ARTIFACTS=$(grep "planning_artifacts:" "$CONFIG_FILE" | cut -d '"' -f 2)
    if [ -z "$PLANNING_ARTIFACTS" ]; then
        PLANNING_ARTIFACTS=$(grep "planning_artifacts:" "$CONFIG_FILE" | cut -d ':' -f 2 | xargs)
    fi
    
    PROJECT_NAME=$(grep "project_name:" "$CONFIG_FILE" | cut -d '"' -f 2)
    if [ -z "$PROJECT_NAME" ]; then
        PROJECT_NAME=$(grep "project_name:" "$CONFIG_FILE" | cut -d ':' -f 2 | xargs)
    fi
}

# Function to create a new status file from template with updated values
create_status_file() {
    local output_file="$1"
    local project_name="$2"
    
    # Create the status file from scratch with updated values
    cat > "$output_file" << EOF
# Sprint Status for $project_name

sprint_info:
  name: "$project_name Sprint Status"
  start_date: "$(date +%Y-%m-%d)"
  end_date: ""
  team_members: []
  objectives: []

epics:
EOF

    # Process each epic file
    for epic_file in $(find "$PLANNING_ARTIFACTS" -name "epic*.md" -type f 2>/dev/null || true); do
        echo "Processing epic file: $epic_file"
        
        # Extract epic information
        epic_title=$(head -n 1 "$epic_file" | sed 's/#* *//' | head -c 100)
        if [ -z "$epic_title" ]; then
            epic_title=$(basename "$epic_file" .md)
        fi
        
        epic_id=$(basename "$epic_file" .md | sed 's/[^a-zA-Z0-9]/_/g')
        epic_description=$(sed -n '2,10p' "$epic_file" | head -c 200)
        
        # Append epic to the status file
        cat >> "$output_file" << EOF
  - id: "$epic_id"
    title: "$epic_title"
    description: "$epic_description"
    priority: "medium"
    status: "defined"
    stories: []
    created_date: "$(date +%Y-%m-%d)"
    updated_date: "$(date +%Y-%m-%d)"

EOF
    done
    
    # Add stories section
    echo "stories:" >> "$output_file"
    
    # Process each epic file again to extract stories
    for epic_file in $(find "$PLANNING_ARTIFACTS" -name "epic*.md" -type f 2>/dev/null || true); do
        epic_id=$(basename "$epic_file" .md | sed 's/[^a-zA-Z0-9]/_/g')
        
        # Extract stories from the epic file
        # Look for headings that start with "Story" or list items that look like stories
        while IFS= read -r line; do
            # Check if line looks like a story header (## Story or - Story)
            if [[ $line =~ ^#+[[:space:]]*Story[[:space:]]*[0-9]+ ]] || [[ $line =~ ^-[[:space:]]*Story[[:space:]]*[0-9]+ ]]; then
                story_header=$(echo "$line" | sed 's/^#\{1,3\}[[:space:]]*//' | sed 's/^- *[Ss]tory[[:space:]]*/Story /')
                story_id=$(echo "$story_header" | sed 's/[^a-zA-Z0-9]/_/g' | cut -c1-20)
                
                # Append story to the status file
                cat >> "$output_file" << EOF
  - id: "$story_id"
    epic_id: "$epic_id"
    title: "$story_header"
    description: ""
    acceptance_criteria: []
    priority: "medium"
    status: "backlog"
    assignee: ""
    estimate: 0
    created_date: "$(date +%Y-%m-%d)"
    updated_date: "$(date +%Y-%m-%d)"
    blocked: false
    blocker_notes: ""
    testing_status: "not-started"
    deployment_status: "not-deployed"

EOF
            fi
        done < "$epic_file"
    done
    
    # Count total stories and statuses
    total_stories=$(grep -c "^  - id: " "$output_file" 2>/dev/null || echo 0)
    total_stories=$(echo "$total_stories" | tr -d '\n\r ')
    
    # Count stories by status
    backlog_count=$(grep -c "status: \"backlog\"" "$output_file" 2>/dev/null || echo 0)
    backlog_count=$(echo "$backlog_count" | tr -d '\n\r ')
    in_progress_count=0
    in_review_count=0
    done_count=0
    
    # Calculate completion percentage
    if [ "$total_stories" -gt 0 ]; then
        completion_percentage=$((done_count * 100 / total_stories))
    else
        completion_percentage=0
    fi
    
    # Add remaining sections with calculated values
    cat >> "$output_file" << EOF
status_tracking:
  created_date: "$(date +%Y-%m-%d)"
  last_updated: "$(date +%Y-%m-%d)"
  total_stories: $total_stories
  stories_by_status:
    backlog: $backlog_count
    in-progress: $in_progress_count
    in-review: $in_review_count
    done: $done_count
  stories_by_priority:
    critical: 0
    high: 0
    medium: 0
    low: 0
  completion_percentage: $completion_percentage
  velocity: 0

timeline:
  current_sprint_day: 0
  days_remaining: 0
  major_milestones: []
EOF
}

# Main execution
main() {
    echo "Starting Sprint Planning Workflow..."
    
    # Load configuration
    load_config
    
    # Validate directories exist
    if [ ! -d "$PLANNING_ARTIFACTS" ]; then
        echo "Error: Planning artifacts directory does not exist: $PLANNING_ARTIFACTS"
        exit 1
    fi
    
    if [ ! -d "$IMPLEMENTATION_ARTIFACTS" ]; then
        echo "Creating implementation artifacts directory: $IMPLEMENTATION_ARTIFACTS"
        mkdir -p "$IMPLEMENTATION_ARTIFACTS"
    fi
    
    # Define output file
    STATUS_FILE="$IMPLEMENTATION_ARTIFACTS/sprint-status.yaml"
    
    # Create the status file with extracted epics and stories
    create_status_file "$STATUS_FILE" "$PROJECT_NAME"
    
    echo "Sprint status file generated: $STATUS_FILE"
    echo "Workflow completed successfully!"
}

# Run main function
main "$@"