import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/repositories/receipt_repository.dart';
import '../../data/services/ocr_service.dart';
import '../../data/services/image_service.dart';
import '../../data/services/receipt_processing_service.dart';
import '../controllers/receipt_controller.dart';

class ReceiptBinding extends Bindings {
  @override
  void dependencies() {
    // Firebase
    final firestore = FirebaseFirestore.instance;

    // Services
    Get.lazyPut<OcrService>(() => OcrService());
    Get.lazyPut<ImageService>(() => ImageService());

    // Repositories
    Get.lazyPut<ReceiptRepository>(() => ReceiptRepository(firestore));
    Get.lazyPut<ReceiptApprovalRepository>(
      () => ReceiptApprovalRepository(firestore),
    );

    // Processing Service
    Get.lazyPut<ReceiptProcessingService>(
      () => ReceiptProcessingService(
        ocrService: Get.find<OcrService>(),
        imageService: Get.find<ImageService>(),
        receiptRepository: Get.find<ReceiptRepository>(),
      ),
    );

    // Controllers
    Get.lazyPut<ReceiptController>(
      () => ReceiptController(
        receiptRepository: Get.find<ReceiptRepository>(),
        ocrService: Get.find<OcrService>(),
        imageService: Get.find<ImageService>(),
        firestore: firestore,
      ),
    );
  }
}
