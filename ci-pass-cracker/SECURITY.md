# Security Policy for John the Ripper GitHub Action

## Supported Versions

The following versions of the John the Ripper GitHub Action are currently being supported with security updates:

| Version | Supported          |
| ------- | ------------------ |
| 1.x     | ✅ Yes             |
| < 1.0   | ❌ No              |

## Reporting a Vulnerability

If you discover a security vulnerability in this GitHub Action, please follow these steps:

1. **Do not open a public issue** - this could expose the vulnerability to others
2. Contact the maintainer directly via email: security@example.com (replace with actual contact)
3. Provide detailed information about the vulnerability:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested remediation (if known)

### Response Timeline
- Acknowledgment of your report: Within 48 hours
- Initial assessment: Within 1 week
- Regular updates: Every 2 weeks until resolution
- Resolution timeline: Depends on severity (critical: 1-2 weeks, high: 1 month)

## Security Best Practices

### For Users
- Only run this action on files you own or have explicit permission to test
- Store sensitive tokens securely using GitHub Secrets
- Limit access to repositories containing password cracking workflows
- Monitor usage of the action to prevent abuse
- Regularly rotate Telegram bot tokens and other credentials

### For Maintainers
- Sanitize all user inputs to prevent injection attacks
- Implement proper error handling to avoid information disclosure
- Regularly update dependencies to patch known vulnerabilities
- Conduct security reviews of code changes
- Follow secure coding practices

## Compliance Guidelines

This action is intended for:
- Educational purposes
- Authorized penetration testing
- Password recovery for owned systems
- Security research with proper authorization

This action must NOT be used for:
- Unauthorized access to systems
- Hacking or cracking attempts without explicit permission
- Violating terms of service of any platform
- Any illegal activities

## Data Handling

- No data is stored permanently by this action
- Files processed are handled only in memory/tmpfs during execution
- No data is transmitted to external services except for Telegram notifications (if configured)
- All temporary files are cleaned up after execution