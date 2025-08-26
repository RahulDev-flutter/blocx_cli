# 🚀 RJ BlocX CLI - Enhanced Flutter Project Generator

**Created with ❤️ by Rahul Verma**

A powerful command-line tool for creating Flutter applications with **BLoC architecture**, **clean
code structure**, and **industry best practices**. Generate production-ready Flutter projects in
seconds!

[![Pub Version](https://img.shields.io/badge/pub-v2.0.0-blue)](https://github.com/RahulDev-flutter/blocx_cli)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev/)
[![Author](https://img.shields.io/badge/Author-Rahul%20Verma-brightgreen)](https://github.com/RahulDev-flutter)

## ✨ Features

### 🏗️ **Project Generation**

- 🎯 **Interactive Setup** - Choose API client, modules, and packages
- 🏛️ **Clean Architecture** - Proper separation of concerns
- 🔄 **BLoC State Management** - Complete BLoC pattern implementation
- 🔐 **Secure Storage** - Encrypted token storage with session management
- 🌐 **Network Layer** - Dio/HTTP with comprehensive error handling
- 🧪 **Testing Ready** - Pre-configured testing infrastructure

### 📦 **Package Management**

- ➕ **Smart Package Addition** - Interactive package selection with descriptions
- 🏷️ **Categorized Packages** - Organized by functionality (State Management, UI, etc.)
- 💡 **Usage Hints** - Helpful import statements and usage tips
- 🔍 **Popular Packages** - Curated list of most-used Flutter packages

### 🎨 **Dynamic Generation**

- 🏗️ **Module Generation** - Complete modules with BLoC, Repository, and Models
- 📱 **Screen Templates** - List, Detail, Form, and Basic screen types
- 🔄 **Auto-Registration** - Automatic service locator and routing updates
- 📝 **CamelCase Support** - Proper naming conventions throughout

## 🚀 Quick Start

### Installation

**Global Installation (Recommended):**

```bash
dart pub global activate --source git https://github.com/RahulDev-flutter/blocx_cli.git
```

**Add to PATH:** (if not already added)

```bash
# For macOS/Linux (Zsh)
echo 'export PATH="$PATH":"$HOME/.pub-cache/bin"' >> ~/.zshrc
source ~/.zshrc

# For macOS/Linux (Bash)
echo 'export PATH="$PATH":"$HOME/.pub-cache/bin"' >> ~/.bashrc
source ~/.bashrc
```

**Verify Installation:**

```bash
rj_blocx --version
# Should output: RJ BlocX CLI version 1.0.0 - Created by Rahul Verma
```

### Create Your First Project

```bash
# Create a new Flutter project
rj_blocx create my_awesome_app

# Follow the interactive prompts:
# 🌐 API Client: Dio (recommended) or HTTP
# 📦 Additional Modules: Profile, Settings
# 🔧 Extra Packages: Hive, ImagePicker, Permissions
```

**What gets generated:**

```
my_awesome_app/
├── lib/
│   ├── app/                 # App configuration
│   │   ├── app_router.dart         # Navigation routing  
│   │   ├── service_locator.dart    # Dependency injection
│   │   └── bloc_observer.dart      # BLoC debugging
│   ├── core/                # Core functionality
│   │   ├── network/               # API client & services
│   │   ├── constants/             # App & API constants
│   │   ├── utils/                 # Utilities & helpers
│   │   └── errors/                # Error handling
│   ├── modules/             # Feature modules
│   │   ├── auth/                  # Authentication
│   │   │   ├── bloc/             # State management
│   │   │   ├── screens/          # Login/Register screens
│   │   │   ├── models/           # User models
│   │   │   └── repository/       # Auth repository
│   │   └── home/                  # Home dashboard
│   │       ├── bloc/             # Home state management
│   │       ├── screens/          # Home/Profile screens
│   │       └── repository/       # Home repository
│   └── main.dart           # App entry point
├── analysis_options.yaml   # Linting rules
└── README.md              # Project documentation
```

## 📚 Commands

### 🆕 Create Project

```bash
rj_blocx create <project_name>
```

**Example:**

```bash
rj_blocx create my_shopping_app
```

**Interactive Features:**

- 🌐 **API Client Selection**: Choose between Dio (advanced) or HTTP (simple)
- 📦 **Module Selection**: Add Profile, Settings, or other modules
- 🔧 **Package Selection**: Add commonly used packages like Hive, ImagePicker
- 📋 **Configuration Summary**: Review your choices before generation

### 📦 Add Packages

**Single Package:**

```bash
rj_blocx add package <package_name>
```

**Examples:**

```bash
rj_blocx add package shared_preferences
rj_blocx add package cached_network_image
rj_blocx add package image_picker
```

**Multiple Packages (Interactive):**

```bash
rj_blocx add packages
```

**Package Categories:**

- 🔄 **State Management**: flutter_bloc, provider, riverpod
- 🌐 **Networking**: dio, http, retrofit
- 💾 **Storage**: shared_preferences, hive, sqflite
- 🎨 **UI Components**: cached_network_image, lottie, shimmer
- 🧭 **Navigation**: go_router, auto_route
- 📝 **Forms**: flutter_form_builder, form_builder_validators
- 📱 **Device**: image_picker, camera, geolocator, permission_handler
- 🛠️ **Utils**: intl, url_launcher, path_provider

### 🎨 Generate Components

**Generate Module:**

```bash
rj_blocx generate module <module_name>
```

**Example:**

```bash
rj_blocx generate module user_profile
```

**Generates:**

- 📁 Complete module structure
- 🔄 BLoC files (bloc, event, state)
- 📱 Customizable screens
- 💾 Repository with API integration
- 📊 Data models
- 🔧 Auto-registration in service locator

**Generate Screen:**

```bash
rj_blocx generate screen <screen_name>
rj_blocx generate page <page_name>    # Alias for screen
```

**Examples:**

```bash
rj_blocx generate screen product_details
rj_blocx generate page checkout_form
```

**Screen Types:**

- 📋 **List Screen**: Displays items with search, filter, and CRUD operations
- 📄 **Detail Screen**: Shows detailed item information with edit/delete options
- 📝 **Form Screen**: Input forms with validation and submission
- 📱 **Basic Screen**: Simple content screen with customizable layout

## 🎯 Generated Features

### 🔐 Authentication System

- ✅ **Secure Login/Register** with input validation
- ✅ **Token Management** with automatic refresh
- ✅ **Session Persistence** with encrypted storage
- ✅ **Biometric Authentication** support (optional)
- ✅ **Password Reset** flow
- ✅ **Logout** with complete cleanup

### 🏠 Home Dashboard

- ✅ **Welcome Screen** with user information
- ✅ **Quick Actions** grid layout
- ✅ **Navigation** to other modules
- ✅ **Profile Management** integration
- ✅ **Settings** access

### 🌐 Network Layer

- ✅ **HTTP/Dio Client** with interceptors
- ✅ **Error Handling** with user-friendly messages
- ✅ **Request/Response Logging** for debugging
- ✅ **Token Injection** for authenticated requests
- ✅ **Retry Logic** for failed requests
- ✅ **Timeout Configuration** with fallbacks

### 💾 Data Layer

- ✅ **Repository Pattern** for data abstraction
- ✅ **Either Pattern** for error handling
- ✅ **Model Classes** with JSON serialization
- ✅ **Caching Strategy** (if Hive selected)
- ✅ **Local Storage** with flutter_secure_storage

### 🎨 UI Components

- ✅ **Material Design 3** components
- ✅ **Responsive Layouts** for different screen sizes
- ✅ **Loading States** with shimmer effects
- ✅ **Error States** with retry options
- ✅ **Empty States** with helpful messages
- ✅ **Form Validation** with real-time feedback

## 🛠️ Development Workflow

### Initial Setup

```bash
# 1. Create project
rj_blocx create my_app

# 2. Navigate to project
cd my_app

# 3. Install dependencies
flutter pub get

# 4. Run the app
flutter run
```

### Adding New Features

```bash
# 1. Generate new module
rj_blocx generate module products

# 2. Add required packages
rj_blocx add package sqflite
rj_blocx add packages  # Interactive selection

# 3. Generate specific screens
rj_blocx generate screen product_list
rj_blocx generate screen product_detail

# 4. Update API constants and routing
# (Follow the generated comments in code)
```

### Code Quality

```bash
# Analyze code
flutter analyze

# Run tests
flutter test

# Format code
dart format .

# Generate coverage
flutter test --coverage
```

## 🏗️ Architecture Overview

RJ BlocX CLI follows **Clean Architecture** principles:

### 📱 Presentation Layer

- **Screens**: UI components and user interactions
- **BLoC**: State management and business logic
- **Widgets**: Reusable UI components

### 💼 Domain Layer

- **Models**: Data entities and business objects
- **Repositories**: Abstract data contracts
- **Use Cases**: Business logic operations

### 💾 Data Layer

- **Repositories**: Concrete data implementations
- **Data Sources**: API clients and local storage
- **Models**: Data transfer objects

### 🔧 Core Layer

- **Network**: HTTP clients and API services
- **Utils**: Helper functions and utilities
- **Constants**: App-wide constants and configuration
- **Errors**: Error handling and exceptions

## 🎨 Customization

### 🎯 API Configuration

Update `lib/core/constants/api_constants.dart`:

```dart
class ApiConstants {
  static const String baseUrl = 'https://your-api.com';
  static const String apiVersion = '/v1';

  // Add your endpoints
  static const String products = '/products';
  static const String orders = '/orders';
}
```

### 🎨 Theme Configuration

Modify `lib/core/theme/app_theme.dart`:

```dart

static ThemeData lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue, // Your brand color
  ),
  // Customize other theme properties
);
```

### 🧭 Navigation

Add routes in `lib/app/app_router.dart`:

```dart
case AppConstants.productListRoute:
return MaterialPageRoute(builder: (_)
=>
const
ProductListScreen
(
)
);
```

## 🔍 Troubleshooting

### Common Issues

**Command not found:**

```bash
# Ensure PATH is set correctly
echo $PATH | grep pub-cache

# If not found, add to your shell config
echo 'export PATH="$PATH":"$HOME/.pub-cache/bin"' >> ~/.zshrc
source ~/.zshrc
```

**Flutter not found:**

```bash
# Verify Flutter installation
flutter doctor

# Install if needed: https://flutter.dev/docs/get-started/install
```

**Permission denied:**

```bash
# Fix executable permissions
chmod +x ~/.pub-cache/bin/rj_blocx
```

**Project creation fails:**

```bash
# Ensure you have write permissions
# Run in a directory you own
cd ~/Projects
rj_blocx create my_app
```

## 🤝 Contributing

We welcome contributions! Here's how to help:

1. **🍴 Fork** the repository
2. **🌿 Create** your feature branch (`git checkout -b feature/amazing-feature`)
3. **✅ Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **📤 Push** to the branch (`git push origin feature/amazing-feature`)
5. **🔀 Open** a Pull Request

### Development Setup

```bash
# Clone the repository
git clone https://github.com/RahulDev-flutter/blocx_cli.git
cd blocx_cli

# Install dependencies
dart pub get

# Run tests
dart test

# Test locally
dart pub global activate --source path .
```

## 👨‍💻 About the Author

**Rahul Verma** - Flutter Developer & Tech Enthusiast

- 🔗 **GitHub**: [@RahulDev-flutter](https://github.com/RahulDev-flutter)
- 💼 **LinkedIn**: [Rahul Verma](https://linkedin.com/in/rahul-verma-flutter)
- 📧 **Email**: rahul.dev.flutter@gmail.com
- 🌐 **Portfolio**: [rahulverma.dev](https://rahulverma.dev)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Flutter Team** for the amazing framework
- **BLoC Library** for excellent state management
- **Community** for feedback and contributions

## 📞 Support

- 🐛 **Issues**: [GitHub Issues](https://github.com/RahulDev-flutter/blocx_cli/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/RahulDev-flutter/blocx_cli/discussions)
- 📧 **Email**: rahul.dev.flutter@gmail.com

---

**Made with ❤️ by Rahul Verma for the Flutter community**

Transform your Flutter development workflow with RJ BlocX CLI!
🚀shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev/)

## ✨ Features

### 🏗️ **Project Generation**

- 🎯 **Interactive Setup** - Choose API client, modules, and packages
- 🏛️ **Clean Architecture** - Proper separation of concerns
- 🔄 **BLoC State Management** - Complete BLoC pattern implementation
- 🔐 **Secure Storage** - Encrypted token storage with session management
- 🌐 **Network Layer** - Dio/HTTP with comprehensive error handling
- 🧪 **Testing Ready** - Pre-configured testing infrastructure

### 📦 **Package Management**

- ➕ **Smart Package Addition** - Interactive package selection with descriptions
- 🏷️ **Categorized Packages** - Organized by functionality (State Management, UI, etc.)
- 💡 **Usage Hints** - Helpful import statements and usage tips
- 🔍 **Popular Packages** - Curated list of most-used Flutter packages

### 🎨 **Dynamic Generation**

- 🏗️ **Module Generation** - Complete modules with BLoC, Repository, and Models
- 📱 **Screen Templates** - List, Detail, Form, and Basic screen types
- 🔄 **Auto-Registration** - Automatic service locator and routing updates
- 📝 **CamelCase Support** - Proper naming conventions throughout

## 🚀 Quick Start

### Installation

**Global Installation (Recommended):**

```bash
dart pub global activate --source git https://github.com/RahulDev-flutter/blocx_cli.git
```

**Add to PATH:** (if not already added)

```bash
# For macOS/Linux (Zsh)
echo 'export PATH="$PATH":"$HOME/.pub-cache/bin"' >> ~/.zshrc
source ~/.zshrc

# For macOS/Linux (Bash)
echo 'export PATH="$PATH":"$HOME/.pub-cache/bin"' >> ~/.bashrc
source ~/.bashrc
```

**Verify Installation:**

```bash
blocx --version
# Should output: BlocX CLI version 1.0.0
```

### Create Your First Project

```bash
# Create a new Flutter project
blocx create my_awesome_app

# Follow the interactive prompts:
# 🌐 API Client: Dio (recommended) or HTTP
# 📦 Additional Modules: Profile, Settings
# 🔧 Extra Packages: Hive, ImagePicker, Permissions
```

**What gets generated:**

```
my_awesome_app/
├── lib/
│   ├── app/                 # App configuration
│   │   ├── app_router.dart         # Navigation routing  
│   │   ├── service_locator.dart    # Dependency injection
│   │   └── bloc_observer.dart      # BLoC debugging
│   ├── core/                # Core functionality
│   │   ├── network/               # API client & services
│   │   ├── constants/             # App & API constants
│   │   ├── utils/                 # Utilities & helpers
│   │   └── errors/                # Error handling
│   ├── modules/             # Feature modules
│   │   ├── auth/                  # Authentication
│   │   │   ├── bloc/             # State management
│   │   │   ├── screens/          # Login/Register screens
│   │   │   ├── models/           # User models
│   │   │   └── repository/       # Auth repository
│   │   └── home/                  # Home dashboard
│   │       ├── bloc/             # Home state management
│   │       ├── screens/          # Home/Profile screens
│   │       └── repository/       # Home repository
│   └── main.dart           # App entry point
├── analysis_options.yaml   # Linting rules
└── README.md              # Project documentation
```

## 📚 Commands

### 🆕 Create Project

```bash
blocx create <project_name>
```

**Example:**

```bash
blocx create my_shopping_app
```

**Interactive Features:**

- 🌐 **API Client Selection**: Choose between Dio (advanced) or HTTP (simple)
- 📦 **Module Selection**: Add Profile, Settings, or other modules
- 🔧 **Package Selection**: Add commonly used packages like Hive, ImagePicker
- 📋 **Configuration Summary**: Review your choices before generation

### 📦 Add Packages

**Single Package:**

```bash
blocx add package <package_name>
```

**Examples:**

```bash
blocx add package shared_preferences
blocx add package cached_network_image
blocx add package image_picker
```

**Multiple Packages (Interactive):**

```bash
blocx add packages
```

**Package Categories:**

- 🔄 **State Management**: flutter_bloc, provider, riverpod
- 🌐 **Networking**: dio, http, retrofit
- 💾 **Storage**: shared_preferences, hive, sqflite
- 🎨 **UI Components**: cached_network_image, lottie, shimmer
- 🧭 **Navigation**: go_router, auto_route
- 📝 **Forms**: flutter_form_builder, form_builder_validators
- 📱 **Device**: image_picker, camera, geolocator, permission_handler
- 🛠️ **Utils**: intl, url_launcher, path_provider

### 🎨 Generate Components

**Generate Module:**

```bash
blocx generate module <module_name>
```

**Example:**

```bash
blocx generate module user_profile
```

**Generates:**

- 📁 Complete module structure
- 🔄 BLoC files (bloc, event, state)
- 📱 Customizable screens
- 💾 Repository with API integration
- 📊 Data models
- 🔧 Auto-registration in service locator

**Generate Screen:**

```bash
blocx generate screen <screen_name>
blocx generate page <page_name>    # Alias for screen
```

**Examples:**

```bash
blocx generate screen product_details
blocx generate page checkout_form
```

**Screen Types:**

- 📋 **List Screen**: Displays items with search, filter, and CRUD operations
- 📄 **Detail Screen**: Shows detailed item information with edit/delete options
- 📝 **Form Screen**: Input forms with validation and submission
- 📱 **Basic Screen**: Simple content screen with customizable layout

## 🎯 Generated Features

### 🔐 Authentication System

- ✅ **Secure Login/Register** with input validation
- ✅ **Token Management** with automatic refresh
- ✅ **Session Persistence** with encrypted storage
- ✅ **Biometric Authentication** support (optional)
- ✅ **Password Reset** flow
- ✅ **Logout** with complete cleanup

### 🏠 Home Dashboard

- ✅ **Welcome Screen** with user information
- ✅ **Quick Actions** grid layout
- ✅ **Navigation** to other modules
- ✅ **Profile Management** integration
- ✅ **Settings** access

### 🌐 Network Layer

- ✅ **HTTP/Dio Client** with interceptors
- ✅ **Error Handling** with user-friendly messages
- ✅ **Request/Response Logging** for debugging
- ✅ **Token Injection** for authenticated requests
- ✅ **Retry Logic** for failed requests
- ✅ **Timeout Configuration** with fallbacks

### 💾 Data Layer

- ✅ **Repository Pattern** for data abstraction
- ✅ **Either Pattern** for error handling
- ✅ **Model Classes** with JSON serialization
- ✅ **Caching Strategy** (if Hive selected)
- ✅ **Local Storage** with flutter_secure_storage

### 🎨 UI Components

- ✅ **Material Design 3** components
- ✅ **Responsive Layouts** for different screen sizes
- ✅ **Loading States** with shimmer effects
- ✅ **Error States** with retry options
- ✅ **Empty States** with helpful messages
- ✅ **Form Validation** with real-time feedback

## 🛠️ Development Workflow

### Initial Setup

```bash
# 1. Create project
blocx create my_app

# 2. Navigate to project
cd my_app

# 3. Install dependencies
flutter pub get

# 4. Run the app
flutter run
```

### Adding New Features

```bash
# 1. Generate new module
blocx generate module products

# 2. Add required packages
blocx add package sqflite
blocx add packages  # Interactive selection

# 3. Generate specific screens
blocx generate screen product_list
blocx generate screen product_detail

# 4. Update API constants and routing
# (Follow the generated comments in code)
```

### Code Quality

```bash
# Analyze code
flutter analyze

# Run tests
flutter test

# Format code
dart format .

# Generate coverage
flutter test --coverage
```

## 🏗️ Architecture Overview

BlocX CLI follows **Clean Architecture** principles:

### 📱 Presentation Layer

- **Screens**: UI components and user interactions
- **BLoC**: State management and business logic
- **Widgets**: Reusable UI components

### 💼 Domain Layer

- **Models**: Data entities and business objects
- **Repositories**: Abstract data contracts
- **Use Cases**: Business logic operations

### 💾 Data Layer

- **Repositories**: Concrete data implementations
- **Data Sources**: API clients and local storage
- **Models**: Data transfer objects

### 🔧 Core Layer

- **Network**: HTTP clients and API services
- **Utils**: Helper functions and utilities
- **Constants**: App-wide constants and configuration
- **Errors**: Error handling and exceptions

## 🎨 Customization

### 🎯 API Configuration

Update `lib/core/constants/api_constants.dart`:

```dart
class ApiConstants {
  static const String baseUrl = 'https://your-api.com';
  static const String apiVersion = '/v1';

  // Add your endpoints
  static const String products = '/products';
  static const String orders = '/orders';
}
```

### 🎨 Theme Configuration

Modify `lib/core/theme/app_theme.dart`:

```dart

static ThemeData lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue, // Your brand color
  ),
  // Customize other theme properties
);
```

### 🧭 Navigation

Add routes in `lib/app/app_router.dart`:

```dart
case AppConstants.productListRoute:
return MaterialPageRoute(builder: (_)
=>
const
ProductListScreen
(
)
);
```

## 🔍 Troubleshooting

### Common Issues

**Command not found:**

```bash
# Ensure PATH is set correctly
echo $PATH | grep pub-cache

# If not found, add to your shell config
echo 'export PATH="$PATH":"$HOME/.pub-cache/bin"' >> ~/.zshrc
source ~/.zshrc
```

**Flutter not found:**

```bash
# Verify Flutter installation
flutter doctor

# Install if needed: https://flutter.dev/docs/get-started/install
```

**Permission denied:**

```bash
# Fix executable permissions
chmod +x ~/.pub-cache/bin/blocx
```

**Project creation fails:**

```bash
# Ensure you have write permissions
# Run in a directory you own
cd ~/Projects
blocx create my_app
```

## 🤝 Contributing

We welcome contributions! Here's how to help:

1. **🍴 Fork** the repository
2. **🌿 Create** your feature branch (`git checkout -b feature/amazing-feature`)
3. **✅ Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **📤 Push** to the branch (`git push origin feature/amazing-feature`)
5. **🔀 Open** a Pull Request

### Development Setup

```bash
# Clone the repository
git clone https://github.com/RahulDev-flutter/blocx_cli.git
cd blocx_cli

# Install dependencies
dart pub get

# Run tests
dart test

# Test locally
dart pub global activate --source path .
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Flutter Team** for the amazing framework
- **BLoC Library** for excellent state management
- **Community** for feedback and contributions

## 📞 Support

- 🐛 **Issues**: [GitHub Issues](https://github.com/RahulDev-flutter/blocx_cli/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/RahulDev-flutter/blocx_cli/discussions)
- 📧 **Email**: your.email@example.com

---

**Made with ❤️ by Rahul Verma, for developers**

Transform your Flutter development workflow with BlocX CLI! 🚀
