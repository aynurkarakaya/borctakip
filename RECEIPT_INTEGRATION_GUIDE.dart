import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'lib/modules/receipt/bindings/receipt_binding.dart';
import 'lib/modules/receipt/screens/receipt_capture_screen.dart';
import 'lib/modules/receipt/screens/receipt_confirmation_screen.dart';
import 'lib/modules/receipt/screens/receipt_approvals_screen.dart';
import 'lib/modules/receipt/screens/receipt_history_screen.dart';

/// Example integration guide for OCR Receipt System
/// 
/// Add these routes to your GetMaterialApp in main.dart

class ReceiptIntegration {
  /// GetPages for Receipt Routes
  static final List<GetPage> receiptRoutes = [
    GetPage(
      name: '/receipt/capture',
      page: () => const ReceiptCaptureScreen(),
      binding: ReceiptBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/receipt/confirmation',
      page: () => const ReceiptConfirmationScreen(),
      binding: ReceiptBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/receipt/approvals',
      page: () => const ReceiptApprovalsScreen(),
      binding: ReceiptBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/receipt/history',
      page: () => const ReceiptHistoryScreen(),
      binding: ReceiptBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}

/// Example main.dart integration
/*
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Borcum',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
      getPages: [
        // Existing routes...
        
        // Receipt routes
        ...ReceiptIntegration.receiptRoutes,
      ],
    );
  }
}
*/

/// Example usage in screens

class ExampleHomeScreen extends StatelessWidget {
  const ExampleHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Borcum'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => Get.toNamed('/receipt/approvals'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add Receipt Button
            ElevatedButton.icon(
              onPressed: () => Get.toNamed('/receipt/capture'),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Fiş Ekle'),
            ),
            const SizedBox(height: 16),

            // View History Button
            ElevatedButton.icon(
              onPressed: () => Get.toNamed('/receipt/history'),
              icon: const Icon(Icons.history),
              label: const Text('Fiş Geçmişi'),
            ),
            const SizedBox(height: 16),

            // View Approvals Button
            ElevatedButton.icon(
              onPressed: () => Get.toNamed('/receipt/approvals'),
              icon: const Icon(Icons.check_circle),
              label: const Text('Bekleyen Onaylar'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example programmatic navigation
/*
class ExampleNavigationUsage {
  static void navigateToCapture() {
    Get.toNamed('/receipt/capture');
  }

  static void navigateToConfirmation() {
    Get.toNamed('/receipt/confirmation');
  }

  static void navigateToApprovals() {
    Get.toNamed('/receipt/approvals');
  }

  static void navigateToHistory() {
    Get.toNamed('/receipt/history');
  }

  // With result handling
  static void captureAndHandle() async {
    final result = await Get.toNamed('/receipt/capture');
    
    if (result != null) {
      // Receipt created successfully
      print('Receipt created: $result');
    }
  }
}
*/

/// Example bottom navigation integration
class ExampleBottomNavigation extends StatefulWidget {
  const ExampleBottomNavigation({Key? key}) : super(key: key);

  @override
  State<ExampleBottomNavigation> createState() =>
      _ExampleBottomNavigationState();
}

class _ExampleBottomNavigationState extends State<ExampleBottomNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    // Home page
    ExampleHomeScreen(),
    // Receipt capture page
    ReceiptCaptureScreen(),
    // Receipt history page
    ReceiptHistoryScreen(),
    // Receipt approvals page
    ReceiptApprovalsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Anasayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_a_photo),
            label: 'Fiş Çek',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Geçmiş',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Onaylar',
          ),
        ],
      ),
    );
  }
}

/// Example with FloatingActionButton
class ExampleFABIntegration extends StatelessWidget {
  const ExampleFABIntegration({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Borcum'),
      ),
      body: const Center(
        child: Text('Ana sayfa'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.camera_alt),
        label: const Text('Fiş Ekle'),
        onPressed: () {
          Get.toNamed('/receipt/capture');
        },
      ),
    );
  }
}

/// Error handling example
/*
class ReceiptErrorHandler {
  static void handleError(String error) {
    Get.snackbar(
      'Hata',
      error,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  static void showPermissionError() {
    Get.dialog(
      AlertDialog(
        title: const Text('İzin Gerekli'),
        content: const Text('Kamera kullanmak için izin gereklidir'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              // Open app settings
            },
            child: const Text('Ayarlar'),
          ),
        ],
      ),
    );
  }
}
*/

/// Testing example
/*
void main() {
  group('Receipt Navigation', () {
    testWidgets('Navigate to receipt capture', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      
      expect(find.byType(ReceiptCaptureScreen), findsOneWidget);
    });

    testWidgets('Navigate back from receipt capture', 
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      
      await tester.pageBack();
      await tester.pumpAndSettle();
      
      expect(find.byType(ExampleHomeScreen), findsOneWidget);
    });
  });
}
*/
