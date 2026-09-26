import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../presentation/widgets/no_internet_dialog.dart';
import '../route/app_route.dart';

/// Global network connectivity service.
///
/// Provides active network interface tracking via [connectivity_plus],
/// real internet DNS verification (preventing false-positive WiFi connections),
/// and global No-Internet dialog presentation and dismissal.
class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  static NetworkService get instance => _instance;

  final Connectivity _connectivity;
  final StreamController<bool> _connectivityController = StreamController<bool>.broadcast();

  bool _isDialogShowing = false;
  bool _isOnline = true;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  NetworkService._internal({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity() {
    _init();
  }

  /// Current online status cached from latest check.
  bool get isOnline => _isOnline;

  /// Whether the No-Internet dialog is currently active on screen.
  bool get isDialogShowing => _isDialogShowing;

  /// Stream of true/false representing live internet reachability.
  Stream<bool> get onConnectivityChanged => _connectivityController.stream;

  void _init() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((results) async {
      final hasNet = await hasInternetConnection();
      _isOnline = hasNet;
      _connectivityController.add(hasNet);

      if (!hasNet) {
        showNoInternetDialog();
      } else {
        dismissNoInternetDialog();
      }
    });
  }

  /// Verifies active internet reachability.
  /// First checks the hardware network interfaces, then executes a DNS ping
  /// to verify true end-to-end internet connectivity.
  Future<bool> hasInternetConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final hasInterface = results.any((r) => r != ConnectivityResult.none);
      if (!hasInterface) {
        _isOnline = false;
        return false;
      }

      // Perform real internet DNS lookup with a fast timeout (2.5s)
      final googleLookup = await InternetAddress.lookup('google.com')
          .timeout(const Duration(milliseconds: 2500));
      if (googleLookup.isNotEmpty && googleLookup[0].rawAddress.isNotEmpty) {
        _isOnline = true;
        return true;
      }
    } catch (_) {
      // Fallback DNS lookup (Cloudflare) in case Google is blocked/slow
      try {
        final cfLookup = await InternetAddress.lookup('one.one.one.one')
            .timeout(const Duration(milliseconds: 2000));
        if (cfLookup.isNotEmpty && cfLookup[0].rawAddress.isNotEmpty) {
          _isOnline = true;
          return true;
        }
      } catch (_) {
        _isOnline = false;
        return false;
      }
    }

    _isOnline = false;
    return false;
  }

  /// Checks internet connection and triggers the blocking dialog if offline.
  Future<void> checkAndShowNoInternet() async {
    final connected = await hasInternetConnection();
    if (!connected) {
      showNoInternetDialog();
    }
  }

  /// Shows the modal, non-dismissible No-Internet dialog.
  /// Prevents stacking multiple dialogs using [_isDialogShowing].
  Future<void> showNoInternetDialog({VoidCallback? onConnected}) async {
    if (_isDialogShowing) return;

    final context = AppRoute.rootNavigatorKey.currentContext;
    if (context == null) {
      // If navigator context is not yet mounted (e.g. at cold start),
      // retry once after the first frame renders.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showNoInternetDialog(onConnected: onConnected);
      });
      return;
    }

    _isDialogShowing = true;
    developer.log('🚨 [NetworkService] Showing No-Internet blocking dialog.', name: 'NetworkService');

    try {
      await showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        routeSettings: const RouteSettings(name: '/no-internet-dialog'),
        builder: (dialogContext) => NoInternetDialog(
          onRetrySuccess: onConnected,
        ),
      );
    } catch (e) {
      developer.log('⚠️ [NetworkService] showDialog error: $e', name: 'NetworkService');
    } finally {
      _isDialogShowing = false;
    }
  }

  /// Closes the No-Internet dialog if currently displayed.
  void dismissNoInternetDialog() {
    if (!_isDialogShowing) return;

    final navigator = AppRoute.rootNavigatorKey.currentState;
    if (navigator != null && navigator.canPop()) {
      developer.log('✅ [NetworkService] Dismissing No-Internet dialog (Connection restored).', name: 'NetworkService');
      navigator.pop();
    }
    _isDialogShowing = false;
  }

  /// Cleans up resources on app shutdown.
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityController.close();
  }
}
