# Borcum - Borç/Alacak Takip Uygulaması

Flutter + Firebase + GetX ile geliştirilmiş modern borç/alacak takip uygulaması.

**Hackathon 2026 Projesi**

---

## Teknoloji Stack

| Frontend | Backend |
|---|---|
| Flutter SDK >= 3.0.0 | Firebase Authentication |
| Dart SDK >= 3.0.0 | Firestore Database |
| GetX (State Management) | Firebase Cloud Messaging |
| GetX (Routing) | FlutterFire CLI |

---

## Kurulum Adımları

### 1. Gereksinimler

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Firebase hesabı
- VS Code + Flutter extension

### 2. Firebase Projesi Oluşturma

1. [Firebase Console](https://console.firebase.google.com)'a gidin
2. **Yeni proje oluştur** > proje adını girin
3. **Authentication** > **Sign-in method** > **Email/Password**'u aktif edin
4. **Firestore Database** > **Create database** > Test modunda başlayın
5. Firestore kurallarını `firestore.rules` dosyasından kopyalayın

### 3. FlutterFire CLI Kurulumu

```bash
# FlutterFire CLI yükle
dart pub global activate flutterfire_cli

# Projeyi Firebase'e bağla (proje klasöründeyken çalıştır)
flutterfire configure
```

> Not: Bu komut `lib/firebase_options.dart` dosyasını otomatik oluşturur ve günceller.

### 4. Bağımlılıkları Yükle

```bash
flutter pub get
```

### 5. Android Ayarları

`android/app/build.gradle` dosyasında `minSdk` değerini kontrol edin:

```gradle
defaultConfig {
    minSdk 21
}
```

`android/app/src/main/AndroidManifest.xml` dosyasına internet izni ekleyin:

```xml

```

### 6. iOS Ayarları (Mac için)

`ios/Podfile` dosyasında minimum iOS versiyonunu ayarlayın:

```ruby
platform :ios, '13.0'
```

### 7. Uygulamayı Çalıştır

```bash
flutter run
```

---

## Proje Yapısı
lib/
├── core/
│   ├── constants/     # AppConstants, AppStrings
│   ├── routes/        # AppRoutes, AppPages
│   ├── theme/         # AppTheme, AppColors, AppTextStyles
│   ├── utils/         # AppBindings, Validators
│   └── widgets/       # AppButton, AppCard, AppTextField
├── data/
│   ├── models/        # UserModel, CafeModel
│   ├── repositories/  # (sonraki aşama)
│   └── services/      # AuthService, FirestoreService
├── modules/
│   ├── auth/
│   │   ├── bindings/    # AuthBinding
│   │   ├── controllers/ # AuthController
│   │   ├── views/       # LoginView, RegisterView...
│   │   └── widgets/     # AuthFormHeader, AuthFooterLink
│   ├── home/            # UserHomeView, CafeHomeView
│   └── splash/          # SplashView
├── firebase_options.dart
└── main.dart

---

## Firestore Veri Yapısı
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

---

## Özellikler

### Mevcut Sürüm

- [x] Splash ekranı (oturum kontrolü ile)
- [x] Hesap tipi seçimi (Kullanıcı / Kafe)
- [x] Kullanıcı kayıt / giriş
- [x] Kafe kayıt / giriş
- [x] Şifre sıfırlama
- [x] Firebase Authentication
- [x] Firestore kullanıcı kaydı
- [x] GetX state management ve routing
- [x] Form validasyonu
- [x] Hata yönetimi

### Planlanan Geliştirmeler

- [ ] Borç/alacak ekleme
- [ ] Müşteri yönetimi (Kafe)
- [ ] Bildirimler (FCM)
- [ ] OCR ile fiş okuma
- [ ] Özet ve istatistikler

---

## Takım

Bu proje Hackathon 2026 kapsamında geliştirilmiştir.

| İsim |
|Aynur KARAKAYA|
| Özlem Nur Dinç |
| Derya Arslan |
