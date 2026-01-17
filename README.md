# CI Pass Cracker - John the Ripper GitHub Action

A GitHub Action for cracking passwords from various file types using John the Ripper with Telegram notifications and a modern UI dashboard.

## Overview

The CI Pass Cracker system provides a comprehensive solution for password recovery automation with proper security, compliance, and monitoring capabilities. It supports multiple file types including Office documents, PDFs, ZIP/RAR archives, and hash files.

### ✅ **Core Features**
- **File Type Support**: Office documents (docx, xlsx, pptx), PDFs, ZIP/RAR archives, hash files
- **John the Ripper**: Version 1.8.0 with all extraction utilities
- **Security Compliance**: Usage policy enforcement and ethical guidelines
- **Monitoring**: Real-time notifications via Telegram
- **Modern UI**: Dashboard for tracking cracking jobs

## Usage

### GitHub Actions Workflow

To use this action in your repository, create a workflow file at `.github/workflows/jtr-crack.yml`:

```yaml
name: John the Ripper Password Cracking

on:
  workflow_dispatch:
    inputs:
      file-path:
        description: 'Path to the file to crack (direct path in repo)'
        required: true
        default: 'protected_document.pdf'
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

      - name: Run John the Ripper Action
        uses: ./ci-pass-cracker  # References the local action
        with:
          file-path: ${{ inputs.file-path }}
          wordlist-url: ${{ inputs.wordlist-url }}
          custom-rules: ${{ inputs.custom-rules }}
          timeout: ${{ inputs.timeout }}
          telegram-token: ${{ inputs.telegram-token }}
          telegram-chat-id: ${{ inputs.telegram-chat-id }}
```

### Action Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `file-path` | Path to the file to crack | Yes | - |
| `wordlist-url` | URL to download wordlist from | No | Internal wordlist |
| `custom-rules` | Custom John the Ripper rules to apply | No | - |
| `telegram-token` | Telegram bot token for notifications | No | - |
| `telegram-chat-id` | Telegram chat ID for notifications | No | - |
| `timeout` | Timeout for cracking attempts in seconds | No | 3600 |

### Action Outputs

| Output | Description |
|--------|-------------|
| `cracked-password` | The cracked password if successful |

## Security and Compliance

This action includes several security and compliance features:

- **Usage Policy Enforcement**: Ensures users acknowledge ethical usage terms
- **Rate Limiting**: Prevents abuse by limiting job frequency
- **Input Validation**: Validates all inputs to prevent injection attacks
- **Secure Credential Handling**: Uses GitHub Secrets for sensitive information

Before using this action, please ensure you have appropriate authorization to perform password recovery on the target files.

## File Type Support

The action supports the following file types:
- Microsoft Office documents: `.doc`, `.docx`, `.xls`, `.xlsx`, `.ppt`, `.pptx`
- PDF files: `.pdf`
- Archive files: `.zip`, `.rar`, `.7z`
- Network capture files: `.pcap`, `.pcapng`
- Hash files: `.txt`, `.hash`, `.sha1`, `.sha256`, `.md5`

## Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md) before submitting a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.