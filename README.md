# NutriTrack MAMA 🤱📱

**Maternal Nutrition Tracking System for Healthcare Workers**

[![Flutter](https://img.shields.io/badge/Flutter-3.8.1-blue.svg)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-orange.svg)](https://firebase.google.com/)
[![Node.js](https://img.shields.io/badge/Node.js-16.0+-green.svg)](https://nodejs.org/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## 📋 Overview

NutriTrack MAMA is a comprehensive mobile application designed to support maternal nutrition monitoring in healthcare settings. The system enables healthcare workers to register pregnant women, track their nutritional intake via SMS, and receive automated alerts for nutritional deficiencies.

### 🎯 Key Features

- **👩‍⚕️ Healthcare Worker Authentication** - Secure login with Firebase Auth + Google Sign-In
- **👶 Patient Management** - Complete CRUD operations for pregnant women
- **📱 SMS Integration** - Food logging via simple SMS messages (Twilio)
- **🔔 Smart Alerts** - Automated nutrition deficiency detection
- **📊 Analytics Dashboard** - Visual nutrition trends and reports
- **🌍 Multi-language Support** - English, Swahili, Kinyarwanda

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │   Node.js API   │    │   Firebase      │
│                 │    │                 │    │                 │
│ • Authentication│◄──►│ • REST Endpoints│◄──►│ • Firestore     │
│ • Patient CRUD  │    │ • SMS Webhooks  │    │ • Realtime DB   │
│ • Analytics     │    │ • Auth Middleware│    │ • Authentication│
│ • Alerts        │    │ • Nutrition AI  │    │ • Security Rules│
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                                ▼
                       ┌─────────────────┐
                       │   Twilio SMS    │
                       │                 │
                       │ • Patient SMS   │
                       │ • Food Logging  │
                       │ • Alerts        │
                       └─────────────────┘
```

## 🚀 Quick Start

### Prerequisites

- **Flutter SDK** 3.8.1+
- **Node.js** 16.0+
- **Firebase CLI**
- **Twilio Account**
- **Android Studio/Xcode**

### 📱 Frontend Setup

1. **Clone the repository**
```bash
git clone https://github.com/your-username/nutritrack.git
cd nutritrack/nutritrack_test
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Firebase Configuration**
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login and initialize
firebase login
firebase init

# Add configuration files:
# - android/app/google-services.json
# - ios/Runner/GoogleService-Info.plist
```

4. **Run the application**
```bash
# For Android/iOS (required for full functionality)
flutter run

# For development testing only
flutter run -d chrome
```

### 🖥️ Backend Setup

1. **Navigate to backend directory**
```bash
cd nutritrack-backend
```

2. **Install dependencies**
```bash
npm install
```

3. **Environment configuration**
```bash
# Create .env file
FIREBASE_DATABASE_URL=https://your-project.firebaseio.com
TWILIO_ACCOUNT_SID=your_twilio_sid
TWILIO_AUTH_TOKEN=your_twilio_token
TWILIO_PHONE_NUMBER=your_twilio_number
```

4. **Add Firebase service account**
- Download `serviceAccountkey.json` from Firebase Console
- Place in backend root directory

5. **Start the server**
```bash
node index.js
```

6. **Configure Twilio webhook**
- Set webhook URL: `https://your-domain.com/incoming-sms`
- HTTP Method: POST

## 📊 Database Schema

### Firebase Firestore Collections

```javascript
// Healthcare Workers
healthcare_workers/{uid}
├── name: string
├── email: string
├── healthcareId: string
├── facilityName: string
├── role: string
└── lastUpdated: timestamp

// Patients
patients/{patientId}
├── name: string
├── phone: string
├── age: number
├── language: string
├── trimester: number
├── assignedTo: string
└── createdAt: timestamp

// Nutrition Logs
nutrition_logs/{logId}
├── from: string
├── body: string
├── parsedFood: string
├── quantity: string
├── receivedAt: timestamp
└── linkedPatient: reference

// SMS Logs
sms_logs/{logId}
├── phone: string
├── message: string
├── messageSid: string
├── status: string
├── type: string
└── timestamp: timestamp

// Alerts
alerts_sent/{alertId}
├── patientId: string
├── phone: string
├── message: string
└── triggeredAt: timestamp
```

## 🔐 Security

### Firebase Security Rules

```javascript
// Firestore Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Healthcare workers can only access their own data
    match /healthcare_workers/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Patients accessible only by assigned healthcare worker
    match /patients/{patientId} {
      allow read, write: if request.auth != null && 
        resource.data.assignedTo == getHealthcareId(request.auth.uid);
    }
    
    function getHealthcareId(uid) {
      return get(/databases/$(database)/documents/healthcare_workers/$(uid)).data.healthcareId;
    }
  }
}
```

## 🧪 Testing

### Run Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/auth_test.dart
```

### Test Coverage

- **Unit Tests**: Authentication, API services, data models
- **Widget Tests**: UI components, user interactions
- **Integration Tests**: End-to-end user workflows
- **Coverage**: 85%+ code coverage maintained

## 📱 API Documentation

### Authentication Endpoints

```http
POST /auth/register
Content-Type: application/json
Authorization: Bearer <firebase-token>

{
  "name": "Dr. Sarah Johnson",
  "email": "sarah@hospital.com",
  "healthcareId": "HCW001",
  "facilityName": "Central Hospital",
  "role": "Nutritionist"
}
```

### Patient Management

```http
# Create Patient
POST /send-sms
{
  "name": "Maria Uwimana",
  "phone": "+250788123456",
  "age": 26,
  "language": "kinyarwanda",
  "trimester": 2,
  "assignedTo": "HCW001"
}

# Get Patients
GET /patients?assignedTo=HCW001

# Update Patient
PUT /patients/{patientId}
{
  "trimester": 3,
  "age": 27
}
```

### SMS Integration

```http
# Incoming SMS Webhook (Twilio)
POST /incoming-sms
Content-Type: application/x-www-form-urlencoded

From=+250788123456&Body=BEANS 1C
```

### Alerts

```http
# Get Healthcare Worker Alerts
GET /hcw-alerts?healthcareWorkerId=HCW001&days=7

# Send Alert
POST /send-alert
{
  "patientId": "patient123"
}
```

## 📊 Usage Examples

### Patient Registration Flow

1. Healthcare worker opens app and logs in
2. Taps "Add Patient" button
3. Fills patient information form
4. System sends welcome SMS in patient's language
5. Patient receives: "Karibu NutriTrack MAMA 🌸 Tafadhali tuma chakula kama: MAHARAGE 1C"

### Food Logging Flow

1. Patient sends SMS: "BEANS 1C"
2. System parses message and stores nutrition data
3. Patient receives confirmation: "✅ BEANS (1C) logged. Thank you!"
4. Healthcare worker sees updated nutrition dashboard

### Alert Generation

1. System analyzes patient's 7-day nutrition history
2. Detects protein deficiency for trimester 2
3. Sends SMS to patient: "⚠️ Nutrition Alert: Low protein intake. Advice: Add beans, fish, or eggs to meals"
4. Creates alert for healthcare worker dashboard

## 🛠️ Development

### Project Structure

```
nutritrack/
├── nutritrack_test/          # Flutter mobile app
│   ├── lib/
│   │   ├── models/          # Data models
│   │   ├── screens/         # UI screens
│   │   ├── widgets/         # Reusable components
│   │   ├── services/        # API services
│   │   ├── state/           # State management
│   │   └── utils/           # Utility functions
│   ├── test/                # Test files
│   └── pubspec.yaml         # Dependencies
├── nutritrack-backend/       # Node.js backend
│   ├── routes/              # API routes
│   ├── utils/               # Utilities
│   ├── data/                # Static data
│   ├── index.js             # Main server
│   └── package.json         # Dependencies
└── README.md                # This file
```

### Code Quality

```bash
# Format code
dart format .

# Analyze code
flutter analyze

# Check for issues
dart fix --dry-run
```

## 🌍 Localization

### Supported Languages

- **English**: Default language for healthcare workers
- **Swahili**: "Karibu NutriTrack MAMA 🌸 Tafadhali tuma chakula kama: MAHARAGE 1C"
- **Kinyarwanda**: "Murakaza neza kuri NutriTrack MAMA 🌸 Andika: IBISHYIMO 1C buri munsi"

### Adding New Languages

1. Add language option in patient registration
2. Update SMS message templates in `index.js`
3. Add translation strings for UI elements

## 🚀 Deployment

### Production Deployment

1. **Build Flutter app**
```bash
flutter build apk --release
flutter build ios --release
```

2. **Deploy backend**
```bash
# Deploy to Firebase Functions
firebase deploy --only functions

# Or deploy to your preferred cloud provider
```

3. **Configure production environment**
- Update Firebase security rules
- Set production Twilio webhook URLs
- Configure environment variables

## 📈 Performance

### Optimization Features

- **State Management**: Provider pattern with selective rebuilds
- **Caching**: SharedPreferences for offline data
- **Image Optimization**: Cached network images
- **Database**: Firestore indexes for fast queries
- **API**: Rate limiting and connection pooling

### Monitoring

- **Firebase Analytics**: User engagement tracking
- **Crashlytics**: Real-time crash reporting
- **Performance Monitoring**: API response times
- **Custom Logging**: Structured logging for debugging

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow Flutter/Dart style guide
- Write tests for new features
- Update documentation
- Ensure code passes all quality checks

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Team

- **Technical Lead**: Project architecture, authentication system
- **Frontend Developer**: UI/UX design, Flutter widgets
- **Backend Developer**: Node.js API, SMS integration
- **QA Engineer**: Testing, quality assurance
- **Data Analyst**: Analytics, nutrition algorithms

## 🆘 Support

### Common Issues

**Q: SMS not being received?**
A: Check Twilio configuration and webhook URL setup.

**Q: Firebase authentication failing?**
A: Verify `google-services.json` and `GoogleService-Info.plist` are properly configured.

**Q: App crashing on startup?**
A: Ensure all dependencies are installed with `flutter pub get`.

### Getting Help

- 📧 Email: support@nutritrack-mama.com
- 🐛 Issues: [GitHub Issues](https://github.com/your-username/nutritrack/issues)
- 📖 Documentation: [Wiki](https://github.com/your-username/nutritrack/wiki)

## 🎯 Roadmap

### Version 2.0 (Planned)
- [ ] AI-powered food recognition from images
- [ ] Voice-to-text food logging
- [ ] Integration with wearable devices
- [ ] Advanced predictive analytics
- [ ] Multi-facility support
- [ ] EHR system integration

### Version 1.1 (Next Release)
- [ ] Push notifications
- [ ] Offline mode improvements
- [ ] Additional language support
- [ ] Enhanced analytics dashboard

---

**Made with ❤️ for maternal health by the NutriTrack MAMA team**

*Bridging the digital divide in maternal healthcare through innovative SMS integration*