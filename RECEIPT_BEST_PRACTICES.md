# OCR Receipt System - Best Practices & Optimization

## Performance Optimization

### 1. Image Optimization

**Before Processing:**
```dart
// Good: Compress image before OCR
Future<File> compressImage(File imageFile) async {
  final originalSize = imageFile.lengthSync();
  
  // Compress to 85% quality
  final compressed = await FlutterImageCompress.compressAndGetFile(
    imageFile.absolute.path,
    imageFile.absolute.path,
    quality: 85,
    format: CompressFormat.jpeg,
  );
  
  final compressedSize = compressed?.lengthSync() ?? 0;
  print('Compression: $originalSize -> $compressedSize bytes');
  
  return File(compressed?.path ?? imageFile.path);
}
```

### 2. Memory Management

**Proper Resource Cleanup:**
```dart
class OcrService {
  // Use singleton pattern
  static final OcrService _instance = OcrService._internal();
  
  factory OcrService() {
    return _instance;
  }
  
  OcrService._internal();
  
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  // Always dispose
  @override
  void dispose() {
    textRecognizer.close();
  }
}

// Usage with GetX
@override
void onClose() {
  _ocrService.dispose(); // Always cleanup
  super.onClose();
}
```

### 3. Caching OCR Results

**Implement Smart Caching:**
```dart
class OcrCacheService {
  static const String _cachePath = 'ocr_cache';
  
  Future<OcrResult?> getCachedResult(String imageHash) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('ocr_$imageHash');
      
      if (cached != null) {
        return OcrResult.fromJson(jsonDecode(cached));
      }
    } catch (_) {}
    
    return null;
  }
  
  Future<void> cacheResult(String imageHash, OcrResult result) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(
        'ocr_$imageHash',
        jsonEncode(result.toJson()),
      );
    } catch (_) {}
  }
}

// Compute image hash
String computeImageHash(File file) {
  final bytes = file.readAsBytesSync();
  return sha256.convert(bytes).toString();
}
```

### 4. Batch Operations

**Batch Multiple Receipts:**
```dart
Future<void> submitMultipleReceipts(
  List<ReceiptModel> receipts,
  String userId,
) async {
  try {
    final batch = _firestore.batch();
    
    for (final receipt in receipts) {
      final docRef = _firestore.collection('receipts').doc(receipt.id);
      batch.set(docRef, receipt.toFirestore());
    }
    
    await batch.commit();
  } catch (e) {
    throw Exception('Batch operation failed: $e');
  }
}
```

## Error Handling Best Practices

### 1. Comprehensive Error Handling

```dart
Future<OcrResult> recognizeTextSafely(File imageFile) async {
  try {
    // Validate input
    if (!imageFile.existsSync()) {
      throw ImageException('Dosya bulunamadı');
    }
    
    if (imageFile.lengthSync() > 10 * 1024 * 1024) {
      throw ImageException('Resim çok büyük (max 10MB)');
    }
    
    return await recognizeText(imageFile);
    
  } on SocketException catch (e) {
    throw OcrException('Ağ bağlantısı hatası: ${e.message}');
  } on TimeoutException catch (_) {
    throw OcrException('İşlem zaman aşımına uğradı');
  } on OcrException catch (e) {
    rethrow;
  } catch (e) {
    throw OcrException('Bilinmeyen hata: $e');
  }
}
```

### 2. User-Friendly Error Messages

```dart
String mapErrorToUserMessage(Exception error) {
  if (error is OcrException) {
    return 'Fiş taranırken hata: ${error.message}';
  } else if (error is PermissionException) {
    return 'Uygulama için gerekli izinler verilmedi';
  } else if (error is ImageException) {
    return 'Resim işlenirken sorun oluştu';
  } else if (error is ReceiptRepositoryException) {
    return 'Veritabanı işlemi başarısız oldu';
  } else {
    return 'Bir hata oluştu. Lütfen tekrar deneyin.';
  }
}
```

## Code Quality & Maintenance

### 1. Null Safety

```dart
// ✅ Good: Proper null safety
class ReceiptModel {
  final String id;
  final double amount;
  final String? description; // Optional
  final DateTime? approvedAt;
  
  ReceiptModel({
    required this.id,
    required this.amount,
    this.description,
    this.approvedAt,
  });
}

// ❌ Bad: Unsafe null handling
String description = model.description!; // Crash if null
```

### 2. Constants & Configuration

```dart
class OcrConstants {
  // Amount extraction
  static const double minAmount = 0.01;
  static const double maxAmount = 999999.99;
  
  // Description
  static const int minDescriptionLength = 2;
  static const int maxDescriptionLength = 500;
  
  // Image
  static const int maxImageSizeMB = 10;
  static const int imageQuality = 85;
  
  // Timeouts
  static const Duration ocrTimeout = Duration(seconds: 30);
  static const Duration networkTimeout = Duration(seconds: 15);
  
  // Patterns
  static const String amountPatternTL = r'(\d+[.,]\d{2})\s*(?:TL|₺)';
  static const String amountPatternReverse = r'(?:TL|₺)\s*(\d+[.,]\d{2})';
}
```

### 3. Logging & Monitoring

```dart
class ReceiptLogger {
  static void logOcrSuccess(OcrResult result) {
    developer.log(
      'OCR Success',
      name: 'receipt.ocr',
      level: 800,
      error: {
        'amount': result.amount,
        'confidence': result.confidence,
      },
    );
  }
  
  static void logError(String operation, Exception error) {
    developer.log(
      'Receipt Error',
      name: 'receipt.error',
      level: 900,
      error: error,
      stackTrace: StackTrace.current,
    );
  }
}
```

## Security Best Practices

### 1. Input Validation

```dart
bool validateReceiptData(ReceiptModel receipt) {
  // Validate amount
  if (receipt.amount <= 0 || receipt.amount > 999999.99) {
    return false;
  }
  
  // Validate description
  if (receipt.description.isEmpty || 
      receipt.description.length > 500) {
    return false;
  }
  
  // Validate UIDs
  if (receipt.createdBy.isEmpty || 
      receipt.participants.isEmpty) {
    return false;
  }
  
  // Check no SQL injection patterns
  if (receipt.description.contains(RegExp(r'[<>\"\'%;()&+]'))) {
    return false;
  }
  
  return true;
}
```

### 2. Firestore Security

```javascript
// Firestore Rules - Already updated
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(uid) {
      return isAuthenticated() && request.auth.uid == uid;
    }

    match /receipts/{receiptId} {
      // Only owner can read/write unless participant
      allow read: if isAuthenticated()
        && (resource.data.createdBy == request.auth.uid
          || request.auth.uid in resource.data.participants);
      
      // Only owner can create valid receipts
      allow create: if isAuthenticated()
        && request.resource.data.createdBy == request.auth.uid
        && request.resource.data.amount > 0
        && request.resource.data.amount < 1000000;
      
      // Can't change approved receipts
      allow update: if isAuthenticated()
        && resource.data.createdBy == request.auth.uid
        && resource.data.status != 'approved';
    }
  }
}
```

## Testing Best Practices

### 1. Unit Test Template

```dart
void main() {
  group('ReceiptService', () {
    late ReceiptService service;

    setUp(() {
      service = ReceiptService();
    });

    tearDown(() {
      service.dispose();
    });

    test('should extract amount correctly', () {
      const input = 'Kahve 120 TL';
      final result = service.extractAmount(input);
      
      expect(result, equals(120.0));
    });

    test('should handle error gracefully', () {
      expect(
        () => service.processInvalidData(),
        throwsA(isA<ReceiptException>()),
      );
    });
  });
}
```

### 2. Widget Test Template

```dart
void main() {
  group('ReceiptCaptureScreen', () {
    testWidgets('should display loading state', 
        (WidgetTester tester) async {
      await tester.pumpWidget(_createTestWidget());
      
      // Simulate loading
      final controller = Get.find<ReceiptController>();
      controller.isLoading.value = true;
      
      await tester.pumpAndSettle();
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
```

## Production Deployment Checklist

- [ ] All tests passing (100% critical paths)
- [ ] Code coverage > 80%
- [ ] No memory leaks detected
- [ ] Firestore rules reviewed & tested
- [ ] Error messages user-friendly (Turkish)
- [ ] Android permissions configured
- [ ] iOS permissions configured
- [ ] App signing certificates valid
- [ ] Crash reporting configured (Firebase Crashlytics)
- [ ] Performance monitoring enabled
- [ ] Analytics integrated
- [ ] User privacy policy updated
- [ ] Offline mode working
- [ ] Network timeout handling
- [ ] Dark mode tested
- [ ] Accessibility tested (a11y)
- [ ] RTL language support (if needed)

## Performance Metrics

### Expected Performance

| Operation | Target | Actual |
|-----------|--------|--------|
| OCR Processing | < 5s | - |
| Image Upload | < 10s | - |
| Firestore Write | < 2s | - |
| Receipt Load | < 2s | - |
| Search Query | < 1s | - |

### Monitoring

```dart
class ReceiptMetrics {
  static void trackOcrPerformance(Duration duration) {
    FirebaseAnalytics.instance.logEvent(
      name: 'ocr_performance',
      parameters: {
        'duration_ms': duration.inMilliseconds,
        'status': duration.inSeconds < 5 ? 'good' : 'slow',
      },
    );
  }
  
  static void trackReceiptCreation() {
    FirebaseAnalytics.instance.logEvent(
      name: 'receipt_created',
    );
  }
}
```

## Optimization Techniques

### 1. Lazy Loading

```dart
// Load receipts in batches
Future<List<ReceiptModel>> loadMoreReceipts() async {
  final lastReceipt = _receipts.last;
  
  return _firestore
      .collection('receipts')
      .where('createdBy', isEqualTo: userId)
      .startAfter([lastReceipt.createdAt])
      .limit(20)
      .get()
      .then((snapshot) => 
          snapshot.docs.map(ReceiptModel.fromFirestore).toList());
}
```

### 2. Indexed Queries

```javascript
// Firestore composite indexes
// firestore.indexes.json
{
  "indexes": [
    {
      "collectionGroup": "receipts",
      "queryScope": "Collection",
      "fields": [
        {"fieldPath": "createdBy", "order": "ASCENDING"},
        {"fieldPath": "createdAt", "order": "DESCENDING"}
      ]
    },
    {
      "collectionGroup": "receipts",
      "queryScope": "Collection",
      "fields": [
        {"fieldPath": "status", "order": "ASCENDING"},
        {"fieldPath": "participants", "order": "ASCENDING"},
        {"fieldPath": "createdAt", "order": "DESCENDING"}
      ]
    }
  ]
}
```

### 3. Real-time Optimization

```dart
// Use snapshots wisely
Stream<List<ReceiptModel>> watchPendingReceipts(String userId) {
  return _firestore
      .collection('receipts')
      .where('status', isEqualTo: 'pending')
      .where('participants', arrayContains: userId)
      .orderBy('createdAt', descending: true)
      .limit(50) // Limit results
      .snapshots()
      .map((snapshot) => 
          snapshot.docs.map(ReceiptModel.fromFirestore).toList());
}
```

## Resources

- [Flutter Best Practices](https://flutter.dev/docs/testing/best-practices)
- [Firebase Security Rules](https://firebase.google.com/docs/firestore/security/start)
- [ML Kit Documentation](https://developers.google.com/ml-kit/vision/text-recognition)
- [GetX Documentation](https://github.com/jonataslaw/getx/wiki)
- [Dart Performance](https://dart.dev/guides/performance)
