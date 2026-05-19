# Borcum - Borc/Alacak Takip Uygulamasi

Flutter + Firebase + GetX ile gelistirilmis modern borc/alacak takip uygulamasi.

---

## Kurulum Adimlari

### 1. Gereksinimler
- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Firebase hesabi
- VS Code + Flutter extension

### 2. Firebase Projesi Olusturma

1. [Firebase Console](https://console.firebase.google.com)'a gidin
2. **Yeni proje olustur** > proje adini girin
3. **Authentication** > **Sign-in method** > **Email/Password**'u aktif edin
4. **Firestore Database** > **Create database** > Test modunda baslayin
5. Firestore kurallarini `firestore.rules` dosyasindan kopyalayin

### 3. FlutterFire CLI Kurulumu

```bash
# FlutterFire CLI yukle
dart pub global activate flutterfire_cli

# Projeyi Firebase'e bagla (proje klasoründeyken calistir)
flutterfire configure
```

Bu komut `lib/firebase_options.dart` dosyasini otomatik olusturur/gunceller.

### 4. Bagimliliklari Yukle

```bash
flutter pub get
```

### 5. Android Ayarlari

`android/app/build.gradle` dosyasinda `minSdk`'yi kontrol edin:
```gradle
defaultConfig {
    minSdk 21
}
```

`android/app/src/main/AndroidManifest.xml` dosyasina internet izni ekleyin:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

### 6. iOS Ayarlari (Mac icin)

`ios/Podfile` dosyasinda minimum iOS versiyonunu ayarlayin:
```ruby
platform :ios, '13.0'
```

### 7. Uygulamayi Calistir

```bash
flutter run
```

---

## Proje Yapisi

```
lib/
├── core/
│   ├── constants/     # AppConstants, AppStrings
│   ├── routes/        # AppRoutes, AppPages
│   ├── theme/         # AppTheme, AppColors, AppTextStyles
│   ├── utils/         # AppBindings, Validators
│   └── widgets/       # AppButton, AppCard, AppTextField
├── data/
│   ├── models/        # UserModel, CafeModel
│   ├── repositories/  # (sonraki asama)
│   └── services/      # AuthService, FirestoreService
├── modules/
│   ├── auth/
│   │   ├── bindings/  # AuthBinding
│   │   ├── controllers/ # AuthController
│   │   ├── views/     # LoginView, RegisterView...
│   │   └── widgets/   # AuthFormHeader, AuthFooterLink
│   ├── home/          # UserHomeView, CafeHomeView
│   └── splash/        # SplashView
├── firebase_options.dart
└── main.dart
```

## Firestore Yapisi

```
users/
  {uid}/
    uid: string
    name: string
    username: string
    email: string
    phone: string
    accountType: "user"
    createdAt: timestamp

cafes/
  {uid}/
    uid: string
    name: string
    username: string
    email: string
    phone: string
    accountType: "cafe"
    createdAt: timestamp
```

## Ozellikler (Bu Asama)

- [x] Splash ekrani (oturum kontrolu ile)
- [x] Hesap tipi secimi (Kullanici / Kafe)
- [x] Kullanici kayit / giris
- [x] Kafe kayit / giris
- [x] Sifre sifirlama
- [x] Firebase Authentication
- [x] Firestore kullanici kaydi
- [x] GetX state management ve routing
- [x] Form validasyonu
- [x] Hata yonetimi

## Sonraki Asama

- [ ] Borc/alacak ekleme
- [ ] Musteri yonetimi (Kafe)
- [ ] Bildirimler (FCM)
- [ ] OCR ile fis okuma
- [ ] Ozet ve istatistikler
