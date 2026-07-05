import '../db/user_dao.dart';
import '../models/user.dart';
import 'password_service.dart';

/// Login, registration, and field validation for auth screens.
class AuthService {
  AuthService({UserDao? userDao}) : _userDao = userDao ?? UserDao();

  final UserDao _userDao;

  static const List<String> vehicleTypes = ['Truck', 'Tricycle', 'Van'];

  /// Returns null on success, or a user-facing error message.
  String? validatePhone(String phone) {
    final trimmed = phone.trim();
    if (trimmed.isEmpty) return 'Phone number is required';
    if (!RegExp(r'^[0-9]{9,15}$').hasMatch(trimmed)) {
      return 'Enter a valid phone number (9–15 digits)';
    }
    return null;
  }

  String? validatePassword(String password) {
    if (password.isEmpty) return 'Password is required';
    if (password.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? validateFullName(String name) {
    if (name.trim().isEmpty) return 'Full name is required';
    return null;
  }

  /// Logs in and checks the account matches the selected role.
  Future<({User? user, String? error})> login({
    required String phone,
    required String password,
    required String expectedRole,
  }) async {
    final phoneError = validatePhone(phone);
    if (phoneError != null) return (user: null, error: phoneError);

    final passwordError = validatePassword(password);
    if (passwordError != null) return (user: null, error: passwordError);

    final user = await _userDao.getUserByPhone(phone.trim());
    if (user == null) {
      return (user: null, error: 'Phone number not registered');
    }

    if (!PasswordService.verifyPassword(password, user.passwordHash)) {
      return (user: null, error: 'Incorrect password');
    }

    if (user.role != expectedRole) {
      final roleLabel = expectedRole == 'client' ? 'Client' : 'Driver';
      return (
        user: null,
        error: 'This account is not registered as a $roleLabel',
      );
    }

    return (user: user, error: null);
  }

  Future<({User? user, String? error})> registerClient({
    required String fullName,
    required String phone,
    required String password,
    required int cityId,
    required int districtId,
    int? streetId,
    String? landmarkNote,
  }) async {
    final nameError = validateFullName(fullName);
    if (nameError != null) return (user: null, error: nameError);

    final phoneError = validatePhone(phone);
    if (phoneError != null) return (user: null, error: phoneError);

    final passwordError = validatePassword(password);
    if (passwordError != null) return (user: null, error: passwordError);

    if (await _userDao.phoneExists(phone.trim())) {
      return (user: null, error: 'Phone number already registered');
    }

    final user = User(
      fullName: fullName.trim(),
      phone: phone.trim(),
      passwordHash: PasswordService.hashPassword(password),
      role: 'client',
      cityId: cityId,
      districtId: districtId,
      streetId: streetId,
      landmarkNote: landmarkNote?.trim().isEmpty == true
          ? null
          : landmarkNote?.trim(),
    );

    final id = await _userDao.insertUser(user);
    return (user: user.copyWith(id: id), error: null);
  }

  Future<({User? user, String? error})> registerDriver({
    required String fullName,
    required String phone,
    required String password,
    required String vehicleType,
    required int serviceCityId,
    String? vehiclePlate,
  }) async {
    final nameError = validateFullName(fullName);
    if (nameError != null) return (user: null, error: nameError);

    final phoneError = validatePhone(phone);
    if (phoneError != null) return (user: null, error: phoneError);

    final passwordError = validatePassword(password);
    if (passwordError != null) return (user: null, error: passwordError);

    if (await _userDao.phoneExists(phone.trim())) {
      return (user: null, error: 'Phone number already registered');
    }

    final user = User(
      fullName: fullName.trim(),
      phone: phone.trim(),
      passwordHash: PasswordService.hashPassword(password),
      role: 'driver',
      vehicleType: vehicleType,
      vehiclePlate: vehiclePlate?.trim().isEmpty == true
          ? null
          : vehiclePlate?.trim(),
      serviceCityId: serviceCityId,
    );

    final id = await _userDao.insertUser(user);
    return (user: user.copyWith(id: id), error: null);
  }
}
