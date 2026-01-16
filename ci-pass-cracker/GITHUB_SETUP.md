# CI Pass Cracker - GitHub Actions Setup Guide

This guide explains how to properly set up and use the CI Pass Cracker in GitHub Actions.

## Repository Structure

The CI Pass Cracker expects the following repository structure:

```
.
├── ci-pass-cracker/           # Main action directory
│   ├── action.yml            # Action definition
│   ├── docker/
│   │   ├── Dockerfile        # Docker build file
│   │   └── entrypoint.sh     # Entry point script
│   └── ...
├── .github/
│   └── workflows/
│       └── jtr-action.yaml   # GitHub Actions workflow
└── sample-protected-document.md  # Example file to process
```

## Setting Up the Action

### 1. Repository Preparation

1. Clone your repository locally
2. Ensure the `ci-pass-cracker/` directory exists with all necessary files
3. Add password-protected files you want to process to your repository

### 2. GitHub Actions Workflow

Create a workflow file at `.github/workflows/jtr-action.yaml` with the following content:

```yaml
name: John the Ripper Action

on:
  workflow_dispatch:
    inputs:
      file-path:
        description: 'Path to the file to crack (direct path in repo)'
        required: true
        default: 'sample-protected-document.md'
      wordlist-url:
        description: 'URL to download wordlist from (optional)'
        required: false
      custom-rules:
        description: 'Custom John the Ripper rules to apply (optional)'
        required: false
      timeout:
        description: 'Timeout in seconds'
        required: false
        default: '3600'
      telegram-token:
        description: 'Telegram bot token for notifications (optional)'
        required: false
      telegram-chat-id:
        description: 'Telegram chat ID for notifications (optional)'
        required: false

permissions:
  contents: read

jobs:
  crack-password:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Display repository structure
        run: |
          echo "Repository structure:"
          find . -type f -name "*.md" -o -name "*.pdf" -o -name "*.doc*" -o -name "*.zip" -o -name "*.rar" | head -20

      - name: Validate file exists
        run: |
          if [ ! -f "${{ inputs.file-path }}" ]; then
            echo "Error: File does not exist at path ${{ inputs.file-path }}"
            echo "Available files in repository:"
            find . -type f -not -path "./.git/*" | head -20
            exit 1
          fi
          echo "File found: ${{ inputs.file-path }}"
          ls -la "${{ inputs.file-path }}"

      - name: Build and run John the Ripper Docker container directly
        run: |
          # Build the Docker image from the repository
          if [ -f "./ci-pass-cracker/docker/Dockerfile" ]; then
            echo "Building Docker image from ./ci-pass-cracker/docker/Dockerfile"
            docker build -f ./ci-pass-cracker/docker/Dockerfile -t jtr-action .
          else
            echo "ERROR: Dockerfile not found at ./ci-pass-cracker/docker/Dockerfile"
            exit 1
          fi

          # Run the container with the specified file
          echo "Running John the Ripper on file: ${{ inputs.file-path }}"
          docker run --rm -v $(pwd):/workspace -w /workspace jtr-action /app/entrypoint.sh "${{ inputs.file-path }}" "${{ inputs.wordlist-url }}" "${{ inputs.custom-rules }}" "${{ inputs.telegram-token }}" "${{ inputs.telegram-chat-id }}" "${{ inputs.timeout }}"

      - name: Display results
        run: |
          echo "Password cracking attempt completed"
          echo "Check the action logs for results"
          echo "File processed: ${{ inputs.file-path }}"
```

## Troubleshooting Common Issues

### Issue: "Dockerfile not found"
**Solution**: Ensure the Dockerfile exists at `./ci-pass-cracker/docker/Dockerfile` relative to your repository root.

### Issue: "File does not exist"
**Solution**: Verify the file path is correct relative to your repository root and that the file is committed to the repository.

### Issue: Permission Denied
**Solution**: Ensure your GitHub Actions workflow has the necessary permissions to read repository contents.

## Security Considerations

⚠️ **IMPORTANT**: This action is intended for authorized penetration testing and security research only. Always ensure you have explicit permission before attempting to recover passwords from any system or file you do not own.

## Usage Notes

- The action will only process files that are committed to your repository
- Large files may cause timeouts; adjust the timeout parameter as needed
- For security reasons, cracked passwords will only be visible in the action logs
- Telegram notifications require valid bot tokens and chat IDs to be configured as secrets