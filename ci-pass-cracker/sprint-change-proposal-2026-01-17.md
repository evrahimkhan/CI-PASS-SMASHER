# Sprint Change Proposal - John the Ripper GitHub Action Parameter Issue

## Date
2026-01-17

## Issue Description
The John the Ripper GitHub Action is experiencing a parameter handling issue where the container's entrypoint script is attempting to process itself (`/app/entrypoint.sh`) instead of the intended target file. This occurs when the action is run without proper parameters or when the file path parameter is not correctly passed to the container.

## Impact Analysis
- **Functional Impact**: The action fails to process the intended file
- **User Experience**: Users receive confusing error messages
- **Security**: Potential for unintended file processing if not handled properly
- **Reliability**: Action consistently fails when parameters are not properly configured

## Root Cause
The Docker container has an entrypoint defined that expects a file path as an argument. When the action is run without proper parameters, the entrypoint script receives no file path argument and defaults to processing the entrypoint script itself, which is not a valid password-protected file.

## Proposed Solution
1. **Parameter Validation**: Add robust parameter validation to ensure required inputs are provided
2. **Default Behavior**: Modify the entrypoint script to handle missing parameters gracefully
3. **Error Messaging**: Improve error messages to guide users on proper usage
4. **Documentation**: Update documentation with clear usage examples

## Implementation Plan
1. Update the entrypoint.sh script to validate required parameters before proceeding
2. Add a check to ensure the file path parameter is provided and is not empty
3. Add a check to ensure the file path is not pointing to the entrypoint script itself
4. Provide clear error messages when required parameters are missing
5. Update the action.yml to ensure proper parameter passing

## Risk Assessment
- **Low Risk**: Changes are limited to parameter validation and error handling
- **Security Impact**: Minimal - improves security by preventing unintended file processing
- **Compatibility**: Backward compatible with existing workflows when properly configured

## Timeline
- Implementation: 1 day
- Testing: 1 day
- Deployment: 1 day

## Resources Required
- 1 developer for implementation
- Access to testing environment

## Success Criteria
- Action properly validates input parameters
- Action provides clear error messages when parameters are missing
- Action only processes intended files, not internal scripts
- Existing workflows continue to function when properly configured

## Additional Notes
The issue was identified during testing where the command `docker run jtr-action /app/entrypoint.sh /workspace/test_file.txt` was causing the entrypoint script to process itself instead of the intended file. This is because the container's entrypoint is already set to `/app/entrypoint.sh`, so when we specify it again as a command, it creates a parameter confusion.