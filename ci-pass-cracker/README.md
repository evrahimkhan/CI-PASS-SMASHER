# John the Ripper GitHub Action

A GitHub Action for cracking passwords from various file types using John the Ripper with Telegram notifications and a modern UI dashboard.

## Table of Contents
- [Features](#features)
- [Supported File Types](#supported-file-types)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Inputs](#inputs)
- [Outputs](#outputs)
- [Examples](#examples)
- [Security and Compliance](#security-and-compliance)
- [Troubleshooting](#troubleshooting)
- [License](#license)

## Features

- 🔐 Supports multiple file types: Office documents, PDFs, ZIP/RAR archives, and hash files
- 🤖 Automated password cracking using John the Ripper
- 📱 Real-time notifications via Telegram
- 📊 Modern UI dashboard for monitoring jobs
- 🛡️ Built-in security and compliance checks
- 🧪 Comprehensive testing suite

## Supported File Types

- Microsoft Office documents: `.doc`, `.docx`, `.xls`, `.xlsx`, `.ppt`, `.pptx`
- PDF files: `.pdf`
- Archive files: `.zip`, `.rar`
- Network capture files: `.pcap`, `.pcapng`
- Hash files: `.txt`, `.hash`, `.sha1`, `.sha256`, `.md5`

## Prerequisites

- A GitHub repository where you have admin rights
- A Telegram bot token and chat ID for notifications (optional)
- Files to crack must be stored in the repository or accessible via URL

## Usage

To use this action, create a new workflow file in your repository at `.github/workflows/jtr-crack.yml`:

```yaml
name: Password Cracking

on:
  workflow_dispatch:
    inputs:
      file-path:
        description: 'Path to the file to crack'
        required: true
        default: 'protected_document.pdf'
      wordlist-url:
        description: 'URL to download wordlist from (optional)'
        required: false
      timeout:
        description: 'Timeout in seconds'
        required: false
        default: '3600'

jobs:
  crack-password:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout repository
      uses: actions/checkout@v3
    
    - name: Crack password
      uses: your-username/jtr-action@v1
      with:
        file-path: ${{ github.event.inputs.file-path }}
        wordlist-url: ${{ github.event.inputs.wordlist-url }}
        timeout: ${{ github.event.inputs.timeout }}
        telegram-token: ${{ secrets.TELEGRAM_TOKEN }}
        telegram-chat-id: ${{ secrets.TELEGRAM_CHAT_ID }}
```

## Inputs

| Name | Description | Required | Default |
|------|-------------|----------|---------|
| `file-path` | Path to the file to crack | Yes | - |
| `wordlist-url` | URL to download wordlist from | No | Internal wordlist |
| `custom-rules` | Custom John the Ripper rules to apply | No | - |
| `telegram-token` | Telegram bot token for notifications | No | - |
| `telegram-chat-id` | Telegram chat ID for notifications | No | - |
| `timeout` | Timeout for cracking attempts in seconds | No | 3600 |

## Outputs

| Name | Description |
|------|-------------|
| `cracked-password` | The cracked password if successful |

## Examples

### Basic Usage

```yaml
- name: Crack password
  uses: your-username/jtr-action@v1
  with:
    file-path: protected_document.pdf
```

### With Custom Wordlist

```yaml
- name: Crack password with custom wordlist
  uses: your-username/jtr-action@v1
  with:
    file-path: protected_file.xlsx
    wordlist-url: https://example.com/custom-wordlist.txt
```

### With Telegram Notifications

```yaml
- name: Crack password with notifications
  uses: your-username/jtr-action@v1
  with:
    file-path: protected_archive.zip
    telegram-token: ${{ secrets.TELEGRAM_TOKEN }}
    telegram-chat-id: ${{ secrets.TELEGRAM_CHAT_ID }}
```

### With Custom Rules

```yaml
- name: Crack with custom rules
  uses: your-username/jtr-action@v1
  with:
    file-path: protected_doc.pdf
    custom-rules: |
      [List.Rules:Wordlist]
      c
      \$1
      \$2
      ^a
      ^b
```

## Security and Compliance

This action includes several security and compliance features:

- **Usage Policy Enforcement**: Ensures users acknowledge ethical usage terms
- **Rate Limiting**: Prevents abuse by limiting job frequency
- **Input Validation**: Validates all inputs to prevent injection attacks
- **Secure Credential Handling**: Uses GitHub Secrets for sensitive information

Before using this action, please read our [Ethical Usage Policy](ETHICAL_USE.md) and [Security Policy](SECURITY.md).

## Troubleshooting

### Common Issues

1. **File not found**: Ensure the file path is correct and the file exists in the repository
2. **Permission denied**: Check that your repository has the necessary permissions
3. **Timeout exceeded**: Increase the timeout value for complex passwords
4. **Telegram notifications not working**: Verify your bot token and chat ID are correct

### Debugging Tips

- Enable verbose logging by setting `ACTIONS_STEP_DEBUG` to `true` in your repository secrets
- Check the action logs for detailed error messages
- Use small test files to verify functionality before processing larger files

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md) before submitting a pull request.

## Support

For support, please open an issue in the repository or contact the maintainers.