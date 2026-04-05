import 'package:url_launcher/url_launcher.dart';

class EmergencyWhatsAppService {
  Future<bool> openChatWithPrefilledMessage({
    required String rawPhoneNumber,
    required String message,
  }) async {
    final normalizedNumber = normalizePhoneNumber(rawPhoneNumber);
    if (normalizedNumber == null || normalizedNumber.isEmpty) {
      return false;
    }

    final encodedMessage = Uri.encodeComponent(message);

    // 1) نحاول نفتح واتساب مباشرة
    final Uri whatsappUri = Uri.parse(
      'whatsapp://send?phone=$normalizedNumber&text=$encodedMessage',
    );

    // 2) fallback إلى wa.me
    final Uri waMeUri = Uri.parse(
      'https://wa.me/$normalizedNumber?text=$encodedMessage',
    );

    try {
      final openedWhatsApp = await launchUrl(
        whatsappUri,
        mode: LaunchMode.externalApplication,
      );

      if (openedWhatsApp) {
        return true;
      }
    } catch (_) {
      // ignored - هنجرّب wa.me
    }

    try {
      final openedWaMe = await launchUrl(
        waMeUri,
        mode: LaunchMode.externalApplication,
      );

      return openedWaMe;
    } catch (_) {
      return false;
    }
  }

  String? normalizePhoneNumber(String rawPhoneNumber) {
    final digitsOnly = rawPhoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.isEmpty) return null;

    // لو الرقم بالفعل بصيغة مصر الدولية
    if (digitsOnly.startsWith('20') && digitsOnly.length >= 12) {
      return digitsOnly;
    }

    // لو الرقم المحلي يبدأ بـ 0 مثل 010xxxxxxxx
    if (digitsOnly.startsWith('0') && digitsOnly.length == 11) {
      return '2$digitsOnly'; // 010... -> 2010...
    }

    // لو الرقم بدون الصفر الأول مثل 10xxxxxxxx
    if (digitsOnly.startsWith('1') && digitsOnly.length == 10) {
      return '20$digitsOnly';
    }

    // لو رقم دولي آخر أو مُدخل بشكل كامل
    if (digitsOnly.length >= 10) {
      return digitsOnly;
    }

    return null;
  }
}