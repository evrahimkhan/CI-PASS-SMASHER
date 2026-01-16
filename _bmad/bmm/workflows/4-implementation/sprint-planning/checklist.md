# Sprint Status Validation Checklist

## Pre-Execution Checks
- [ ] All epic files are present in the planning artifacts directory
- [ ] Epic files follow the naming convention "epic*.md"
- [ ] Each epic file contains properly formatted user stories
- [ ] Implementation artifacts directory is accessible
- [ ] Previous sprint-status.yaml file is backed up (if exists)

## During Execution Checks
- [ ] All epic files are successfully parsed
- [ ] User stories are correctly extracted from epic files
- [ ] Story IDs are unique across all epics
- [ ] Status values are valid (backlog, in-progress, in-review, done)
- [ ] Priority values are valid (critical, high, medium, low)
- [ ] All required fields are populated for each story

## Post-Execution Validation
- [ ] sprint-status.yaml file is generated successfully
- [ ] Generated YAML file is syntactically correct
- [ ] All statistics are calculated correctly
- [ ] Total story count matches actual number of stories
- [ ] Status distribution is accurate
- [ ] No duplicate story IDs exist
- [ ] All referenced epic IDs exist in the epics section
- [ ] Dates are in valid format (YYYY-MM-DD)

## Quality Assurance
- [ ] All stories have meaningful titles and descriptions
- [ ] Acceptance criteria are clearly defined for each story
- [ ] Estimates seem reasonable for the complexity described
- [ ] Priority assignments are appropriate
- [ ] Assignees are valid team members
- [ ] Blocked stories have appropriate blocker notes
- [ ] Testing and deployment statuses are up-to-date

## Final Verification
- [ ] sprint-status.yaml file is saved in the correct location
- [ ] File has appropriate read/write permissions
- [ ] Status tracking information is current
- [ ] Timeline information is accurate
- [ ] Velocity calculation is based on recent sprints