# Falo Mobile App

Falo is a cross-platform mobile application built with Flutter that helps users identify and verify potential misinformation in news and online content.

## 🚀 Features

- **Content Analysis**: Submit text or URLs for misinformation analysis
- **Real-time Verification**: Get instant feedback on content credibility
- **News Feed**: Browse verified news from trusted sources
- **History**: View your previous verifications
- **User Profile**: Manage your account and preferences
- **Dark/Light Mode**: Choose your preferred theme

## 📱 Supported Platforms

- Android 6.0+ (API level 23+)
- iOS 12.0+
- Web (Progressive Web App)
- Desktop (Windows, macOS, Linux)

## 🛠️ Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK (included with Flutter)
- Android Studio / Xcode (for mobile development)
- VS Code or Android Studio (recommended IDEs)

## 🚀 Getting Started

### 1. Clone the repository
```bash
git clone [your-repository-url]
cd Falo
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Configure environment
Create a `.env` file in the project root with the following variables:
```
API_BASE_URL=http://localhost:8000
SENTRY_DSN=your-sentry-dsn-if-using
```

### 4. Run the app
```bash
# For web
flutter run -d chrome

# For Android
flutter run -d <device_id>

# For iOS
flutter run -d <device_id>
```

## 📂 Project Structure

```
lib/
├── main.dart          # Application entry point
├── config/           # App configuration and constants
├── models/           # Data models
├── providers/        # State management
├── screens/          # App screens
├── services/         # API and business logic
├── theme/            # App theming
├── utils/            # Helper functions and utilities
├── widgets/          # Reusable widgets
└── main_development.dart  # Development entry point
```

## 🛠 Development

### Running tests
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

### Code Generation
This project uses:
- `build_runner` for code generation
- `freezed` for immutable models
- `json_serializable` for JSON serialization

To generate code, run:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Code Style
This project follows the [official Flutter style guide](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo).

## 📦 Building for Production

### Android
```bash
flutter build apk --release
# or
flutter build appbundle
```

iOS
```bash
flutter build ios --release
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with Flutter
- Uses Provider for state management
- Integrates with Falo Backend API
- Icons by [Font Awesome](https://fontawesome.com/)

