import 'dart:convert';

import 'package:flutter/services.dart';

/// Loads sizes, time slots, and payment methods from seed_data.json.
class ReferenceDataService {
  ReferenceDataService._();
  static final ReferenceDataService instance = ReferenceDataService._();

  List<String>? _sizes;
  List<String>? _timeSlots;
  List<String>? _paymentMethods;

  Future<void> _ensureLoaded() async {
    if (_sizes != null) return;

    final jsonString = await rootBundle.loadString('seed_data.json');
    final data = json.decode(jsonString) as Map<String, dynamic>;

    _sizes = (data['sizes'] as List<dynamic>).cast<String>();
    _timeSlots = (data['time_slots'] as List<dynamic>).cast<String>();
    _paymentMethods =
        (data['payment_methods'] as List<dynamic>).cast<String>();
  }

  Future<List<String>> getSizes() async {
    await _ensureLoaded();
    return _sizes!;
  }

  Future<List<String>> getTimeSlots() async {
    await _ensureLoaded();
    return _timeSlots!;
  }

  Future<List<String>> getPaymentMethods() async {
    await _ensureLoaded();
    return _paymentMethods!;
  }
}
