# Contributing to John the Ripper GitHub Action

Thank you for your interest in contributing to the John the Ripper GitHub Action! This document provides guidelines and instructions for contributing to the project.

## Table of Contents
- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Pull Request Process](#pull-request-process)
- [Style Guides](#style-guides)
- [Security Considerations](#security-considerations)

## Code of Conduct

This project and everyone participating in it is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior to the project maintainers.

## How Can I Contribute?

### Reporting Bugs
- Ensure the bug was not already reported by searching on GitHub under [Issues](https://github.com/your-username/jtr-action/issues)
- If you're unable to find an open issue addressing the problem, open a new one
- Follow the provided template and provide as much detail as possible

### Suggesting Enhancements
- Open a new issue with the "enhancement" tag
- Clearly describe the enhancement and its use case
- Explain why this enhancement would be useful to most users

### Pull Requests
- Fork the repository and create your branch from `main`
- If you've added code that should be tested, add tests
- Ensure your code follows the project's style guides
- Update documentation as needed
- Submit your PR with a clear title and description

## Development Setup

### Prerequisites
- Docker
- Node.js (for UI development)
- GitHub CLI (optional but recommended)

### Setting Up the Project
1. Fork the repository on GitHub
2. Clone your fork locally
   ```bash
   git clone https://github.com/YOUR_USERNAME/jtr-action.git
   ```
3. Navigate to the project directory
   ```bash
   cd jtr-action
   ```
4. Build the Docker container for testing
   ```bash
   docker build -t jtr-action ./docker
   ```

### Running Tests
```bash
# Run unit tests
bash tests/unit_tests.sh

# Run security tests
bash tests/security_tests.sh

# Run compliance checks
bash tests/compliance_check.sh
```

## Pull Request Process

1. Ensure your PR addresses an open issue or describes a clear enhancement
2. Update the README.md with details of changes if needed
3. Add tests for new functionality
4. Verify all tests pass before submitting
5. Submit your PR to the `develop` branch (or `main` if no develop branch exists)
6. Wait for review from maintainers
7. Address any feedback from reviewers

## Style Guides

### Git Commit Messages
- Use the present tense ("Add feature" not "Added feature")
- Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit the first line to 72 characters or less
- Reference issues and pull requests liberally after the first line

### Shell Script Style Guide
- Use 4 spaces for indentation (no tabs)
- Use descriptive variable names
- Include comments for complex logic
- Follow the Google Shell Style Guide

### JavaScript Style Guide
- Use 2 spaces for indentation
- Use camelCase for variable and function names
- Use PascalCase for component names
- Follow the Airbnb JavaScript Style Guide

### Documentation Style Guide
- Use Markdown for documentation
- Use consistent heading hierarchy
- Include examples where helpful
- Keep sentences concise and clear

## Security Considerations

When contributing to this project, please pay special attention to:

1. **Never commit credentials or secrets** to the repository
2. Ensure all user inputs are properly sanitized
3. Follow secure coding practices
4. Test for potential security vulnerabilities
5. Update security documentation as needed

If you discover a security vulnerability, please follow the instructions in our [Security Policy](SECURITY.md) rather than filing a public issue.

## Questions?

If you have any questions about contributing, feel free to open an issue with the "question" tag or contact the maintainers directly.

Thank you for contributing to the John the Ripper GitHub Action!