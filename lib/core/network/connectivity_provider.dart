import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';

/// Status koneksi internet aplikasi.
///
/// - [online]    : ada interface jaringan & host API benar-benar reachable.
/// - [offline]   : tidak ada interface jaringan, atau host API tidak reachable.
/// - [checking]  : sedang memverifikasi reachability (transisi awal/refresh).
enum ConnectionStatus { online, offline, checking }

/// Provider status koneksi internet global.
///
/// Menggabungkan dua sumber kebenaran:
/// 1. `connectivity_plus` — mendeteksi ada/tidaknya interface jaringan
///    (WiFi/seluler). Ini cepat tapi BUKAN jaminan internet benar-benar jalan
///    (mis. terhubung WiFi tanpa akses internet / captive portal).
/// 2. Verifikasi reachability — DNS lookup ke host API ([AppConfig.probeHost])
///    untuk memastikan koneksi benar-benar bisa menjangkau server.
class ConnectivityProvider extends ChangeNotifier {
  ConnectivityProvider({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity() {
    _init();
  }

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectionStatus _status = ConnectionStatus.checking;
  ConnectionStatus get status => _status;

  bool get isOnline => _status == ConnectionStatus.online;
  bool get isOffline => _status == ConnectionStatus.offline;
  bool get isChecking => _status == ConnectionStatus.checking;

  Future<void> _init() async {
    _subscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
    );
    try {
      final results = await _connectivity.checkConnectivity();
      await _onConnectivityChanged(results);
    } catch (e) {
      debugPrint('ConnectivityProvider init error: $e');
      _setStatus(ConnectionStatus.offline);
    }
  }

  Future<void> _onConnectivityChanged(List<ConnectivityResult> results) async {
    final hasInterface = results.any((r) => r != ConnectivityResult.none);
    if (!hasInterface) {
      _setStatus(ConnectionStatus.offline);
      return;
    }
    // Ada interface jaringan → verifikasi apakah server benar-benar reachable.
    _setStatus(ConnectionStatus.checking);
    await _verifyReachability();
  }

  Future<void> _verifyReachability() async {
    try {
      final result = await InternetAddress.lookup(
        AppConfig.probeHost,
      ).timeout(const Duration(seconds: 5));
      final reachable =
          result.isNotEmpty && result.first.rawAddress.isNotEmpty;
      _setStatus(
        reachable ? ConnectionStatus.online : ConnectionStatus.offline,
      );
    } catch (_) {
      // SocketException / TimeoutException → anggap offline.
      _setStatus(ConnectionStatus.offline);
    }
  }

  /// Paksa cek ulang koneksi (mis. dari tombol retry di banner offline).
  Future<void> refresh() async {
    _setStatus(ConnectionStatus.checking);
    try {
      final results = await _connectivity.checkConnectivity();
      await _onConnectivityChanged(results);
    } catch (e) {
      debugPrint('ConnectivityProvider refresh error: $e');
      _setStatus(ConnectionStatus.offline);
    }
  }

  void _setStatus(ConnectionStatus status) {
    if (_status == status) return;
    _status = status;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
