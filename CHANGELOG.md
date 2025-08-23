# Changelog

All notable changes to RJ BlocX CLI will be documented in this file.

**Created with ❤️ by Rahul Verma**

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2024-01-XX

### 🎉 Major Release - RJ BlocX CLI Launch

**Author: Rahul Verma**

#### ✨ Added
- **RJ BlocX Branding**: Complete rebranding with `rj_blocx` command
- **Interactive Project Creation**: Choose API client, modules, and packages during setup
- **Package Management System**: Add single or multiple packages with smart categorization
- **Dynamic Module Generation**: Create modules with custom screens and configurations
- **Screen Templates**: List, Detail, Form, and Basic screen types with proper BLoC integration
- **Enhanced CLI Experience**: Colored output, progress indicators, and better error handling
- **CamelCase Support**: Automatic conversion between naming conventions
- **Auto-Registration**: Automatic service locator and routing updates
- **Project Documentation**: Auto-generated README with complete project information
- **Code Quality Tools**: Built-in linting rules and analysis options
- **Enhanced Security**: Better secure storage and session management
- **Testing Infrastructure**: Pre-configured testing setup with bloc_test
- **Personal Branding**: Rahul Verma's signature throughout the CLI

#### 🔄 Changed
- **Command Name**: Changed from `blocx` to `rj_blocx` for personal branding
- **Project Structure**: Improved organization with clear separation of concerns
- **Template Quality**: More realistic and production-ready code templates
- **Error Handling**: Comprehensive error handling throughout the application
- **Network Layer**: Enhanced API integration with better error management
- **BLoC Pattern**: Updated to latest BLoC patterns and best practices
- **Author Attribution**: All generated projects include Rahul Verma's signature

#### 🛠️ Improved
- **User Experience**: Interactive prompts with helpful descriptions
- **Documentation**: Comprehensive README and inline code documentation
- **Validation**: Better project name and module name validation
- **Package Suggestions**: Context-aware package recommendations
- **File Organization**: Better file structure and naming conventions
- **Personal Touch**: Added personal branding and author information

#### 🐛 Fixed
- PATH configuration issues on different operating systems
- Flutter project creation edge cases
- Dependency resolution conflicts
- Template generation bugs

### Commands Available
- `rj_blocx create <project_name>` - Interactive project creation
- `rj_blocx add package <n>` - Add single package
- `rj_blocx add packages` - Interactive multiple package selection
- `rj_blocx generate module <n>` - Generate complete module
- `rj_blocx generate screen <n>` - Generate screen with templates
- `rj_blocx generate page <n>` - Alias for screen generation

### Package Categories
- **State Management**: flutter_bloc, provider, riverpod
- **Networking**: dio, http, retrofit
- **Storage**: shared_preferences, hive, sqflite, flutter_secure_storage
- **UI Components**: cached_network_image, lottie, shimmer, flutter_svg
- **Navigation**: go_router, auto_route
- **Forms & Validation**: flutter_form_builder, form_builder_validators
- **Device Features**: image_picker, camera, geolocator, permission_handler
- **Utils**: intl, url_launcher, path_provider, connectivity_plus
- **Development**: flutter_lints, json_annotation, build_runner
- **Testing**: mockito, bloc_test

### Generated Features
- 🔐 **Complete Authentication System** with secure token management
- 🏠 **Beautiful Home Dashboard** with Material Design 3
- 🌐 **Robust Network Layer** with comprehensive error handling
- 💾 **Clean Data Layer** with Repository pattern
- 🎨 **Modern UI Components** with responsive layouts
- 🧪 **Testing Infrastructure** pre-configured
- 📚 **Auto-generated Documentation** with project setup guide

---

## Development Guidelines

### Version Numbering
- **Major (X.0.0)**: Breaking changes, complete rewrites, major architectural changes
- **Minor (X.Y.0)**: New features, new commands, enhanced functionality
- **Patch (X.Y.Z)**: Bug fixes, documentation updates, small improvements

### Commit Convention
- `feat:` New features
- `fix:` Bug fixes
- `docs:` Documentation changes
- `style:` Code style changes
- `refactor:` Code refactoring
- `test:` Test additions or modifications
- `chore:` Build process or auxiliary tool changes

### Release Process
1. Update version in `pubspec.yaml`
2. Update `CHANGELOG.md` with new changes
3. Create git tag with version number
4. Push changes and tag to repository
5. Create GitHub release with changelog notes

---

## About the Author

**Rahul Verma** - Flutter Developer & Tech Enthusiast

RJ BlocX CLI is a personal project created to help Flutter developers build better applications with clean architecture and best practices.

### Connect with Rahul
- 🔗 **GitHub**: [@RahulDev-flutter](https://github.com/RahulDev-flutter)
- 💼 **LinkedIn**: [Rahul Verma](https://linkedin.com/in/rahul-verma-flutter)
- 📧 **Email**: rahul.dev.flutter@gmail.com
- 🌐 **Portfolio**: [rahulverma.dev](https://rahulverma.dev)

---

## Contributing

Please read our [Contributing Guide](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## Support

For support and questions:
- 🐛 **Report Issues**: [GitHub Issues](https://github.com/RahulDev-flutter/blocx_cli/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/RahulDev-flutter/blocx_cli/discussions)
- 📧 **Email**: rahul.dev.flutter@gmail.com

---

**Made with ❤️ by Rahul Verma for the Flutter community** 🚀

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2024-01-XX

### 🎉 Major Release - Complete CLI Overhaul

#### ✨ Added
- **Interactive Project Creation**: Choose API client, modules, and packages during setup
- **Package Management System**: Add single or multiple packages with smart categorization
- **Dynamic Module Generation**: Create modules with custom screens and configurations
- **Screen Templates**: List, Detail, Form, and Basic screen types with proper BLoC integration
- **Enhanced CLI Experience**: Colored output, progress indicators, and better error handling
- **CamelCase Support**: Automatic conversion between naming conventions
- **Auto-Registration**: Automatic service locator and routing updates
- **Project Documentation**: Auto-generated README with complete project information
- **Code Quality Tools**: Built-in linting rules and analysis options
- **Enhanced Security**: Better secure storage and session management
- **Testing Infrastructure**: Pre-configured testing setup with bloc_test

#### 🔄 Changed
- **Project Structure**: Improved organization with clear separation of concerns
- **Template Quality**: More realistic and production-ready code templates
- **Error Handling**: Comprehensive error handling throughout the application
- **Network Layer**: Enhanced API integration with better error management
- **BLoC Pattern**: Updated to latest BLoC patterns and best practices

#### 🛠️ Improved
- **User Experience**: Interactive prompts with helpful descriptions
- **Documentation**: Comprehensive README and inline code documentation
- **Validation**: Better project name and module name validation
- **Package Suggestions**: Context-aware package recommendations
- **File Organization**: Better file structure and naming conventions

#### 🐛 Fixed
- PATH configuration issues on different operating systems
- Flutter project creation edge cases
- Dependency resolution conflicts
- Template generation bugs

### Commands Added
- `blocx create <project_name>` - Interactive project creation
- `blocx add package <name>` - Add single package
- `blocx add packages` - Interactive multiple package selection
- `blocx generate module <name>` - Generate complete module
- `blocx generate screen <name>` - Generate screen with templates
- `blocx generate page <name>` - Alias for screen generation

### Package Categories
- State Management (flutter_bloc, provider, riverpod)
- Networking (dio, http, retrofit)
- Storage (shared_preferences, hive, sqflite, flutter_secure_storage)
- UI Components (cached_network_image, lottie, shimmer, flutter_svg)
- Navigation (go_router, auto_route)
- Forms & Validation (flutter_form_builder, form_builder_validators)
- Device Features (image_picker, camera, geolocator, permission_handler)
- Utils (intl, url_launcher, path_provider, connectivity_plus)
- Development (flutter_lints, json_annotation, build_runner)
- Testing (mockito, bloc_test)

---

## [1.0.0] - 2023-XX-XX

### 🎉 Initial Release

#### ✨ Added
- Basic Flutter project generation with BLoC architecture
- Auth and Home modules with basic functionality
- Core network layer with Dio/HTTP support
- Service locator setup with GetIt
- Basic error handling and utilities
- Simple CLI interface

#### 🏗️ Features
- Clean architecture implementation
- BLoC state management setup
- Secure storage integration
- Basic routing configuration
- Repository pattern implementation

---

## Development Guidelines

### Version Numbering
- **Major (X.0.0)**: Breaking changes, complete rewrites, major architectural changes
- **Minor (X.Y.0)**: New features, new commands, enhanced functionality
- **Patch (X.Y.Z)**: Bug fixes, documentation updates, small improvements

### Commit Convention
- `feat:` New features
- `fix:` Bug fixes
- `docs:` Documentation changes
- `style:` Code style changes
- `refactor:` Code refactoring
- `test:` Test additions or modifications
- `chore:` Build process or auxiliary tool changes

### Release Process
1. Update version in `pubspec.yaml`
2. Update `CHANGELOG.md` with new changes
3. Create git tag with version number
4. Push changes and tag to repository
5. Create GitHub release with changelog notes

---

## Contributing

Please read our [Contributing Guide](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## Support

For support and questions:
- 🐛 **Report Issues**: [GitHub Issues](https://github.com/RahulDev-flutter/blocx_cli/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/RahulDev-flutter/blocx_cli/discussions)
- 📧 **Email**: your.email@example.com