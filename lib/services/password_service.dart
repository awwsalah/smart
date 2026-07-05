import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Hashes passwords with SHA-256 + a random salt (never store plain text).
class PasswordService {
  static const int _saltLength = 16;

  /// Returns `salt:hash` ready to save in the `password_hash` column.
  static String hashPassword(String password) {
    final salt = _generateSalt();
    final hash = _sha256('$salt$password');
    return '$salt:$hash';
  }

  /// Checks a plain password against a stored `salt:hash` value.
  static bool verifyPassword(String password, String storedHash) {
    final parts = storedHash.split(':');
    if (parts.length != 2) return false;

    final salt = parts[0];
    final expectedHash = parts[1];
    return _sha256('$salt$password') == expectedHash;
  }

  static String _sha256(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }

  static String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(_saltLength, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }
}
