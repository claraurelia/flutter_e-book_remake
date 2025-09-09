# 📚 Flutter Ebook App

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-039BE5?style=for-the-badge&logo=Firebase&logoColor=white)](https://firebase.google.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A modern, feature-rich ebook application built with Flutter. This app provides a seamless reading experience with dual user roles (Admin & User), dark theme UI, and comprehensive book management system.

> **Status**: 🚧 **In Development** - This is a demo version with mock authentication for testing purposes.

## 🚀 Features

### 👤 User Features
- � **Browse Books**: Explore a curated collection of ebooks
- � **Search & Filter**: Find books by title, author, or category
- ⭐ **Favorites**: Save books to your personal favorites list
- 💎 **Premium Books**: Purchase and access premium content
- 📱 **Download Books**: Offline reading capability
- 🌙 **Dark Theme**: Eye-friendly dark mode interface
- � **User Profile**: Manage account settings and preferences

### 🔧 Admin Features
- ➕ **Add Books**: Upload new ebooks to the collection
- ✏️ **Edit Books**: Update book information and metadata
- 🗑️ **Delete Books**: Remove books from the collection
- 📊 **Dashboard**: View app statistics and user analytics
- 👥 **User Management**: Monitor user activities and subscriptions

### 🎨 UI/UX Features
- 🌙 **Modern Dark Theme**: Sleek Material Design 3 interface
- 📱 **Responsive Design**: Optimized for various screen sizes
- � **Smooth Navigation**: Intuitive routing with GoRouter
- ⚡ **Fast Loading**: Cached images and optimized performance
- 🎯 **Role-based Access**: Different interfaces for Admin and User

## 🛠️ Tech Stack

- **Framework**: Flutter 3.x
- **Language**: Dart
- **Backend**: Firebase (Auth, Firestore, Storage)
- **State Management**: Provider
- **Navigation**: GoRouter
- **UI**: Material Design 3
- **Image Caching**: cached_network_image
- **Loading Animations**: flutter_spinkit

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^3.15.2
  firebase_auth: ^5.7.0
  cloud_firestore: ^5.6.12
  firebase_storage: ^12.4.10
  
  # State Management & Navigation
  provider: ^6.1.2
  go_router: ^14.8.1
  
  # UI & Utils
  cached_network_image: ^3.4.1
  flutter_spinkit: ^5.2.1
  file_picker: ^8.3.7
  permission_handler: ^11.4.0
  
  # Development
  flutter_lints: ^5.0.0
```

## 🏗️ Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   └── app_strings.dart
│   └── theme/
│       └── app_theme.dart
├── models/
│   ├── user_model.dart
│   └── book_model.dart
├── services/
│   ├── auth_service.dart
│   ├── book_service.dart
│   └── mock_auth_service.dart
├── providers/
│   ├── auth_provider.dart
│   ├── book_provider.dart
│   └── mock_auth_provider.dart
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── books/
│   │   └── book_detail_screen.dart
│   ├── profile/
│   │   └── profile_screen.dart
│   └── admin/
│       └── admin_dashboard_screen.dart
├── widgets/
│   └── common/
│       └── loading_widget.dart
└── main.dart
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code
- Firebase Project (for production)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/flutter-ebook-app.git
   cd flutter-ebook-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app (Development Mode)**
   ```bash
   flutter run
   ```

## 🧪 Demo Mode

The app includes a **mock authentication system** for development and testing:

### Demo Accounts
- **Admin Account**: 
  - Email: `admin@test.com`
  - Password: `123456`
  
- **User Account**:
  - Email: `user@test.com` 
  - Password: `123456`

### Quick Demo Login
Use the **"Demo Admin"** and **"Demo User"** buttons on the login screen for instant access.

## 🔥 Firebase Setup (Production)

1. **Create a Firebase project** at [Firebase Console](https://console.firebase.google.com/)

2. **Enable services**:
   - Authentication (Email/Password)
   - Cloud Firestore
   - Cloud Storage

3. **Configure Firebase**:
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase for your project
   flutterfire configure
   ```

4. **Update main.dart** to use Firebase instead of Mock services

## 📱 Database Structure

### Users Collection
```
users/{userId}
├── uid: string
├── email: string
├── name: string
├── role: string (admin/user)
├── profileImage: string?
├── isPremium: boolean
├── createdAt: timestamp
├── favoriteBooks: array<string>
├── purchasedBooks: array<string>
└── downloadedBooks: array<string>
```

### Books Collection
```
books/{bookId}
├── title: string
├── author: string
├── description: string
├── category: string
├── coverImageUrl: string
├── fileUrl: string
├── price: number
├── isFree: boolean
├── isPremium: boolean
├── publishedDate: timestamp
├── downloadCount: number
├── favoriteCount: number
└── rating: number
```

## 🔧 Development Status

### ✅ Completed Features
- [x] Project structure setup
- [x] Authentication system (Mock & Firebase ready)
- [x] Dark theme UI implementation
- [x] Navigation with role-based access
- [x] User and Admin interfaces
- [x] Book listing and detail views
- [x] Profile management
- [x] Mock data for testing

### 🚧 In Progress
- [ ] Book CRUD operations (Admin)
- [ ] File upload for book covers
- [ ] Search and filter functionality
- [ ] Favorites system
- [ ] Premium book purchasing
- [ ] Download functionality

### 📋 Planned Features
- [ ] Payment integration
- [ ] Reading progress tracking
- [ ] Book categories and tags
- [ ] User reviews and ratings
- [ ] Push notifications
- [ ] Offline reading mode
- [ ] Social sharing features

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📱 Screenshots

*Screenshots will be added once the UI is finalized*

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors

- **Developer** - *Initial work* - [GitHub Profile](https://github.com/yourusername)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Material Design for UI guidelines
- Open source community for inspiration

## 📞 Support

If you have any questions or need help, please:

1. Create an issue in this repository
2. Contact the development team
3. Check the documentation

---

⭐ **Star this repository if you find it helpful!**

Made with ❤️ and Flutter

Key packages used in this project:

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.6.0
  cloud_firestore: ^5.4.3
  firebase_auth: ^5.3.1
  firebase_storage: ^12.3.2
  provider: ^6.1.2
  go_router: ^14.2.7
  cached_network_image: ^3.4.1
  flutter_spinkit: ^5.2.1
  # ... other dependencies
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Screenshots

[Add screenshots of your app here]

## Support

For support, email your-email@example.com or create an issue in this repository.
