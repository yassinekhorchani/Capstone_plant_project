# 🌿 DeepSea Plant Doctor

> AI-powered mobile application for plant disease detection and treatment recommendations

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![TensorFlow](https://img.shields.io/badge/TensorFlow-2.14-FF6F00?logo=tensorflow)](https://tensorflow.org)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

DeepSea Plant Doctor is a comprehensive mobile application that helps farmers and gardeners detect plant diseases using AI, get instant treatment advice, and track their plant health history.

![App Demo](docs/demo.gif)

---

## ✨ Features

### 🔍 **Smart Plant Disease Detection**
- Real-time plant disease detection using TensorFlow Lite
- Support for 38 different plant diseases and healthy conditions
- High accuracy predictions with confidence scores
- On-device ML inference for fast results

### 🤖 **AI-Powered Treatment Advice**
- Personalized care recommendations powered by Google Gemini AI
- Treatment plans for diseased plants
- Maintenance tips for healthy plants
- Prevention strategies and recovery timelines

### 📊 **Detection History & Analytics**
- Cloud-based storage of all plant scans
- Track plant health over time
- View past detection results
- Statistical insights on plant health

### 🔐 **Secure Authentication**
- User registration and login via Firebase Auth
- Personalized user profiles
- Secure data storage per user

### 📸 **Flexible Image Input**
- Camera capture for instant scanning
- Gallery upload for existing photos
- High-quality image processing

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────┐
│           Flutter Mobile App                │
│  ┌─────────────────────────────────────┐   │
│  │  UI Layer (Screens & Widgets)       │   │
│  └─────────────┬───────────────────────┘   │
│                │                             │
│  ┌─────────────▼───────────────────────┐   │
│  │  Service Layer                      │   │
│  │  • Auth Service                     │   │
│  │  • Firestore Service                │   │
│  │  • Supabase Service                 │   │
│  │  • Gemini AI Service                │   │
│  │  • TFLite Model Helper              │   │
│  └─────────────┬───────────────────────┘   │
└────────────────┼───────────────────────────┘
                 │
        ┌────────┼────────┐
        │        │        │
        ▼        ▼        ▼
   ┌────────┐ ┌─────┐ ┌────────┐
   │Firebase│ │Supa │ │Gemini  │
   │Auth &  │ │base │ │  AI    │
   │Firestore│ │Storage│ │  API   │
   └────────┘ └─────┘ └────────┘
                 │
                 ▼
          ┌─────────────┐
          │  TFLite     │
          │  Model      │
          │  (On-device)│
          └─────────────┘
```

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** (3.0 or higher) - [Install Flutter](https://flutter.dev/docs/get-started/install)
- **Android Studio** or **VS Code** with Flutter extensions
- **Python 3.8+** (for ML model retraining)
- **Git** for version control
- **Firebase Account** (free tier)
- **Supabase Account** (free tier)
- **Google AI Studio Account** (free tier)

### Installation

#### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/deepsea-plant-doctor.git
cd deepsea-plant-doctor
```

#### 2. Install Flutter Dependencies

```bash
cd capstone_deepsea
flutter pub get
```

#### 3. Configure Firebase

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or use existing one
3. Add an Android app with package name: `com.example.capstone_deepsea`
4. Download `google-services.json` and place it in:
   ```
   capstone_deepsea/android/app/google-services.json
   ```
5. Enable Firebase Authentication (Email/Password)
6. Enable Firestore Database
7. Set up Firestore security rules (see [Setup Guide](DATABASE_SETUP_GUIDE.md))

#### 4. Configure Supabase

1. Create account at [Supabase](https://supabase.com/)
2. Create a new project
3. Create a storage bucket named `plant-images` (make it public)
4. Copy your Project URL and anon key
5. Update `lib/services/supabase_service.dart`:
   ```dart
   static const String supabaseUrl = 'YOUR_SUPABASE_URL';
   static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
   ```

#### 5. Configure Gemini AI

1. Visit [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Create a free API key
3. Update `lib/services/gemini_service.dart`:
   ```dart
   static const String _apiKey = 'YOUR_GEMINI_API_KEY';
   ```

#### 6. Set Up ML Model

**Option A: Use Pre-trained Model** (Quick Start)
```bash
# Model files are already in assets/
# Skip to step 7
```

**Option B: Retrain Model** (Recommended for best results)
```bash
# Follow the complete retraining guide
See RETRAINING_GUIDE.md for detailed instructions
```

#### 7. Run the App

```bash
# List available devices
flutter devices

# Run on connected device
flutter run -d <device_id>

# Or run on specific device (example)
flutter run -d R5CY42QYAZF
```

## 🧪 Testing

### Run Unit Tests
```bash
flutter test
```

### Run Integration Tests
```bash
flutter test integration_test/
```

### Test ML Model
```bash
python test_model.py
```

---

## 📚 Documentation

Detailed documentation is available in the following guides:

- **[Firebase Setup Guide](FIREBASE_SETUP_GUIDE.md)** - Complete Firebase configuration
- **[Database Setup Guide](DATABASE_SETUP_GUIDE.md)** - Firestore & Supabase setup
- **[Gemini AI Setup Guide](GEMINI_SETUP_GUIDE.md)** - AI treatment advice configuration
- **[Model Retraining Guide](RETRAINING_GUIDE.md)** - How to retrain the TFLite model
- **[Quick Setup Checklist](QUICK_SETUP.md)** - Fast-track setup guide

---

## 🌱 Supported Plants & Diseases

The model currently detects diseases for the following plants:

### 🌶️ Pepper
- Bacterial spot
- Healthy

### 🥔 Potato
- Early blight
- Late blight
- Healthy

### 🍅 Tomato
- Bacterial spot
- Early blight
- Late blight
- Leaf mold
- Septoria leaf spot
- Spider mites (Two-spotted spider mite)
- Target spot
- Tomato Yellow Leaf Curl Virus
- Tomato mosaic virus
- Healthy

### 🍎 Apple
- Apple scab
- Black rot
- Cedar apple rust
- Healthy

### 🌽 Corn (Maize)
- Cercospora leaf spot (Gray leaf spot)
- Common rust
- Northern Leaf Blight
- Healthy

### 🍇 Grape
- Black rot
- Esca (Black Measles)
- Leaf blight (Isariopsis Leaf Spot)
- Healthy

### 🍑 Peach
- Bacterial spot
- Healthy

### 🫑 Bell Pepper
- Bacterial spot
- Healthy

### 🍓 Strawberry
- Leaf scorch
- Healthy

### 🍊 Orange (Citrus)
- Huanglongbing (Citrus greening)

### 🫐 Blueberry
- Healthy

### 🍒 Cherry
- Powdery mildew
- Healthy

### 🌿 Soybean
- Healthy

### 🥒 Squash
- Powdery mildew

### 🍐 Raspberry
- Healthy

**Total Classes**: 38 (15 plant types, 26 diseases, 12 healthy conditions)

---

## 🛠️ Technology Stack

### Frontend
- **Flutter** - Cross-platform mobile framework
- **Dart** - Programming language
- **Material Design** - UI/UX components

### Backend Services
- **Firebase Authentication** - User management
- **Cloud Firestore** - NoSQL database
- **Supabase Storage** - Image storage

### AI & ML
- **TensorFlow Lite** - On-device inference
- **EfficientNetB5** - CNN architecture
- **Google Gemini AI** - Treatment recommendations

### Development Tools
- **Android Studio** - IDE
- **VS Code** - Code editor
- **Git** - Version control

---

## 📊 Project Structure

```
deepsea-plant-doctor/
├── capstone_deepsea/              # Flutter application
│   ├── lib/
│   │   ├── main.dart              # App entry point
│   │   ├── screens/               # UI screens
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   ├── detection_screen.dart
│   │   │   └── treatment_advice_screen.dart
│   │   ├── services/              # Business logic
│   │   │   ├── auth_service.dart
│   │   │   ├── firestore_service.dart
│   │   │   ├── supabase_service.dart
│   │   │   └── gemini_service.dart
│   │   └── models/                # Data models
│   ├── android/
│   │   └── app/
│   │       ├── src/main/java/
│   │       │   └── TFLiteModelHelper.java  # ML inference
│   │       └── google-services.json        # Firebase config
│   ├── assets/
│   │   ├── my_model_tf214.tflite  # ML model
│   │   └── class_names.txt        # Disease labels
│   └── pubspec.yaml               # Flutter dependencies
│
├── retrain_model_tf214.py         # Model training script
├── convert_to_tflite_tf214.py     # TFLite conversion
├── setup_tf214_env.ps1            # Python environment setup
├── requirements_tf214.txt         # Python dependencies
│
├── docs/                          # Documentation
├── FIREBASE_SETUP_GUIDE.md
├── DATABASE_SETUP_GUIDE.md
├── GEMINI_SETUP_GUIDE.md
├── RETRAINING_GUIDE.md
├── QUICK_SETUP.md
│
├── LICENSE
└── README.md                      # This file
```

---

## 🔧 Configuration Files

### `pubspec.yaml` - Key Dependencies
```yaml
dependencies:
  firebase_core: ^3.8.1
  firebase_auth: ^5.3.3
  cloud_firestore: ^5.4.4
  image_picker: ^1.1.2
  supabase_flutter: ^2.8.0
  google_generative_ai: ^0.4.6
```

### Environment Variables
For production deployment, use environment variables:

```bash
# .env file (do not commit to git)
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_key
GEMINI_API_KEY=your_gemini_key
```


## 💰 Cost Estimate

All services have generous free tiers suitable for development and moderate use:

| Service | Free Tier | Monthly Cost (Development) |
|---------|-----------|----------------------------|
| Firebase Auth | Unlimited | $0 |
| Firestore | 50K reads/day | $0 |
| Supabase Storage | 1 GB | $0 |
| Gemini API | 1,500 requests/day | $0 |
| **Total** | | **$0/month** |

**Note**: Costs may apply at scale. Monitor usage in production.


## 🙏 Acknowledgments

- **PlantVillage Dataset** - Training data source
- **TensorFlow Team** - ML framework
- **Flutter Team** - Mobile framework
- **Firebase** - Backend infrastructure
- **Supabase** - Storage solution
- **Google Gemini** - AI recommendations


## 🔬 Research & References

This project is based on research in:
- Computer Vision for Agriculture
- Deep Learning for Plant Disease Detection
- Mobile Edge Computing for AI

### Key Papers
1. "Plant Disease Detection using Deep Learning" - IEEE Conference 2020
2. "EfficientNet: Rethinking Model Scaling for Convolutional Neural Networks" - ICML 2019
3. "PlantVillage Dataset: A Resource for Training AI Models" - arXiv 2015

---

## ⚡ Quick Start (TL;DR)

```bash
# 1. Clone repo
git clone https://github.com/yourusername/deepsea-plant-doctor.git
cd deepsea-plant-doctor/capstone_deepsea

# 2. Install dependencies
flutter pub get

# 3. Add Firebase config file
# Place google-services.json in android/app/

# 4. Update service credentials
# Edit lib/services/supabase_service.dart
# Edit lib/services/gemini_service.dart

# 5. Run app
flutter run

# 6. (Optional) Retrain model
cd ..
.\setup_tf214_env.ps1
python retrain_model_tf214.py
python convert_to_tflite_tf214.py
```

---

**Made with ❤️ by the DeepSea Team**

⭐ Star this repo if you find it helpful!
