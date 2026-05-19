import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../models/receipt_model.dart';

class OcrService {
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<OcrResult> recognizeText(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await textRecognizer.processImage(inputImage);
      
      final fullText = recognizedText.text;
      final result = _parseReceiptText(fullText);
      
      await inputImage.close();
      return result;
    } catch (e) {
      throw OcrException('Metin tanıma başarısız: $e');
    }
  }

  OcrResult _parseReceiptText(String text) {
    if (text.isEmpty) {
      throw OcrException('Alınan metinde veri yok');
    }

    final amount = _extractAmount(text);
    final description = _extractDescription(text);

    if (amount == null) {
      throw OcrException('Fiyat bulunamadı');
    }

    return OcrResult(
      amount: amount,
      description: description ?? 'Fiş',
      rawText: text,
      confidence: 0.8,
    );
  }

  double? _extractAmount(String text) {
    // Turkish lira patterns: 100 TL, 100TL, 100₺, 100 ₺
    final patterns = [
      RegExp(r'(\d+[.,]\d{2})\s*(?:TL|₺)', caseSensitive: false),
      RegExp(r'(?:TL|₺)\s*(\d+[.,]\d{2})', caseSensitive: false),
      RegExp(r'\b(\d+[.,]\d{2})\b'),
      RegExp(r'(\d+)\s*(?:TL|₺)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final amountStr = match.group(1)!.replaceAll(',', '.');
        try {
          return double.parse(amountStr);
        } catch (_) {
          continue;
        }
      }
    }

    return null;
  }

  String? _extractDescription(String text) {
    final lines = text.split('\n');
    
    // Get the first non-empty, non-numeric line as description
    for (final line in lines) {
      final cleaned = line.trim();
      if (cleaned.isEmpty || cleaned.length < 2) continue;
      if (RegExp(r'^\d+[.,]\d{2}').hasMatch(cleaned)) continue;
      if (cleaned.toLowerCase().contains('total') || 
          cleaned.toLowerCase().contains('tutar')) continue;
      
      return cleaned.length > 50 ? cleaned.substring(0, 50) : cleaned;
    }

    return null;
  }

  Future<void> dispose() async {
    await textRecognizer.close();
  }
}

class OcrException implements Exception {
  final String message;
  OcrException(this.message);

  @override
  String toString() => message;
}
