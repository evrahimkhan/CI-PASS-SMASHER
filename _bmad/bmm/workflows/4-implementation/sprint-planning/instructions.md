# Sprint Planning Workflow Instructions

## Purpose
This workflow generates and manages the sprint status tracking file for Phase 4 implementation, extracting all epics and stories from epic files and tracking their status through the development lifecycle.

## Process Flow
1. Scan the planning artifacts directory for all epic files matching the pattern "epic*.md"
2. Extract user stories from each epic file
3. Map stories to their current status in the development lifecycle
4. Generate/update the sprint-status.yaml file with current status
5. Validate the generated status file against the checklist

## Input Requirements
- Epic files must be located in the planning artifacts directory
- Epic files must follow the naming convention "epic*.md"
- Each epic file should contain user stories in the standard format

## Output
- Updates/creates sprint-status.yaml in the implementation artifacts directory
- Tracks status of all stories through the development lifecycle