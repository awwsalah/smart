import 'package:flutter/material.dart';

import '../services/phone_service.dart';
import '../utils/app_snackbar.dart';

/// Call + SMS buttons shown when a contact phone number is available.
class ContactButtons extends StatelessWidget {
  const ContactButtons({
    super.key,
    required this.phone,
    this.callLabel = 'Call',
    this.smsLabel = 'SMS',
    this.smsBody,
  });

  final String phone;
  final String callLabel;
  final String smsLabel;
  final String? smsBody;

  Future<void> _call(BuildContext context) async {
    if (phone.trim().isEmpty) {
      AppSnackBar.showError(context, 'Phone number not available');
      return;
    }
    final ok = await PhoneService.call(phone);
    if (!context.mounted) return;
    if (!ok) PhoneService.showContactError(context);
  }

  Future<void> _sms(BuildContext context) async {
    if (phone.trim().isEmpty) {
      AppSnackBar.showError(context, 'Phone number not available');
      return;
    }
    final ok = await PhoneService.sms(phone, body: smsBody);
    if (!context.mounted) return;
    if (!ok) PhoneService.showContactError(context);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _call(context),
            icon: const Icon(Icons.phone),
            label: Text(callLabel),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _sms(context),
            icon: const Icon(Icons.sms_outlined),
            label: Text(smsLabel),
          ),
        ),
      ],
    );
  }
}
