# OCR Receipt System - Testing Guide

## Unit Tests

### OCR Service Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:borctakip/data/services/ocr_service.dart';

void main() {
  group('OcrService', () {
    late OcrService ocrService;

    setUp(() {
      ocrService = OcrService();
    });

    tearDown(() {
      ocrService.dispose();
    });

    group('Amount Extraction', () {
      test('Extract amount from standard TL format', () {
        final text = 'Kahvaltı 120 TL';
        final amount = ocrService._extractAmount(text);
        expect(amount, equals(120.0));
      });

      test('Extract amount with Turkish Lira symbol', () {
        final text = 'Yemek 150 ₺';
        final amount = ocrService._extractAmount(text);
        expect(amount, equals(150.0));
      });

      test('Extract decimal amount', () {
        final text = 'Ürün 99.99 TL';
        final amount = ocrService._extractAmount(text);
        expect(amount, equals(99.99));
      });

      test('Extract comma-separated amount', () {
        final text = 'Hizmet 199,50 TL';
        final amount = ocrService._extractAmount(text);
        expect(amount, equals(199.50));
      });

      test('Return null for invalid amount', () {
        final text = 'Fatura detayı görüntüle';
        final amount = ocrService._extractAmount(text);
        expect(amount, isNull);
      });
    });

    group('Description Extraction', () {
      test('Extract first non-numeric line as description', () {
        final text = 'Kahve\n120 TL\nToplam: 120';
        final description = ocrService._extractDescription(text);
        expect(description, equals('Kahve'));
      });

      test('Skip empty lines', () {
        final text = '\n\nYemek\n100 TL';
        final description = ocrService._extractDescription(text);
        expect(description, equals('Yemek'));
      });

      test('Truncate long descriptions', () {
        final text = 'A' * 100 + '\n100 TL';
        final description = ocrService._extractDescription(text);
        expect(description?.length, lessThanOrEqualTo(50));
      });
    });

    group('OCR Result Validation', () {
      test('Valid result with amount and description', () {
        final result = OcrResult(
          amount: 120.0,
          description: 'Kahve',
          rawText: 'Kahve 120 TL',
        );
        expect(result.isValid, isTrue);
      });

      test('Invalid result with null amount', () {
        final result = OcrResult(
          amount: null,
          description: 'Kahve',
          rawText: 'Kahve TL',
        );
        expect(result.isValid, isFalse);
      });

      test('Invalid result with zero amount', () {
        final result = OcrResult(
          amount: 0,
          description: 'Kahve',
          rawText: 'Kahve 0 TL',
        );
        expect(result.isValid, isFalse);
      });
    });
  });
}
```

### Receipt Model Tests

```dart
void main() {
  group('ReceiptModel', () {
    test('Create receipt from Firestore document', () {
      final data = {
        'createdBy': 'user1',
        'amount': 120.0,
        'description': 'Kahve',
        'status': 'pending',
        'participants': ['user1', 'user2'],
        'createdAt': Timestamp.now(),
      };

      final doc = MockDocumentSnapshot(data);
      final receipt = ReceiptModel.fromFirestore(doc);

      expect(receipt.amount, equals(120.0));
      expect(receipt.description, equals('Kahve'));
      expect(receipt.status, equals('pending'));
    });

    test('Convert receipt to Firestore map', () {
      final receipt = ReceiptModel(
        id: 'receipt1',
        createdBy: 'user1',
        amount: 120.0,
        description: 'Kahve',
        createdAt: DateTime.now(),
        participants: ['user1', 'user2'],
      );

      final data = receipt.toFirestore();

      expect(data['amount'], equals(120.0));
      expect(data['description'], equals('Kahve'));
      expect(data['participants'], equals(['user1', 'user2']));
    });

    test('Copy receipt with updated fields', () {
      final receipt = ReceiptModel(
        id: 'receipt1',
        createdBy: 'user1',
        amount: 120.0,
        description: 'Kahve',
        createdAt: DateTime.now(),
        participants: ['user1', 'user2'],
      );

      final updated = receipt.copyWith(
        status: 'approved',
        amount: 150.0,
      );

      expect(updated.status, equals('approved'));
      expect(updated.amount, equals(150.0));
      expect(updated.description, equals('Kahve'));
    });
  });
}
```

### Repository Tests

```dart
void main() {
  group('ReceiptRepository', () {
    late ReceiptRepository repository;
    late MockFirebaseFirestore mockFirestore;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      repository = ReceiptRepository(mockFirestore);
    });

    test('Create receipt successfully', () async {
      final receipt = ReceiptModel(
        id: 'receipt1',
        createdBy: 'user1',
        amount: 120.0,
        description: 'Kahve',
        createdAt: DateTime.now(),
        participants: ['user1', 'user2'],
      );

      final result = await repository.createReceipt(receipt);

      expect(result.id, isNotEmpty);
      expect(result.amount, equals(120.0));
    });

    test('Get user receipts', () async {
      mockFirestore.mockGetReceipts([
        {'id': '1', 'amount': 120.0},
        {'id': '2', 'amount': 150.0},
      ]);

      final receipts = await repository.getUserReceipts('user1');

      expect(receipts.length, equals(2));
      expect(receipts[0].amount, equals(120.0));
    });

    test('Handle repository exception', () async {
      mockFirestore.mockError = Exception('Network error');

      expect(
        () => repository.getUserReceipts('user1'),
        throwsA(isA<ReceiptRepositoryException>()),
      );
    });
  });
}
```

## Widget Tests

### Receipt Capture Screen Tests

```dart
void main() {
  group('ReceiptCaptureScreen', () {
    testWidgets('Display initial state with camera and gallery buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: ReceiptCaptureScreen(),
          bindings: [ReceiptBinding()],
        ),
      );

      expect(find.text('Kamera ile Çek'), findsOneWidget);
      expect(find.text('Galeriden Seç'), findsOneWidget);
    });

    testWidgets('Display OCR result after image selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: ReceiptCaptureScreen(),
          bindings: [ReceiptBinding()],
        ),
      );

      // Simulate image selection
      final controller = Get.find<ReceiptController>();
      controller.ocrResult.value = OcrResult(
        amount: 120.0,
        description: 'Kahve',
        rawText: 'Kahve 120 TL',
      );
      controller.amountController.text = '120.0';
      controller.descriptionController.text = 'Kahve';

      await tester.pumpAndSettle();

      expect(find.text('120.0'), findsWidgets);
      expect(find.text('Kahve'), findsWidgets);
    });

    testWidgets('Show error message for invalid receipt',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: ReceiptCaptureScreen(),
          bindings: [ReceiptBinding()],
        ),
      );

      final controller = Get.find<ReceiptController>();
      controller.errorMessage.value = 'Tutar geçersiz';

      await tester.pumpAndSettle();

      expect(find.text('Tutar geçersiz'), findsOneWidget);
    });
  });
}
```

### Receipt Approvals Screen Tests

```dart
void main() {
  group('ReceiptApprovalsScreen', () {
    testWidgets('Display empty state when no pending approvals',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: ReceiptApprovalsScreen(),
          bindings: [ReceiptBinding()],
        ),
      );

      expect(find.text('Onay bekleyen fiş yok'), findsOneWidget);
    });

    testWidgets('Display approval cards with approve/reject buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: ReceiptApprovalsScreen(),
          bindings: [ReceiptBinding()],
        ),
      );

      final controller = Get.find<ReceiptController>();
      controller.pendingApprovals.value = [
        ReceiptApproval(
          id: 'approval1',
          createdBy: 'user1',
          approverId: 'user2',
          receiptId: 'receipt1',
          createdAt: DateTime.now(),
        ),
      ];

      await tester.pumpAndSettle();

      expect(find.text('Onayla'), findsOneWidget);
      expect(find.text('Reddet'), findsOneWidget);
    });

    testWidgets('Approve receipt on button tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: ReceiptApprovalsScreen(),
          bindings: [ReceiptBinding()],
        ),
      );

      final controller = Get.find<ReceiptController>();
      controller.pendingApprovals.value = [
        ReceiptApproval(
          id: 'approval1',
          createdBy: 'user1',
          approverId: 'user2',
          receiptId: 'receipt1',
          createdAt: DateTime.now(),
        ),
      ];

      await tester.pumpAndSettle();

      await tester.tap(find.text('Onayla'));
      await tester.pumpAndSettle();

      // Verify approval was called
      expect(controller.isLoading.value, isFalse);
    });
  });
}
```

## Integration Tests

```dart
void main() {
  group('Receipt System Integration', () {
    testWidgets('Complete receipt workflow', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Navigate to receipt capture
      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle();

      expect(find.byType(ReceiptCaptureScreen), findsOneWidget);

      // Simulate image selection
      await tester.tap(find.text('Kamera ile Çek'));
      await tester.pumpAndSettle();

      // Verify OCR result
      expect(find.byType(TextField), findsWidgets);

      // Fill form
      await tester.enterText(find.byType(TextField).first, '120.0');
      await tester.enterText(find.byType(TextField).last, 'Kahve');

      // Submit
      await tester.tap(find.text('Gönder'));
      await tester.pumpAndSettle();

      // Verify success
      expect(find.byType(ReceiptHistoryScreen), findsOneWidget);
    });
  });
}
```

## Performance Tests

```dart
void main() {
  group('Receipt Performance', () {
    test('OCR processing time under 5 seconds', () async {
      final ocrService = OcrService();
      final imageFile = File('test_receipt.jpg');

      final stopwatch = Stopwatch()..start();
      await ocrService.recognizeText(imageFile);
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });

    test('Load 100 receipts in reasonable time', () async {
      final repository = ReceiptRepository(FirebaseFirestore.instance);

      final stopwatch = Stopwatch()..start();
      await repository.getUserReceipts('user1');
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(3000));
    });
  });
}
```

## Test Coverage

```bash
# Run tests with coverage
flutter test --coverage

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html

# View coverage
open coverage/html/index.html
```

## Mocking Strategy

### Mock Firestore

```dart
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {
  Map<String, List<Map<String, dynamic>>> collections = {};

  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    return MockCollectionReference(collections[path] ?? []);
  }
}
```

### Mock Firebase Storage

```dart
class MockFirebaseStorage extends Mock implements FirebaseStorage {
  @override
  Reference ref(String path) {
    return MockReference();
  }
}
```

## Running Tests

```bash
# All tests
flutter test

# Specific test file
flutter test test/services/ocr_service_test.dart

# Watch mode
flutter test --watch

# With coverage
flutter test --coverage

# Generate HTML report
flutter test --coverage && genhtml coverage/lcov.info -o coverage/html
```

## CI/CD Integration

```yaml
# .github/workflows/test.yml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run tests
        run: flutter test --coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
```

## Test Checklist

- [ ] OCR amount extraction tests
- [ ] OCR description extraction tests  
- [ ] Receipt model serialization tests
- [ ] Repository CRUD operations tests
- [ ] Permission handling tests
- [ ] Error handling tests
- [ ] Validation tests
- [ ] Widget UI tests
- [ ] Navigation tests
- [ ] Integration workflow tests
- [ ] Performance tests
- [ ] Memory leak tests

## Debugging Tips

1. **Enable verbose logging**:
   ```bash
   flutter test -v
   ```

2. **Use debugPrintBeginFrame**:
   ```dart
   debugPrintBeginFrame = true;
   ```

3. **Check memory usage**:
   ```bash
   flutter test --trace-startup
   ```

4. **Mock Firebase locally**:
   ```dart
   setupCloudFirestoreMocks();
   ```
