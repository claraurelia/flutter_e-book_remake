# Contributing to Flutter Ebook App

Thank you for your interest in contributing to the Flutter Ebook App! We welcome contributions from everyone.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Git
- A GitHub account

### Setting Up Your Development Environment

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/yourusername/flutter-ebook-app.git
   cd flutter-ebook-app
   ```
3. **Add the original repository as upstream**:
   ```bash
   git remote add upstream https://github.com/originalowner/flutter-ebook-app.git
   ```
4. **Install dependencies**:
   ```bash
   flutter pub get
   ```

## 🏗️ Development Workflow

### Creating a Feature Branch

1. **Sync with upstream**:
   ```bash
   git checkout main
   git pull upstream main
   ```
2. **Create a new branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

### Making Changes

1. **Write clean, documented code**
2. **Follow the existing code style**
3. **Add tests for new functionality**
4. **Update documentation as needed**

### Code Style Guidelines

- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused
- Use proper error handling

### Commit Messages

Use clear and descriptive commit messages:

```bash
git commit -m "Add book search functionality"
git commit -m "Fix login button alignment issue"
git commit -m "Update README with new features"
```

### Testing

Before submitting your changes:

1. **Run tests**:
   ```bash
   flutter test
   ```
2. **Check for analysis issues**:
   ```bash
   flutter analyze
   ```
3. **Test on multiple platforms** (if possible):
   ```bash
   flutter run -d android
   flutter run -d ios
   ```

## 📝 Pull Request Process

1. **Push your changes** to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create a Pull Request** on GitHub with:
   - Clear title describing the change
   - Detailed description of what was changed and why
   - Screenshots if UI changes were made
   - Reference to any related issues

3. **Address review feedback** if requested

4. **Wait for approval** from maintainers

## 🐛 Reporting Bugs

When reporting bugs, please include:

- **Description** of the bug
- **Steps to reproduce** the issue
- **Expected behavior**
- **Actual behavior**
- **Screenshots** (if applicable)
- **Device/Platform** information
- **Flutter/Dart version**

## 💡 Suggesting Features

For feature requests:

- **Check existing issues** to avoid duplicates
- **Provide clear description** of the feature
- **Explain the use case** and benefits
- **Consider implementation complexity**

## 🎯 Priority Areas for Contribution

We especially welcome contributions in these areas:

### High Priority
- [ ] Firebase integration setup
- [ ] Book CRUD operations for admin
- [ ] Search and filter functionality
- [ ] User favorites system
- [ ] File upload for book covers

### Medium Priority
- [ ] Premium book purchasing system
- [ ] Download functionality
- [ ] User reviews and ratings
- [ ] Reading progress tracking
- [ ] Push notifications

### Low Priority
- [ ] Social sharing features
- [ ] Offline reading mode
- [ ] Multi-language support
- [ ] Advanced analytics
- [ ] Book recommendations

## 🔧 Development Setup for Specific Features

### Firebase Features
If working on Firebase-related features:
1. Set up a test Firebase project
2. Configure `firebase_options.dart`
3. Enable required services (Auth, Firestore, Storage)
4. Test with both mock and real data

### UI/UX Changes
For UI modifications:
1. Follow Material Design 3 guidelines
2. Maintain dark theme consistency
3. Test on different screen sizes
4. Ensure accessibility compliance

## 📚 Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
- [Firebase for Flutter](https://firebase.flutter.dev/)
- [Material Design 3](https://m3.material.io/)
- [Provider Package](https://pub.dev/packages/provider)

## 🤝 Code of Conduct

Please be respectful and constructive in all interactions. We're all here to learn and improve the project together.

## 🎉 Recognition

Contributors will be acknowledged in:
- README.md contributors section
- Release notes for major contributions
- GitHub contributors page

## ❓ Questions?

If you have questions about contributing:
- Create an issue with the "question" label
- Reach out to the maintainers
- Check existing documentation

Thank you for contributing to Flutter Ebook App! 🚀
