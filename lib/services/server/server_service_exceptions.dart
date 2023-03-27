import 'dart:io';

class CouldNotConnectError implements Exception {
  final dynamic error;
  CouldNotConnectError(this.error);
}

class BadCertificateError implements Exception {
  final X509Certificate cert;
  BadCertificateError(this.cert);
}

class AuthenticationError implements Exception {
  final dynamic error;
  AuthenticationError(this.error);
}

class RegisterUserError implements Exception {
  final dynamic error;
  RegisterUserError(this.error);
}

class UserAlreadyExistsError implements Exception {
  final dynamic error;
  UserAlreadyExistsError(this.error);
}

class InvalidPasswordError implements Exception {
  final dynamic error;
  InvalidPasswordError(this.error);
}
