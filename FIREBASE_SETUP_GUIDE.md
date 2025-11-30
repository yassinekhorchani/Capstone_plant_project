# Firebase Setup Guide for DeepSea Plant Doctor

## Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click on **"Add project"** or **"Create a project"**
3. Enter project name: **`DeepSea-Plant-Doctor`** (or any name you prefer)
4. Click **Continue**
5. **Disable Google Analytics** (you can enable it later if needed) or keep it enabled
6. Click **Create project**
7. Wait for the project to be created, then click **Continue**

---

## Step 2: Add Android App to Firebase

1. In your Firebase project dashboard, click on the **Android icon** to add an Android app
2. Fill in the required information:
   - **Android package name**: `com.example.capstone_deepsea`
     - To find this, open: `android/app/build.gradle`
     - Look for `applicationId` under `defaultConfig`
   - **App nickname** (optional): `DeepSea Android`
   - **Debug signing certificate SHA-1** (optional for now): Leave empty
3. Click **Register app**

---

## Step 3: Download google-services.json

1. Click **Download google-services.json**
2. Move the downloaded file to your project:
   ```
   capstone_deepsea/android/app/google-services.json
   ```
   - Place it directly in the `android/app/` folder
3. Click **Next**

---

## Step 4: Add Firebase SDK to Android

### 4.1 Edit `android/build.gradle` (Project level)

Open `capstone_deepsea/android/build.gradle` and make sure you have:

```gradle
buildscript {
    ext.kotlin_version = '2.1.0'
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath "com.android.tools.build:gradle:8.9.1"
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
        classpath "com.google.gms:google-services:4.4.2"  // Add this line
    }
}
```

### 4.2 Edit `android/app/build.gradle` (App level)

Open `capstone_deepsea/android/app/build.gradle` and add at the **BOTTOM** of the file:

```gradle
// At the very bottom, after the dependencies block
apply plugin: 'com.google.gms.google-services'
```

The end of your file should look like:
```gradle
dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
}

apply plugin: 'com.google.gms.google-services'  // Add this line
```

---

## Step 5: Enable Firebase Authentication

1. In Firebase Console, go to **Build** → **Authentication**
2. Click **Get started**
3. Go to **Sign-in method** tab
4. Click on **Email/Password**
5. **Enable** the toggle for Email/Password
6. Click **Save**

---

## Step 6: Install Flutter Packages

Run this command in your terminal:

```bash
cd c:\Users\borhe\Capstone_plant_project\capstone_deepsea
flutter pub get
```

---

## Step 7: Initialize Firebase in Your App

The code is already set up! Here's what was added:

### Main.dart
```dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();  // Initialize Firebase
  runApp(const DeepSeaApp());
}
```

### Auth Service Created
File: `lib/services/auth_service.dart`
- Sign in with email/password
- Register new users
- Sign out
- Password reset
- Error handling

---

## Step 8: Test Your Setup

1. Run your app:
   ```bash
   flutter run -d R5CY42QYAZF
   ```

2. Try to **register** a new account:
   - Enter name, email, password
   - Click Sign Up
   - You should see "Registration successful!"

3. Check Firebase Console:
   - Go to **Authentication** → **Users**
   - You should see the new user listed

4. Try to **login** with the same credentials
   - Should successfully log in

---

## Step 9: Add Firebase Auth to Android Manifest (Optional)

Open `android/app/src/main/AndroidManifest.xml` and add internet permission if not already there:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.CAMERA" />
    <!-- ... rest of your manifest -->
</manifest>
```

---

## Troubleshooting

### Error: "No Firebase App"
- Make sure `google-services.json` is in `android/app/`
- Run `flutter clean` then `flutter pub get`

### Error: "Default Firebase app not initialized"
- Make sure you have `await Firebase.initializeApp();` in `main.dart`

### Build Error
- Check that you added the google-services plugin in both gradle files
- Make sure Kotlin version matches (2.1.0)

### Authentication Not Working
- Verify Email/Password is enabled in Firebase Console
- Check Firebase Authentication → Users to see if registration worked

---

## Current Features Implemented

✅ Email/Password Registration
✅ Email/Password Login
✅ User Display Name
✅ Error Handling
✅ Loading States
✅ Form Validation
✅ Password Visibility Toggle
✅ Terms & Conditions Agreement

---

## What's Next?

After authentication is working, you can add:
- Forgot Password functionality
- Email verification
- User profile management
- Logout functionality
- Protected routes (only authenticated users can access certain screens)

---

## Quick Reference

**Firebase Console**: https://console.firebase.google.com/

**Your Project Structure**:
```
capstone_deepsea/
├── android/
│   ├── app/
│   │   ├── google-services.json  ← Firebase config
│   │   └── build.gradle          ← Add plugin here
│   └── build.gradle               ← Add classpath here
├── lib/
│   ├── services/
│   │   └── auth_service.dart      ← Authentication logic
│   └── screens/
│       ├── login_screen.dart      ← Login UI
│       └── register_screen.dart   ← Register UI
└── pubspec.yaml                   ← Dependencies
```

---

Good luck! 🚀
