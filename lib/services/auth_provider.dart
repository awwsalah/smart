import 'package:flutter/foundation.dart';

import '../models/user.dart';
import 'auth_service.dart';
import 'profile_service.dart';

/// Holds the logged-in user for the current session (in-memory).
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();

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

  void setCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  Future<String?> updateClientProfile({
    required String fullName,
    required int cityId,
    required int districtId,
    int? streetId,
    String? landmarkNote,
    String? currentPassword,
    String? newPassword,
  }) async {
    if (_currentUser == null) return 'Not logged in';
    final result = await _profileService.updateClientProfile(
      current: _currentUser!,
      fullName: fullName,
      cityId: cityId,
      districtId: districtId,
      streetId: streetId,
      landmarkNote: landmarkNote,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    if (result.error != null) return result.error;
    _currentUser = result.user;
    notifyListeners();
    return null;
  }

  Future<String?> updateDriverProfile({
    required String fullName,
    required String vehicleType,
    required int serviceCityId,
    String? vehiclePlate,
    String? currentPassword,
    String? newPassword,
  }) async {
    if (_currentUser == null) return 'Not logged in';
    final result = await _profileService.updateDriverProfile(
      current: _currentUser!,
      fullName: fullName,
      vehicleType: vehicleType,
      serviceCityId: serviceCityId,
      vehiclePlate: vehiclePlate,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    if (result.error != null) return result.error;
    _currentUser = result.user;
    notifyListeners();
    return null;
  }
}
