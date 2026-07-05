/// Shared form validation messages for auth and profile screens.
class Validators {
  Validators._();

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^[0-9]{9,15}$').hasMatch(value.trim())) {
      return 'Enter a valid phone number (9–15 digits)';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    return null;
  }

  static String? requiredSelection(String? value, String label) {
    if (value == null || value.isEmpty) {
      return 'Please select $label';
    }
    return null;
  }

  static String? cancelReason(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Cancellation reason is required';
    }
    return null;
  }

  static String? optionalNewPassword(String? value, String currentPassword) {
    if (currentPassword.isEmpty) return null;
    return password(value);
  }
}
