import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/app_snackbar.dart';

/// Opens the native dialer or SMS app (no in-app chat).
class PhoneService {
  /// Launches `tel:` URI — returns false if the dialer cannot open.
  static Future<bool> call(String phone) async {
    final cleaned = phone.trim();
    if (cleaned.isEmpty) return false;

    final uri = Uri(scheme: 'tel', path: cleaned);
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri);
    }
    return false;
  }

  /// Launches `sms:` URI — optional pre-filled message body.
  static Future<bool> sms(String phone, {String? body}) async {
    final cleaned = phone.trim();
    if (cleaned.isEmpty) return false;

    final uri = Uri(
      scheme: 'sms',
      path: cleaned,
      queryParameters:
          body != null && body.isNotEmpty ? {'body': body} : null,
    );
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri);
    }
    return false;
  }

  static void showContactError(BuildContext context) {
    AppSnackBar.showError(context, 'Could not open phone or SMS app');
  }
}
