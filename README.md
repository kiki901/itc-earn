# 🐹 Hamster Points - تطبيق مكافآت النقاط

تطبيق Android متكامل لنظام مكافآت النقاط مع دورة اقتصادية متكاملة.

## ✨ الميزات الرئيسية

- 🎰 **عجلة الحظ**: لف العجلة يومياً لمكافآت عشوائية
- 📅 **تسجيل الدخول اليومي**: مكافآت متزايدة مع الاستمرارية
- 🌐 **زيارة المواقع**: اربح نقاطاً لزيارة مواقع مختلفة
- 📋 **المهام**: أكمل المهام المختلفة واحصل على مكافآت
- 🐾 **متجر الحيوانات**: اشترِ حيوانات تمنحك أرباحاً يومية
- 💰 **المحفظة**: أدر نقاطك واسحبها
- 👥 **نظام الإحالة**: ادعُ أصدقاءك واكسب مكافآت
- 📱 **إعلانات AdMob**: ربح من الإعلانات البينية والمكافآت

## 🛠️ التقنيات المستخدمة

- **Flutter** - إطار عمل عبر الأنظمة
- **Firebase** - خلفية التطبيقات
  - Firebase Auth - المصادقة
  - Cloud Firestore - قاعدة البيانات
- **Google AdMob** - الإعلانات
- **Provider** - إدارة الحالة

## 📁 هيكل المشروع

```
lib/
├── main.dart                    # نقطة البداية
├── app.dart                     # إعداد التطبيق
├── models/                      # نماذج البيانات
│   ├── user_model.dart
│   ├── task_model.dart
│   ├── animal_model.dart
│   └── transaction_model.dart
├── services/                    # الخدمات
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   ├── ad_service.dart
│   └── payment_service.dart
├── providers/                   # مزودي الحالة
│   ├── auth_provider.dart
│   ├── user_provider.dart
│   ├── animal_provider.dart
│   └── task_provider.dart
├── screens/                     # الشاشات
│   ├── splash_screen.dart
│   ├── onboarding_screen.dart
│   ├── home_screen.dart
│   ├── visit_sites_screen.dart
│   ├── tasks_screen.dart
│   ├── market_screen.dart
│   ├── my_farm_screen.dart
│   ├── wallet_screen.dart
│   └── referral_screen.dart
├── widgets/                     # المكونات
│   ├── daily_login_widget.dart
│   ├── wheel_of_fortune.dart
│   ├── animal_card.dart
│   ├── task_card.dart
│   ├── transaction_tile.dart
│   └── points_display.dart
├── utils/                       # الأدوات
│   ├── constants.dart
│   ├── helpers.dart
│   └── arabic_strings.dart
└── theme/                       # الثيم
    └── app_theme.dart
```

## 🚀 خطوات البدء

### 1. تثبيت Flutter
```bash
# تثبيت Flutter SDK
# https://docs.flutter.dev/get-started/install

# التحقق من التثبيت
flutter --version
```

### 2. إعداد Firebase

1. أنشئ مشروع Firebase جديد على [Firebase Console](https://console.firebase.google.com)
2. أضف تطبيق Android إلى المشروع
3. حمّل ملف `google-services.json`
4. ضع الملف في `android/app/`
5. فعّل الخدمات التالية:
   - Authentication (Google Sign-In)
   - Cloud Firestore
   - Hosting (اختياري)

### 3. إعداد AdMob

1. أنشئ حساب على [Google AdMob](https://admob.google.com)
2. أنشئ وحدات إعلانية جديدة:
   - Interstitial Ad
   - Rewarded Ad
   - Banner Ad (اختياري)
3. استبدل المعرّفات في `lib/utils/constants.dart`

### 4. تشغيل التطبيق

```bash
# تثبيت التبعيات
flutter pub get

# تشغيل على جهاز Android
flutter run

# بناء APK
flutter build apk --release
```

## 📋 الإعدادات المطلوبة

### تحديث ملف `lib/utils/constants.dart`

```dart
// Firebase
static const String firebaseApiKey = 'YOUR_ACTUAL_API_KEY';
static const String firebaseAppId = 'YOUR_ACTUAL_APP_ID';

// AdMob
static const String androidInterstitialAdId = 'ca-app-pub-XXXXXXXXX/YYYYYYY';
static const String androidRewardedAdId = 'ca-app-pub-XXXXXXXXX/YYYYYYY';

// الدفع
static const String withdrawUrl = 'https://yourwebsite.com/withdraw';
```

### تحديث `android/app/build.gradle`

```gradle
defaultConfig {
    applicationId "com.yourcompany.hamsterpoints"  // استبدل بـ ID الخاص بك
    minSdkVersion 21
    targetSdkVersion 33
    versionCode 1
    versionName "1.0.0"
}

signingConfigs {
    release {
        keyAlias 'your-key-alias'
        keyPassword 'your-key-password'
        storeFile file('your-keystore.jks')
        storePassword 'your-store-password'
    }
}

buildTypes {
    release {
        signingConfig signingConfigs.release
    }
}
```

## 🔐 قواعد Google Play

- ✅ لا توجد وعود بأرباح مالية
- ✅ المكافآت وصفها "نقاط افتراضية"
- ✅ السحب يتم عبر موقع خارجي
- ✅ الإعلانات تتبع سياسات AdMob
- ✅ بوليصة خصوصية واضحة

## 🎯 النموذج الاقتصادي

| المصدر | الوصف |
|--------|-------|
| AdMob Interstitial | إعلانات بينية عند التنقل |
| AdMob Rewarded | مشاهدة إعلان مقابل مكافأة |
| شراء النقاط | باقات متنوعة عبر Google Pay |
| رسوم السحب | 5% رسوم على عمليات السحب |

## 📱 الشاشات

1. **الرئيسية**: ملخص + تسجيل دخول + عجلة حظ
2. **زيارة المواقع**: قائمة مواقع مع عداد تنازلي
3. **المهام**: أنواع مهام مختلفة
4. **المتجر**: شراء حيوانات
5. **مزرعتي**: إدارة الحيوانات وجمع الأرباح
6. **المحفظة**: إيداع وسحب النقاط
7. **الإحالة**: نظام دعوة الأصدقاء

## 🤝 المساهمة

مرحباً بالمساهمات! يرجى فتح issue أو pull request.

## 📄 الترخيص

هذا المشروع مرخص بموجب MIT License.

## 📧 التواصل

- البريد الإلكتروني: your@email.com
- Twitter: @yourhandle
