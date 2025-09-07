# Contributing to RJ BlocX CLI

Thank you for your interest in contributing to RJ BlocX CLI! 🎉 This document provides guidelines and information for contributors.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [How to Contribute](#how-to-contribute)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Submitting Changes](#submitting-changes)
- [Release Process](#release-process)

## 📜 Code of Conduct

By participating in this project, you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md). Please read it before contributing.

## 🚀 Getting Started

### Prerequisites

- **Dart SDK**: Version 3.0.0 or higher
- **Flutter**: Latest stable version (for testing generated projects)
- **Git**: For version control
- **IDE**: VS Code, IntelliJ, or your preferred Dart/Flutter IDE

### Quick Setup

1. **Fork the repository**
   ```bash
   # Fork on GitHub, then clone your fork
   git clone https://github.com/YOUR_USERNAME/blocx_cli.git
   cd blocx_cli
   ```

2. **Install dependencies**
   ```bash
   dart pub get
   ```

3. **Verify setup**
   ```bash
   dart analyze
   dart test
   ```

## 🛠️ Development Setup

### Local Development

1. **Activate local version**
   ```bash
   dart pub global activate --source path .
   ```

2. **Test CLI commands**
   ```bash
   rj_blocx --help
   rj_blocx --version
   ```

3. **Create test projects**
   ```bash
   mkdir -p ~/test_projects
   cd ~/test_projects
   rj_blocx create test_app
   ```

### Development Workflow

1. Create a feature branch: `git checkout -b feature/your-feature-name`
2. Make your changes
3. Run tests: `dart test`
4. Run analysis: `dart analyze`
5. Format code: `dart format .`
6. Commit changes with descriptive messages
7. Push to your fork and create a pull request

## 🤝 How to Contribute

### 🐛 Reporting Bugs

1. **Check existing issues** first to avoid duplicates
2. **Use the bug report template** when creating issues
3. **Include detailed information**:
   - Operating system and version
   - Dart/Flutter versions
   - RJ BlocX CLI version
   - Steps to reproduce
   - Expected vs actual behavior
   - Error messages and stack traces

### ✨ Suggesting Features

1. **Check existing feature requests** first
2. **Use the feature request template**
3. **Provide detailed description**:
   - Problem the feature solves
   - Proposed solution
   - Alternative solutions considered
   - Examples and use cases

### 💻 Code Contributions

We welcome contributions in these areas:

- **Bug fixes**
- **New features**
- **Performance improvements**
- **Documentation updates**
- **Test coverage improvements**
- **Code quality enhancements**

## 📝 Coding Standards

### Dart Style Guide

Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style):

- Use `dart format .` to format code
- Follow naming conventions (camelCase, PascalCase, etc.)
- Keep functions and classes focused and small
- Use meaningful variable and function names
- Add documentation comments for public APIs

### Code Structure

```
lib/
├── src/
│   ├── commands/          # CLI command implementations
│   ├── generators/        # Code generation logic
│   ├── templates/         # Template files and strings
│   └── utils/            # Utility functions and helpers
├── rj_blocx.dart         # Main library export
test/
├── src/                  # Test files mirroring lib structure
└── utils/                # Test utilities and helpers
```

### Best Practices

1. **Error Handling**
   - Use proper exception handling
   - Provide meaningful error messages
   - Handle edge cases gracefully

2. **Code Organization**
   - Keep related functionality together
   - Use clear file and folder structure
   - Separate concerns appropriately

3. **Documentation**
   - Document public APIs
   - Add inline comments for complex logic
   - Update README for new features

## 🧪 Testing Guidelines

### Running Tests

```bash
# Run all tests
dart test

# Run with coverage
dart test --coverage
```

### Test Structure

- **Unit Tests**: Test individual functions and classes
- **Integration Tests**: Test CLI commands and workflows
- **Template Tests**: Validate generated code structure

### Writing Tests

1. Use descriptive test names
2. Follow AAA pattern (Arrange, Act, Assert)
3. Test both happy path and edge cases
4. Mock external dependencies
5. Ensure tests are independent and can run in any order

Example:
```dart
group('ProjectValidator', () {
  test('should validate valid project names', () {
    // Arrange
    const validName = 'my_awesome_app';
    
    // Act
    final result = ProjectValidator.isValidProjectName(validName);
    
    // Assert
    expect(result, isTrue);
  });
});
```

## 📤 Submitting Changes

### Pull Request Guidelines

1. **Create focused PRs** - One feature/fix per PR
2. **Write clear titles** and descriptions
3. **Reference issues** using keywords (Fixes #123)
4. **Include tests** for new functionality
5. **Update documentation** as needed
6. **Ensure CI passes** before requesting review

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Tests pass locally
- [ ] Documentation updated
```

### Review Process

1. **Automated checks** must pass (CI/CD pipeline)
2. **Code review** by maintainers
3. **Testing** of new features
4. **Documentation review** if applicable
5. **Approval** and merge by maintainers

## 🚀 Release Process

Releases follow [Semantic Versioning](https://semver.org/):

- **MAJOR**: Breaking changes
- **MINOR**: New features, backwards compatible
- **PATCH**: Bug fixes, backwards compatible

### Release Steps

1. Update version in `pubspec.yaml`
2. Update `CHANGELOG.md`
3. Create release PR
4. Tag release after merge
5. Publish to pub.dev (maintainers only)

## 💡 Development Tips

### Useful Commands

```bash
# Format all code
dart format .

# Analyze code quality
dart analyze --fatal-warnings

# Run tests with verbose output
dart test --reporter=verbose

# Build executable
dart compile exe bin/rj_blocx.dart -o build/rj_blocx

# Test executable
./build/rj_blocx --help
```

### Debugging

1. Use `print()` statements for quick debugging
2. Use the Dart debugger in your IDE
3. Test with real Flutter projects
4. Check generated code manually

### Performance

- Profile code generation for large projects
- Optimize file I/O operations
- Cache expensive computations
- Use efficient data structures

## 📞 Getting Help

- **Questions**: Create a [GitHub Discussion](https://github.com/RahulDev-flutter/blocx_cli/discussions)
- **Issues**: Report bugs via [GitHub Issues](https://github.com/RahulDev-flutter/blocx_cli/issues)
- **Email**: rahulverma0549@gmail.com
- **Response Time**: Usually within 48 hours

## 🙏 Recognition

Contributors are recognized in:

- `CONTRIBUTORS.md` file
- Release notes
- GitHub contributors section
- Special thanks in README

## 📄 License

By contributing to RJ BlocX CLI, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for contributing to RJ BlocX CLI! Together, we're making Flutter development more efficient and enjoyable.** 🎉

**Created with ❤️ by Rahul Verma and the community**