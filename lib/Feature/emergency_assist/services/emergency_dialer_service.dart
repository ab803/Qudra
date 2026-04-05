import 'package:url_launcher/url_launcher.dart';

class EmergencyDialerService {
  Future<void> callNumber(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    final launched = await launchUrl(uri);

    if (!launched) {
      throw Exception('Could not launch dialer for $phoneNumber');
    }
  }
}