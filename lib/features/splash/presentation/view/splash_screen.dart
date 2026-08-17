import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _controller.forward();

    Timer(
      const Duration(seconds: 2),
      () async {
        if (!mounted) return;

        final savedToken = await InjectionContainer.authRepository.getSavedToken();
        if (savedToken != null && savedToken.isNotEmpty) {
          try {
            await InjectionContainer.getMeUseCase();
            if (mounted) context.go('/dashboard');
            return;
          } catch (_) {}
        }

        if (mounted) context.go('/login');
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2563EB),
              Color(0xFF1D4ED8),
            ],
          ),
        ),

        child: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,

            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,

                child: ScaleTransition(
                  scale: _scaleAnimation,

                  child: Column(
                    children: [

                      const Spacer(),

                      // Logo
                      _InventoryLogo(),

                      const SizedBox(height: 32),

                      const Text(
                        'Inventory',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1,
                        ),
                      ),

                      const Text(
                        'Management',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1,
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 40,
                        ),
                        child: Text(
                          'Manage your stock, track items\nand grow your business.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Loading indicator
                      const SizedBox(
                        width: 90,
                        child: LinearProgressIndicator(
                          minHeight: 4,
                          backgroundColor: Colors.white24,
                          valueColor:
                          AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _InventoryLogo extends StatelessWidget {
  const _InventoryLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 145,
      height: 145,

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),

      child: Center(
        child: Container(
          width: 105,
          height: 105,

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),

          child: const Icon(
            Icons.inventory_2_outlined,
            size: 62,
            color: Color(0xFF2563EB),
          ),
        ),
      ),
    );
  }
}