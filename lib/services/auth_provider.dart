import 'package:flutter/foundation.dart';

import '../models/user.dart';
import 'auth_service.dart';

/// Holds the logged-in user for the current session (in-memory).
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _currentUser;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<String?> login({
    required String phone,
    required String password,
    required String role,
  }) async {
    final result = await _authService.login(
      phone: phone,
      password: password,
      expectedRole: role,
    );
    if (result.error != null) return result.error;

    _currentUser = result.user;
    notifyListeners();
    return null;
  }

  Future<String?> registerClient({
    required String fullName,
    required String phone,
    required String password,
    required int cityId,
    required int districtId,
    int? streetId,
    String? landmarkNote,
  }) async {
    final result = await _authService.registerClient(
      fullName: fullName,
      phone: phone,
      password: password,
      cityId: cityId,
      districtId: districtId,
      streetId: streetId,
      landmarkNote: landmarkNote,
    );
    if (result.error != null) return result.error;

    _currentUser = result.user;
    notifyListeners();
    return null;
  }

  Future<String?> registerDriver({
    required String fullName,
    required String phone,
    required String password,
    required String vehicleType,
    required int serviceCityId,
    String? vehiclePlate,
  }) async {
    final result = await _authService.registerDriver(
      fullName: fullName,
      phone: phone,
      password: password,
      vehicleType: vehicleType,
      serviceCityId: serviceCityId,
      vehiclePlate: vehiclePlate,
    );
    if (result.error != null) return result.error;

    _currentUser = result.user;
    notifyListeners();
    return null;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
