import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> captureReceiptImage() async {
    if (!await _requestCameraPermission()) {
      throw PermissionException('Kamera izni verilmedi');
    }

    try {
      final photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.back,
      );
      
      if (photo != null) {
        return File(photo.path);
      }
      return null;
    } catch (e) {
      throw ImageException('Resim çekilemedi: $e');
    }
  }

  Future<File?> pickReceiptImage() async {
    if (!await _requestGalleryPermission()) {
      throw PermissionException('Galeri izni verilmedi');
    }

    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw ImageException('Resim seçilemedi: $e');
    }
  }

  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<bool> _requestGalleryPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.photos.request();
      return status.isGranted;
    }
    return true;
  }

  Future<bool> hasCameraPermission() async {
    return await Permission.camera.status.isGranted;
  }

  Future<void> openAppSettings() async {
    await openAppSettings();
  }
}

class PermissionException implements Exception {
  final String message;
  PermissionException(this.message);

  @override
  String toString() => message;
}

class ImageException implements Exception {
  final String message;
  ImageException(this.message);

  @override
  String toString() => message;
}
