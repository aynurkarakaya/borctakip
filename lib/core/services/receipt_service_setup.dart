import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../data/repositories/receipt_repository.dart';
import '../data/services/ocr_service.dart';
import '../data/services/image_service.dart';
import '../data/services/receipt_processing_service.dart';
import '../modules/receipt/controllers/receipt_controller.dart';

class ReceiptServiceSetup {
  static void setupServices() {
    // Firebase
    final firestore = FirebaseFirestore.instance;

    // Services
    Get.put<OcrService>(OcrService());
    Get.put<ImageService>(ImageService());

    // Repositories
    Get.put<ReceiptRepository>(ReceiptRepository(firestore));
    Get.put<ReceiptApprovalRepository>(ReceiptApprovalRepository(firestore));

    // Processing Service
    Get.put<ReceiptProcessingService>(
      ReceiptProcessingService(
        ocrService: Get.find<OcrService>(),
        imageService: Get.find<ImageService>(),
        receiptRepository: Get.find<ReceiptRepository>(),
      ),
    );

    // Controllers
    Get.put<ReceiptController>(
      ReceiptController(
        receiptRepository: Get.find<ReceiptRepository>(),
        ocrService: Get.find<OcrService>(),
        imageService: Get.find<ImageService>(),
        firestore: firestore,
      ),
    );
  }

  static void cleanupServices() {
    Get.delete<ReceiptController>();
    Get.delete<ReceiptProcessingService>();
    Get.delete<ReceiptRepository>();
    Get.delete<ReceiptApprovalRepository>();
    Get.delete<OcrService>();
    Get.delete<ImageService>();
  }
}
