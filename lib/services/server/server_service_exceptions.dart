import 'dart:io';

class CouldNotConnectError implements Exception {
  final dynamic error;
  CouldNotConnectError(this.error);
}

class BadCertificateError implements Exception {
  final X509Certificate cert;
  BadCertificateError(this.cert);
}
