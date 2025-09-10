# 🔒 Firebase Configuration Security

## ⚠️ IMPORTANT SECURITY WARNING

**NEVER COMMIT THESE FILES TO GIT:**
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `lib/firebase_options.dart`
- Any `.env` files containing API keys

These files contain sensitive Firebase configuration that could compromise your project if exposed publicly.

## 🛠️ Setup Instructions

### 1. Firebase Configuration

1. **Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project or use existing one

2. **Add Android App**
   - Click "Add app" → Android
   - Package name: `com.example.ebook_job`
   - Download `google-services.json`
   - Place in `android/app/google-services.json`

3. **Add iOS App** (if needed)
   - Click "Add app" → iOS
   - Bundle ID: `com.example.ebookJob`
   - Download `GoogleService-Info.plist`
   - Place in `ios/Runner/GoogleService-Info.plist`

### 2. Generate Firebase Options

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for Flutter
flutterfire configure
```

This will generate `lib/firebase_options.dart` with your project configuration.

### 3. Enable Firebase Services

In Firebase Console, enable:
- **Authentication** → Sign-in method → Email/Password
- **Firestore Database** → Create database
- **Storage** → Get started

### 4. Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Books can be read by authenticated users
    match /books/{bookId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

### 5. Storage Security Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /book_covers/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        request.auth.token.role == 'admin';
    }
  }
}
```

## 🔐 Environment Variables

For additional security, consider using environment variables:

1. Create `.env` file (already in .gitignore):
```env
FIREBASE_API_KEY=your-api-key
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_SENDER_ID=your-sender-id
```

2. Use in Dart code:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

const apiKey = String.fromEnvironment('FIREBASE_API_KEY', 
  defaultValue: dotenv.env['FIREBASE_API_KEY'] ?? 'default-key');
```

## 📋 Checklist

Before deploying:
- [ ] Firebase configuration files are NOT in git
- [ ] .gitignore includes Firebase files
- [ ] Firestore security rules are configured
- [ ] Storage security rules are configured
- [ ] Authentication is properly configured
- [ ] Environment variables are used for sensitive data

## 🚨 If You Accidentally Committed Sensitive Files

1. **Remove from git immediately:**
   ```bash
   git rm --cached android/app/google-services.json
   git rm --cached lib/firebase_options.dart
   git commit -m "Remove sensitive Firebase files"
   ```

2. **Regenerate Firebase keys** in Firebase Console

3. **Update .gitignore** to prevent future commits

4. **Consider repository as compromised** and create new Firebase project if needed

## 📞 Support

If you need help with Firebase configuration, check:
- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Flutter Firebase Setup Guide](https://firebase.flutter.dev/docs/overview)
