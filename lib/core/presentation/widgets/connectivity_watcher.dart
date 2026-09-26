import 'dart:async';
import 'package:flutter/material.dart';
import '../../network/network_service.dart';

/// Global connectivity watcher widget that observes internet connection changes
/// across the entire app lifecycle and triggers the [NoInternetDialog] when disconnected.
class ConnectivityWatcher extends StatefulWidget {
  final Widget child;

  const ConnectivityWatcher({
    super.key,
    required this.child,
  });

  @override
  State<ConnectivityWatcher> createState() => _ConnectivityWatcherState();
}

class _ConnectivityWatcherState extends State<ConnectivityWatcher> with WidgetsBindingObserver {
  StreamSubscription<bool>? _subscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initial internet verification after the first frame mounts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NetworkService.instance.checkAndShowNoInternet();
    });

    // Listen to real-time connectivity changes
    _subscription = NetworkService.instance.onConnectivityChanged.listen((isOnline) {
      if (!isOnline) {
        NetworkService.instance.showNoInternetDialog();
      } else {
        NetworkService.instance.dismissNoInternetDialog();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-verify network connectivity when app is brought back to foreground
      NetworkService.instance.checkAndShowNoInternet();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
