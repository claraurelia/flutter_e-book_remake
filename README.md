# 📚 Flutter Ebook App

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-039BE5?style=for-the-badge&logo=Firebase&logoColor=white)](https://firebase.google.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A modern, feature-rich ebook application built with Flutter. This app provides a seamless reading experience with dual user roles (Admin & User), flat design UI, and comprehensive book management system.

> **Status**: 🚧 **In Development** - Version 2.0 with flat design system and enhanced features

> **🔒 Security Notice**: This repository does NOT contain Firebase configuration files for security reasons. See [FIREBASE_SECURITY.md](FIREBASE_SECURITY.md) for setup instructions.

## 🎨 Design System

### **Flat Design Revolution**
- ✅ **Clean Flat Backgrounds**: No more gradient backgrounds, pure flat colors
- ✅ **Modern Card System**: Consistent CardStyles utility across all components
- ✅ **Shadow-Free Design**: Clean borders instead of dark shadows
- ✅ **Dark/Light Mode**: Seamless theme switching with flat color scheme
- ✅ **Consistent Spacing**: Unified design language throughout the app

## 🚀 Features

### 👤 User Features
- ✅ **Browse Books**: Explore curated ebook collection with flat card design
- ✅ **Search & Filter**: Advanced search with clean flat UI components
- ✅ **Favorites**: Personal bookmarks with modern card styling
- ✅ **Download Books**: Offline reading with PDF viewer integration
- ✅ **Profile Management**: Clean profile interface with role-based features
- ✅ **Theme Toggle**: Instant dark/light mode switching

### 🔧 Admin Features  
- ✅ **Admin Dashboard**: Comprehensive management interface (accessible via profile menu)
- ✅ **Book Management**: Add, edit, delete books with modern forms
- ✅ **User Analytics**: Monitor user activities and book statistics
- ✅ **Seed Data**: Quick test data generation for development
- ✅ **Role-Based Access**: Secure admin-only features

### 🎨 UI/UX Features
- ✅ **Flat Design System**: Modern, clean interface without shadows
- ✅ **Responsive Navigation**: Bottom navigation with flat styling
- ✅ **Smart Back Button**: Context-aware navigation (only shows when needed)
- ✅ **Consistent Cards**: Unified card styling across all screens
- ✅ **Clean Animations**: Smooth transitions without heavy effects

## 🛠️ Tech Stack

- **Framework**: Flutter 3.x
- **Language**: Dart
- **Backend**: Firebase (Auth, Firestore, Storage)
- **State Management**: Provider Pattern
- **Navigation**: Custom Navigation with IndexedStack
- **UI**: Custom Flat Design System
- **PDF Reader**: flutter_pdfview
- **Icons**: FontAwesome Flutter
- **Image Handling**: Image Picker & Firebase Storage

## 📦 Key Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.1.2
  
  # Firebase
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  cloud_firestore: ^5.4.3
  firebase_storage: ^12.3.2
  
  # UI & Navigation
  font_awesome_flutter: ^10.7.0
  flutter_animate: ^4.5.0
  
  # PDF & File Handling
  flutter_pdfview: ^1.3.2
  file_picker: ^8.1.2
  image_picker: ^1.1.2
  
  # Local Storage
  sqflite: ^2.4.0
  shared_preferences: ^2.3.2
  path_provider: ^2.1.4
  
  # Utilities
  permission_handler: ^11.3.1
  url_launcher: ^6.3.1
```

## 🏗️ Project Structure

```
lib/
├── core/
│   └── theme/
│       ├── app_colors.dart      # Flat color scheme
│       ├── app_theme.dart       # Theme configuration
│       ├── card_styles.dart     # Flat design utility
│       └── backgrounds.dart     # Background utilities
├── models/
│   ├── book_model.dart          # Book data model
│   └── user_model.dart          # User data model
├── providers/
│   ├── auth_provider.dart       # Authentication state
│   ├── book_provider.dart       # Book management state
│   └── theme_provider.dart      # Theme state management
├── screens/
│   ├── admin/                   # Admin-only screens
│   ├── auth/                    # Login/Register screens
│   ├── book/                    # Book detail & PDF reader
│   ├── books/                   # Books library screen
│   ├── home/                    # Home screen with flat design
│   ├── profile/                 # Profile & settings screens
│   └── main_wrapper.dart        # Main navigation wrapper
├── services/
│   ├── auth_service.dart        # Firebase authentication
│   ├── book_service.dart        # Book CRUD operations
│   └── image_service.dart       # Image upload handling
└── widgets/
    ├── premium_bottom_nav.dart  # Flat bottom navigation
    ├── card_styles.dart         # Card styling utilities
    └── glass_widgets.dart       # Legacy widgets (being phased out)
```

## ✅ Implementation Status

### **Completed Features**
- ✅ **Flat Design System**: Complete CardStyles utility implementation
- ✅ **Home Screen**: Converted to flat design with modern cards
- ✅ **Profile Screen**: Full conversion from glass to flat design
- ✅ **Books Library**: Flat background and card styling
- ✅ **Navigation**: Bottom nav with clean flat styling
- ✅ **Theme System**: Dark/light mode with flat backgrounds
- ✅ **Admin Dashboard**: Role-based admin menu integration
- ✅ **PDF Reader**: Functional ebook reading capabilities
- ✅ **Firebase Integration**: Authentication and data management
- ✅ **Navigation Fix**: Smart back button logic for tab contexts

### **In Progress**
- 🔄 **Auth Screens**: Converting login/register to flat design
- 🔄 **Book Detail**: Updating with flat card styling
- 🔄 **PDF Reader UI**: Flat design for reading controls
- 🔄 **Error Handling**: Enhanced user feedback systems

### **Planned Features**
- 📋 **Reading Progress**: Bookmark and progress tracking
- 📋 **Book Reviews**: User rating and review system
- 📋 **Premium Features**: Subscription and payment integration
- 📋 **Offline Sync**: Enhanced offline reading capabilities
- 📋 **Push Notifications**: Book recommendations and updates
- 📋 **Social Features**: Book sharing and recommendations
- 📋 **Advanced Search**: AI-powered book discovery
- 📋 **Multi-language**: Internationalization support
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
## 🚀 Next Steps

### **Phase 1: Design Completion** (Current Priority)
1. **Convert remaining GlassContainer widgets** in auth screens and PDF reader
2. **Standardize color scheme** across all components
3. **Optimize card shadows** and borders for consistent flat look
4. **Polish navigation animations** and transitions

### **Phase 2: Feature Enhancement**
1. **Implement reading progress tracking** with local storage
2. **Add book review and rating system** with Firestore
3. **Create comprehensive search filters** (author, category, rating)
4. **Develop premium subscription model** with payment integration

### **Phase 3: Performance & Polish**
1. **Optimize image loading** and caching strategies
2. **Implement offline-first architecture** for better UX
3. **Add comprehensive error handling** and user feedback
4. **Performance testing** and optimization

### **Phase 4: Advanced Features**
1. **AI-powered book recommendations** based on reading history
2. **Social features** for book sharing and discussions
3. **Multi-device sync** for reading progress and bookmarks
4. **Advanced analytics dashboard** for admin users

## � Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Firebase project setup
- Android Studio / VS Code
- Git

### Installation
1. **Clone the repository**
   ```bash
   git clone https://github.com/IlhamWidi/Ebook-Flutter.git
   cd Ebook-Flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **🔒 Configure Firebase (REQUIRED)**
   - See [FIREBASE_SECURITY.md](FIREBASE_SECURITY.md) for detailed setup
   - Add your `google-services.json` to `android/app/`
   - Generate `lib/firebase_options.dart` using FlutterFire CLI
   - **⚠️ NEVER commit these files to git!**

4. **Run the app**
   ```bash
   flutter run
   ```

### 🔒 Security Setup
**IMPORTANT**: Before running the app, you MUST configure Firebase:

1. **Read [FIREBASE_SECURITY.md](FIREBASE_SECURITY.md)** for complete setup instructions
2. **Copy template files**:
   ```bash
   cp android/app/google-services.json.example android/app/google-services.json
   cp lib/firebase_options.dart.example lib/firebase_options.dart
   ```
3. **Replace with your actual Firebase configuration**
4. **Verify files are in .gitignore** (they already are)

### Test Accounts
```
Admin Account:
Email: admin@test.com
Password: admin123

User Account:  
Email: user@test.com
Password: user123
```

## 📱 Screenshots

### Flat Design System
- **Clean Cards**: No shadows, subtle borders
- **Flat Backgrounds**: Consistent dark/light backgrounds
- **Modern Typography**: Clean, readable fonts
- **Consistent Spacing**: Unified layout principles

### Dark Mode Support
- **True Dark Mode**: Deep dark backgrounds
- **Proper Contrast**: Optimized text and element visibility
- **Flat Card Design**: Dark cards with subtle borders
- **Consistent Theme**: Unified dark/light experience

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Priorities
1. **Flat Design Completion**: Help convert remaining components
2. **Feature Implementation**: Work on planned features
3. **Bug Fixes**: Improve stability and performance
4. **Documentation**: Enhance code documentation and guides

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Flutter Team** for the amazing framework
- **Firebase** for backend infrastructure
- **FontAwesome** for beautiful icons
- **Community** for inspiration and feedback

---

**Built with ❤️ using Flutter**

> **Note**: This is an educational project showcasing modern Flutter development with flat design principles, Firebase integration, and role-based authentication.
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
