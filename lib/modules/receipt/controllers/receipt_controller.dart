import 'dart:io';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../data/models/receipt_model.dart';
import '../../../data/repositories/receipt_repository.dart';
import '../../../data/services/ocr_service.dart';
import '../../../data/services/image_service.dart';

class ReceiptController extends GetxController {
  final ReceiptRepository _receiptRepository;
  final OcrService _ocrService;
  final ImageService _imageService;
  final FirebaseFirestore _firestore;

  ReceiptController({
    required ReceiptRepository receiptRepository,
    required OcrService ocrService,
    required ImageService imageService,
    required FirebaseFirestore firestore,
  })  : _receiptRepository = receiptRepository,
        _ocrService = ocrService,
        _imageService = imageService,
        _firestore = firestore;

  // State
  final isLoading = false.obs;
  final isProcessing = false.obs;
  final errorMessage = Rx<String?>(null);
  final selectedImage = Rx<File?>(null);
  final ocrResult = Rx<OcrResult?>(null);
  final selectedRecipient = Rx<Map<String, String>?>(null); // {uid, name}
  final selectedGroup = Rx<String?>(null);
  final userReceipts = <ReceiptModel>[].obs;
  final pendingReceipts = <ReceiptModel>[].obs;
  final pendingApprovals = <ReceiptApproval>[].obs;

  // Form validation
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();

  late final ReceiptApprovalRepository _approvalRepository;

  @override
  void onInit() {
    super.onInit();
    _approvalRepository = ReceiptApprovalRepository(_firestore);
  }

  @override
  void onClose() {
    amountController.dispose();
    descriptionController.dispose();
    _ocrService.dispose();
    super.onClose();
  }

  // Image capture
  Future<void> captureReceiptImage() async {
    try {
      errorMessage.value = null;
      isLoading.value = true;

      final image = await _imageService.captureReceiptImage();
      if (image != null) {
        selectedImage.value = image;
        await _processImage(image);
      }
    } catch (e) {
      errorMessage.value = _handleException(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickReceiptImage() async {
    try {
      errorMessage.value = null;
      isLoading.value = true;

      final image = await _imageService.pickReceiptImage();
      if (image != null) {
        selectedImage.value = image;
        await _processImage(image);
      }
    } catch (e) {
      errorMessage.value = _handleException(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _processImage(File imageFile) async {
    try {
      isProcessing.value = true;
      final result = await _ocrService.recognizeText(imageFile);
      ocrResult.value = result;

      // Auto-fill form fields
      amountController.text = result.amount?.toStringAsFixed(2) ?? '';
      descriptionController.text = result.description ?? '';
    } catch (e) {
      errorMessage.value = _handleException(e);
      ocrResult.value = null;
    } finally {
      isProcessing.value = false;
    }
  }

  void updateAmount(String value) {
    amountController.text = value;
  }

  void updateDescription(String value) {
    descriptionController.text = value;
  }

  void selectRecipient(String uid, String name) {
    selectedRecipient.value = {'uid': uid, 'name': name};
  }

  void selectGroup(String groupId) {
    selectedGroup.value = groupId;
  }

  Future<void> submitReceipt(String currentUserId) async {
    try {
      if (!_validateReceipt()) {
        return;
      }

      errorMessage.value = null;
      isLoading.value = true;

      final amount = double.parse(amountController.text);
      final description = descriptionController.text.trim();

      if (selectedRecipient.value == null && selectedGroup.value == null) {
        errorMessage.value = 'Lütfen alıcı veya grup seçiniz';
        return;
      }

      final participants = <String>[currentUserId];
      String? fromUserId;
      String? toUserId;

      if (selectedRecipient.value != null) {
        toUserId = selectedRecipient.value!['uid'];
        participants.add(toUserId!);
        fromUserId = currentUserId;
      }

      if (selectedGroup.value != null) {
        // For group expenses, add group members as participants
        participants.add(selectedGroup.value!);
      }

      final receipt = ReceiptModel(
        id: '',
        createdBy: currentUserId,
        fromUserId: fromUserId,
        toUserId: toUserId,
        groupId: selectedGroup.value,
        amount: amount,
        description: description,
        imageUrl: null, // URL would be set after Firebase Storage upload
        status: 'pending',
        createdAt: DateTime.now(),
        participants: participants.toSet().toList(),
        ocrData: {
          'rawText': ocrResult.value?.rawText,
          'confidence': ocrResult.value?.confidence ?? 0.0,
        },
      );

      final createdReceipt = await _receiptRepository.createReceipt(receipt);

      // Send approval request if individual recipient selected
      if (toUserId != null) {
        await _approvalRepository.createApproval(
          ReceiptApproval(
            id: '',
            createdBy: currentUserId,
            approverId: toUserId,
            receiptId: createdReceipt.id,
            status: 'pending',
            createdAt: DateTime.now(),
          ),
        );
      }

      _resetForm();
      Get.back(result: createdReceipt);
      Get.snackbar('Başarılı', 'Fiş başarıyla gönderildi');
    } catch (e) {
      errorMessage.value = _handleException(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approveReceipt(String approvalId, String receiptId) async {
    try {
      isLoading.value = true;
      await _approvalRepository.approveReceipt(approvalId, receiptId);
      await _loadPendingApprovals();
      Get.snackbar('Başarılı', 'Fiş onaylandı');
    } catch (e) {
      errorMessage.value = _handleException(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> rejectReceipt(String approvalId, String receiptId) async {
    try {
      isLoading.value = true;
      await _approvalRepository.rejectReceipt(approvalId, receiptId);
      await _loadPendingApprovals();
      Get.snackbar('Başarılı', 'Fiş reddedildi');
    } catch (e) {
      errorMessage.value = _handleException(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUserReceipts(String userId) async {
    try {
      errorMessage.value = null;
      isLoading.value = true;
      final receipts = await _receiptRepository.getUserReceipts(userId);
      userReceipts.value = receipts;
    } catch (e) {
      errorMessage.value = _handleException(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadPendingApprovals({String? userId}) async {
    if (userId == null) return;
    try {
      final approvals = await _approvalRepository.getPendingApprovals(userId);
      pendingApprovals.value = approvals;
    } catch (e) {
      errorMessage.value = _handleException(e);
    }
  }

  void clearImage() {
    selectedImage.value = null;
    ocrResult.value = null;
    _resetForm();
  }

  bool _validateReceipt() {
    if (amountController.text.isEmpty) {
      errorMessage.value = 'Lütfen tutar giriniz';
      return false;
    }

    try {
      final amount = double.parse(amountController.text);
      if (amount <= 0) {
        errorMessage.value = 'Tutar 0 ile büyük olmalıdır';
        return false;
      }
    } catch (_) {
      errorMessage.value = 'Geçersiz tutar formatı';
      return false;
    }

    if (descriptionController.text.trim().isEmpty) {
      errorMessage.value = 'Lütfen açıklama giriniz';
      return false;
    }

    return true;
  }

  void _resetForm() {
    selectedImage.value = null;
    ocrResult.value = null;
    amountController.clear();
    descriptionController.clear();
    selectedRecipient.value = null;
    selectedGroup.value = null;
    errorMessage.value = null;
  }

  String _handleException(dynamic exception) {
    if (exception is OcrException) {
      return exception.toString();
    } else if (exception is PermissionException) {
      return exception.toString();
    } else if (exception is ImageException) {
      return exception.toString();
    } else if (exception is ReceiptRepositoryException) {
      return exception.toString();
    } else {
      return 'Bir hata oluştu: $exception';
    }
  }
}
