import 'dart:io';
import '../models/receipt_model.dart';
import '../repositories/receipt_repository.dart';
import '../services/ocr_service.dart';
import '../services/image_service.dart';

class ReceiptProcessingService {
  final OcrService _ocrService;
  final ImageService _imageService;
  final ReceiptRepository _receiptRepository;

  ReceiptProcessingService({
    required OcrService ocrService,
    required ImageService imageService,
    required ReceiptRepository receiptRepository,
  })  : _ocrService = ocrService,
        _imageService = imageService,
        _receiptRepository = receiptRepository;

  /// Captures image and extracts receipt data
  Future<OcrResult> captureAndProcessReceipt() async {
    final imageFile = await _imageService.captureReceiptImage();
    if (imageFile == null) {
      throw ProcessingException('Resim seçilmedi');
    }
    return _processReceiptImage(imageFile);
  }

  /// Picks image from gallery and extracts receipt data
  Future<OcrResult> pickAndProcessReceipt() async {
    final imageFile = await _imageService.pickReceiptImage();
    if (imageFile == null) {
      throw ProcessingException('Resim seçilmedi');
    }
    return _processReceiptImage(imageFile);
  }

  /// Processes an already-captured image
  Future<OcrResult> _processReceiptImage(File imageFile) async {
    try {
      final result = await _ocrService.recognizeText(imageFile);
      if (!result.isValid) {
        throw ProcessingException(
          'Fiş verisi geçersiz. Lütfen net bir fotoğraf çekiniz.',
        );
      }
      return result;
    } catch (e) {
      throw ProcessingException('Fiş işlenirken hata: $e');
    }
  }

  /// Saves receipt to Firestore
  Future<ReceiptModel> saveReceipt(ReceiptModel receipt) async {
    try {
      return await _receiptRepository.createReceipt(receipt);
    } catch (e) {
      throw ProcessingException('Fiş kaydedilemedi: $e');
    }
  }

  /// Gets user's receipts
  Future<List<ReceiptModel>> getUserReceipts(String userId) async {
    try {
      return await _receiptRepository.getUserReceipts(userId);
    } catch (e) {
      throw ProcessingException('Fişler getirilemedi: $e');
    }
  }

  /// Gets pending receipts for user
  Future<List<ReceiptModel>> getPendingReceipts(String userId) async {
    try {
      return await _receiptRepository.getPendingReceipts(userId);
    } catch (e) {
      throw ProcessingException('Bekleyen fişler getirilemedi: $e');
    }
  }

  /// Validates receipt data
  bool validateReceiptData({
    required double amount,
    required String description,
  }) {
    if (amount <= 0) {
      throw ValidationException('Tutar 0 ile büyük olmalıdır');
    }
    if (description.trim().isEmpty) {
      throw ValidationException('Açıklama boş olamaz');
    }
    if (description.length > 500) {
      throw ValidationException('Açıklama 500 karakterden fazla olamaz');
    }
    return true;
  }

  void dispose() {
    _ocrService.dispose();
  }
}

class ProcessingException implements Exception {
  final String message;
  ProcessingException(this.message);

  @override
  String toString() => message;
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);

  @override
  String toString() => message;
}
