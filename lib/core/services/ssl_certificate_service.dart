import 'dart:io';
import 'package:flutter/foundation.dart';

/// Service to handle SSL certificate validation and errors
class SSLCertificateService {
  static const List<String> _trustedDomains = ['sfxsys.com', '*.sfxsys.com'];

  /// Custom certificate callback that handles domain-specific validation
  static bool certificateCallback(X509Certificate cert, String host, int port) {
    try {
      // Log certificate details for debugging
      if (kDebugMode) {
        debugPrint('=== SSL Certificate Check ===');
        debugPrint('Host: $host:$port');
        debugPrint('Subject: ${cert.subject}');
        debugPrint('Issuer: ${cert.issuer}');
        debugPrint('Valid from: ${cert.startValidity}');
        debugPrint('Valid to: ${cert.endValidity}');
      }

      // Check if the certificate is expired
      final now = DateTime.now();
      if (now.isBefore(cert.startValidity) || now.isAfter(cert.endValidity)) {
        debugPrint('Certificate is expired or not yet valid');
        return false;
      }

      // Check if the host is in our trusted domains list
      if (_isTrustedDomain(host)) {
        debugPrint('Host $host is in trusted domains, accepting certificate');
        return true;
      }

      // For development mode, you might want to be more lenient
      if (kDebugMode) {
        debugPrint('Debug mode: accepting certificate for $host');
        // In debug mode, accept certificates but log warnings
        return true;
      }

      // In production, only accept properly validated certificates
      debugPrint('Certificate validation failed for $host');
      return false;
    } catch (e) {
      debugPrint('Error during certificate validation: $e');
      return false;
    }
  }

  /// Check if a domain is in the trusted domains list
  static bool _isTrustedDomain(String host) {
    for (final domain in _trustedDomains) {
      if (domain.startsWith('*')) {
        // Wildcard domain check
        final baseDomain = domain.substring(2); // Remove '*.'
        if (host == baseDomain || host.endsWith('.$baseDomain')) {
          return true;
        }
      } else {
        // Exact domain match
        if (host == domain) {
          return true;
        }
      }
    }
    return false;
  }

  /// Get detailed certificate information as a string
  static String getCertificateInfo(X509Certificate cert) {
    final info = StringBuffer();
    info.writeln('Certificate Details:');
    info.writeln('  Subject: ${cert.subject}');
    info.writeln('  Issuer: ${cert.issuer}');
    info.writeln('  Valid from: ${cert.startValidity}');
    info.writeln('  Valid to: ${cert.endValidity}');
    return info.toString();
  }

  /// Handle SSL handshake exceptions with user-friendly messages
  static String getSSLErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('certificate_verify_failed')) {
      if (errorString.contains('hostname mismatch')) {
        return 'SSL Certificate error: The server certificate doesn\'t match the domain name. This is a server configuration issue.';
      } else if (errorString.contains('certificate has expired')) {
        return 'SSL Certificate error: The server certificate has expired. Please contact support.';
      } else if (errorString.contains('self signed certificate')) {
        return 'SSL Certificate error: The server is using a self-signed certificate.';
      } else {
        return 'SSL Certificate error: The server certificate could not be verified. Please check your internet connection or contact support.';
      }
    } else if (errorString.contains('handshake')) {
      return 'Network error: Could not establish a secure connection to the server. Please check your internet connection.';
    } else if (errorString.contains('timeout')) {
      return 'Connection timeout: The server took too long to respond. Please try again.';
    } else {
      return 'Network error: Could not connect to the server. Please check your internet connection and try again.';
    }
  }
}
