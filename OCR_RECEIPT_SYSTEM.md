# OCR Receipt System - Borcum

Profesyonel OCR tabanlı fiş okuma sistemi Flutter Firebase uygulaması için.

## Features

✅ **OCR Text Recognition** - Google ML Kit ile yüksek doğruluk  
✅ **Automatic Amount Extraction** - Fiyatları regex ile otomatik çıkarma  
✅ **Camera Integration** - Cihaz kamerasından doğrudan fiş çekme  
✅ **Gallery Picker** - Galerideki fotoğrafları seçme  
✅ **Receipt Approvals** - Multi-party onay sistemi  
✅ **Group Expenses** - Grup harcamaları yönetimi  
✅ **Real-time Sync** - Firestore ile gerçek zamanlı senkronizasyon  
✅ **Error Handling** - Kapsamlı hata işleme  
✅ **Loading States** - Shimmer ve skeleton loading  
✅ **Dark Mode** - Tam dark mode desteği  
✅ **Android Permissions** - Kamera ve galeri izinleri  

## Architecture

```
lib/
├── data/
│   ├── models/
│   │   └── receipt_model.dart          # Receipt, OcrResult, ReceiptApproval
│   ├── services/
│   │   ├── ocr_service.dart            # Google ML Kit entegrasyonu
│   │   ├── image_service.dart          # Kamera ve galeri servisi
│   │   └── receipt_processing_service.dart  # Ortalama koordinasyon
│   └── repositories/
│       └── receipt_repository.dart     # Firestore operasyonları
├── modules/receipt/
│   ├── bindings/
│   │   └── receipt_binding.dart        # GetX dependency injection
│   ├── controllers/
│   │   └── receipt_controller.dart     # Business logic
│   └── screens/
│       ├── receipt_capture_screen.dart      # Fiş çekme/seçme
│       ├── receipt_confirmation_screen.dart # Onay ekranı
│       ├── receipt_approvals_screen.dart    # Onay bekleyen fişler
│       └── receipt_history_screen.dart      # Fiş geçmişi
└── core/
    ├── services/
    │   └── receipt_service_setup.dart  # Service setup
    └── widgets/
        └── receipt_widgets.dart        # Reusable components
```

## Setup

### 1. Dependencies (pubspec.yaml'da zaten mevcut)

```yaml
dependencies:
  google_mlkit_text_recognition: ^0.13.0
  image_picker: ^1.1.2
  permission_handler: ^11.3.1
  cloud_firestore: ^5.1.0
  get: ^4.6.6
  shimmer: ^3.0.0
```

### 2. Android Permissions

`AndroidManifest.xml`'de otomatik eklenir:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.INTERNET" />
```

### 3. Firestore Rules

```javascript
match /receipts/{receiptId} {
  allow read: if isAuthenticated()
    && (resource.data.createdBy == request.auth.uid
      || request.auth.uid in resource.data.participants);
  allow create: if isAuthenticated()
    && request.resource.data.createdBy == request.auth.uid
    && request.resource.data.amount > 0;
  allow update: if isAuthenticated()
    && resource.data.createdBy == request.auth.uid
    && resource.data.status != 'approved';
  allow delete: if isAuthenticated()
    && resource.data.createdBy == request.auth.uid;
}

match /receipt_approvals/{approvalId} {
  allow read: if isAuthenticated()
    && (resource.data.createdBy == request.auth.uid
      || resource.data.approverId == request.auth.uid);
  allow create: if isAuthenticated()
    && request.resource.data.createdBy == request.auth.uid;
  allow update: if isAuthenticated()
    && resource.data.approverId == request.auth.uid;
  allow delete: if false;
}
```

## Usage

### Setup in main.dart

```dart
import 'package:get/get.dart';
import 'lib/modules/receipt/bindings/receipt_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: MainScreen(),
      getPages: [
        GetPage(
          name: '/receipt/capture',
          page: () => ReceiptCaptureScreen(),
          binding: ReceiptBinding(),
        ),
        GetPage(
          name: '/receipt/confirmation',
          page: () => ReceiptConfirmationScreen(),
          binding: ReceiptBinding(),
        ),
        GetPage(
          name: '/receipt/approvals',
          page: () => ReceiptApprovalsScreen(),
          binding: ReceiptBinding(),
        ),
        GetPage(
          name: '/receipt/history',
          page: () => ReceiptHistoryScreen(),
          binding: ReceiptBinding(),
        ),
      ],
    );
  }
}
```

### Use ReceiptController

```dart
final controller = Get.find<ReceiptController>();

// Fiş çekme
await controller.captureReceiptImage();

// Galeriden seçme
await controller.pickReceiptImage();

// Fiş gönderme
controller.selectRecipient('userId', 'userName');
await controller.submitReceipt(currentUserId);

// Onay
await controller.approveReceipt(approvalId, receiptId);

// Reddetme
await controller.rejectReceipt(approvalId, receiptId);

// Fiş yükleme
await controller.loadUserReceipts(userId);
```

## Data Models

### ReceiptModel

```dart
class ReceiptModel {
  final String id;
  final String createdBy;        // Fiş gönderen
  final String? fromUserId;      // Borcu yapan (opsiyonel)
  final String? toUserId;        // Borcu alan
  final String? groupId;         // Grup ID (grup harcaması için)
  final double amount;           // Tutar (TL)
  final String description;      // Açıklama
  final String? imageUrl;        // Fiş fotoğrafı URL
  final String status;           // pending, approved, rejected
  final DateTime createdAt;
  final DateTime? approvedAt;
  final List<String> participants; // Ilgili kişiler
  final Map<String, dynamic>? ocrData; // OCR verisi
}
```

### OcrResult

```dart
class OcrResult {
  final double? amount;      // Çıkarılan tutar
  final String? description; // Çıkarılan açıklama
  final String rawText;      // Orijinal OCR metni
  final double confidence;   // Güven düzeyi (0.0-1.0)
  
  bool get isValid => amount != null && description != null && amount! > 0;
}
```

### ReceiptApproval

```dart
class ReceiptApproval {
  final String id;
  final String createdBy;    // Fiş gönderen
  final String approverId;   // Onay yapacak kişi
  final String receiptId;    // İlgili fiş
  final String status;       // pending, approved, rejected
  final DateTime createdAt;
  final DateTime? respondedAt;
}
```

## Services

### OcrService

```dart
class OcrService {
  // Resimdeki metni tanır
  Future<OcrResult> recognizeText(File imageFile) async;
  
  // Fiyat bulur (regex patterns)
  double? _extractAmount(String text);
  
  // Açıklama çıkarır
  String? _extractDescription(String text);
  
  // Kaynakları serbest bırakır
  Future<void> dispose() async;
}
```

### ImageService

```dart
class ImageService {
  // Kamera ile fiş çeker
  Future<File?> captureReceiptImage() async;
  
  // Galeriden fiş seçer
  Future<File?> pickReceiptImage() async;
  
  // Kamera izni kontrol eder
  Future<bool> hasCameraPermission() async;
  
  // Ayarlara yönlendirir
  Future<void> openAppSettings() async;
}
```

### ReceiptRepository

```dart
class ReceiptRepository {
  // Fiş oluşturur
  Future<ReceiptModel> createReceipt(ReceiptModel receipt);
  
  // Fiş günceller
  Future<void> updateReceipt(ReceiptModel receipt);
  
  // Kullanıcının fişlerini getirir
  Future<List<ReceiptModel>> getUserReceipts(String userId);
  
  // Bekleyen fişleri getirir
  Future<List<ReceiptModel>> getPendingReceipts(String userId);
  
  // Real-time stream
  Stream<List<ReceiptModel>> watchUserReceipts(String userId);
  Stream<List<ReceiptModel>> watchPendingReceipts(String userId);
}
```

## Error Handling

```dart
try {
  await controller.captureReceiptImage();
} catch (e) {
  if (e is OcrException) {
    // OCR hatası
  } else if (e is PermissionException) {
    // İzin hatası
  } else if (e is ImageException) {
    // Resim hatası
  } else if (e is ReceiptRepositoryException) {
    // Veritabanı hatası
  }
}
```

## Validation

```dart
// Fişi doğrulama
try {
  _controller.errorMessage.value = null;
  
  if (amount <= 0) {
    throw ValidationException('Tutar 0 ile büyük olmalıdır');
  }
  
  if (description.isEmpty) {
    throw ValidationException('Açıklama boş olamaz');
  }
  
  if (selectedRecipient == null && selectedGroup == null) {
    throw ValidationException('Lütfen alıcı seçiniz');
  }
} catch (e) {
  _controller.errorMessage.value = e.toString();
}
```

## OCR Amount Patterns

Sistem aşağıdaki fiyat formatlarını destekler:

- `120 TL` ✅
- `120TL` ✅
- `120 ₺` ✅
- `120₺` ✅
- `120.50 TL` ✅
- `120,50 TL` ✅
- `TL 120.50` ✅

## Performance Optimizations

✅ **Memory Management** - Explicit dispose() calls  
✅ **Lazy Loading** - Get.lazyPut() for dependencies  
✅ **Caching** - OCR results cached  
✅ **Async Operations** - Non-blocking operations  
✅ **Null Safety** - Complete null safety implementation  
✅ **Stream Optimization** - Efficient Firestore queries  

## Testing

```dart
// Unit Test Örneği
void main() {
  group('OcrService', () {
    late OcrService ocrService;
    
    setUp(() {
      ocrService = OcrService();
    });
    
    test('Extract amount from text', () {
      final result = ocrService._extractAmount('Kahve 120 TL');
      expect(result, equals(120.0));
    });
    
    test('Extract description from text', () {
      final result = ocrService._extractDescription('Kahve 120 TL');
      expect(result, equals('Kahve'));
    });
  });
}
```

## Dark Mode Support

Tüm ekranlar dark mode'ı destekler:

```dart
final isDark = Theme.of(context).brightness == Brightness.dark;

if (isDark) {
  // Dark colors
} else {
  // Light colors
}
```

## Production Checklist

- [x] OCR sistemi entegrasyonu
- [x] Kamera ve galeri entegrasyonu
- [x] Firestore integration
- [x] Error handling
- [x] Validation sistemi
- [x] Loading states
- [x] Android permissions
- [x] Null safety
- [x] Memory leak prevention
- [x] Firebase security rules
- [x] Dark mode support
- [x] Animasyonlar ve transitions
- [x] Skeleton loading
- [x] Shimmer effects

## Troubleshooting

### OCR Not Working

1. ML Kit models yüklü mü kontrol edin
2. İnternet bağlantısı kontrol edin
3. Model dosyaları çoklamış olabilir

### Permission Errors

1. Android 12+ için READ_MEDIA_IMAGES izni ekleyin
2. Kullanıcıya izin iste (permission_handler)
3. Ayarlardan manuel olarak izin ver

### Memory Issues

```dart
@override
void dispose() {
  _ocrService.dispose(); // ResourcesÜ serbest bırak
  controller.dispose();
  super.dispose();
}
```

## API Reference

Bkz. [API Documentation](./docs/API.md)

## License

© 2024 Borcum. Tüm hakları saklıdır.
