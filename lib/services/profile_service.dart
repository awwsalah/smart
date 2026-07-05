import '../db/user_dao.dart';
import '../models/user.dart';
import 'password_service.dart';

/// Updates profile fields and password for logged-in users.
class ProfileService {
  ProfileService({UserDao? userDao}) : _userDao = userDao ?? UserDao();

  final UserDao _userDao;

  Future<({User? user, String? error})> updateClientProfile({
    required User current,
    required String fullName,
    required int cityId,
    required int districtId,
    int? streetId,
    String? landmarkNote,
    String? currentPassword,
    String? newPassword,
  }) async {
    if (current.id == null) {
      return (user: null, error: 'Account not found');
    }
    if (fullName.trim().isEmpty) {
      return (user: null, error: 'Full name is required');
    }

    final passwordError = _validatePasswordChange(
      current.passwordHash,
      currentPassword,
      newPassword,
    );
    if (passwordError != null) return (user: null, error: passwordError);

    final fields = <String, dynamic>{
      'full_name': fullName.trim(),
      'city_id': cityId,
      'district_id': districtId,
      'street_id': streetId,
      'landmark_note': landmarkNote?.trim().isEmpty == true
          ? null
          : landmarkNote?.trim(),
    };
    if (newPassword != null && newPassword.isNotEmpty) {
      fields['password_hash'] = PasswordService.hashPassword(newPassword);
    }

    await _userDao.updateUser(current.id!, fields);
    final updated = await _userDao.getUserById(current.id!);
    return (user: updated, error: null);
  }

  Future<({User? user, String? error})> updateDriverProfile({
    required User current,
    required String fullName,
    required String vehicleType,
    required int serviceCityId,
    String? vehiclePlate,
    String? currentPassword,
    String? newPassword,
  }) async {
    if (current.id == null) {
      return (user: null, error: 'Account not found');
    }
    if (fullName.trim().isEmpty) {
      return (user: null, error: 'Full name is required');
    }

    final passwordError = _validatePasswordChange(
      current.passwordHash,
      currentPassword,
      newPassword,
    );
    if (passwordError != null) return (user: null, error: passwordError);

    final fields = <String, dynamic>{
      'full_name': fullName.trim(),
      'vehicle_type': vehicleType,
      'vehicle_plate': vehiclePlate?.trim().isEmpty == true
          ? null
          : vehiclePlate?.trim(),
      'service_city_id': serviceCityId,
    };
    if (newPassword != null && newPassword.isNotEmpty) {
      fields['password_hash'] = PasswordService.hashPassword(newPassword);
    }

    await _userDao.updateUser(current.id!, fields);
    final updated = await _userDao.getUserById(current.id!);
    return (user: updated, error: null);
  }

  String? _validatePasswordChange(
    String storedHash,
    String? currentPassword,
    String? newPassword,
  ) {
    final wantsChange = newPassword != null && newPassword.isNotEmpty;
    if (!wantsChange) return null;

    if (currentPassword == null || currentPassword.isEmpty) {
      return 'Enter your current password to set a new one';
    }
    if (!PasswordService.verifyPassword(currentPassword, storedHash)) {
      return 'Current password is incorrect';
    }
    if (newPassword.length < 6) {
      return 'New password must be at least 6 characters';
    }
    return null;
  }
}
