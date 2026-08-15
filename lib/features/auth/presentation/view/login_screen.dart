import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              const SizedBox(height: 55),

              // Logo
              Center(
                child: _Logo(
                  color: colorScheme.primary,
                ),
              ),

              const SizedBox(height: 24),

              Center(
                child: Text(
                  'Welcome Back!',
                  style: theme.textTheme.headlineLarge,
                ),
              ),

              const SizedBox(height: 8),

              Center(
                child: Text(
                  'Please login to continue',
                  style: theme.textTheme.bodyMedium,
                ),
              ),

              const SizedBox(height: 45),

              Text(
                'Email',
                style: theme.textTheme.labelLarge,
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _emailController,

                keyboardType: TextInputType.emailAddress,

                decoration: const InputDecoration(
                  hintText: 'Enter your email',

                  prefixIcon: Icon(
                    Icons.email_outlined,
                  ),
                ),
              ),

              const SizedBox(height: 22),

              Text(
                'Password',
                style: theme.textTheme.labelLarge,
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _passwordController,

                obscureText: _obscurePassword,

                decoration: InputDecoration(
                  hintText: 'Enter your password',

                  prefixIcon: const Icon(
                    Icons.lock_outline,
                  ),

                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword =
                        !_obscurePassword;
                      });
                    },

                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerRight,

                child: TextButton(
                  onPressed: () {
                    // Forgot password
                  },

                  child: const Text(
                    'Forgot Password?',
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 52,

                child: ElevatedButton(
                  onPressed: _login,

                  child: const Text(
                    'Login',
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Row(
                children: [

                  Expanded(
                    child: Divider(
                      color: theme.dividerColor,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                    ),

                    child: Text(
                      'or continue with',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),

                  Expanded(
                    child: Divider(
                      color: theme.dividerColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              Row(
                children: [

                  Expanded(
                    child: _SocialButton(
                      icon: 'G',
                      label: 'Google',
                      onPressed: () {},
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _SocialButton(
                      icon: '',
                      label: 'Apple',
                      onPressed: () {},
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [

                  Text(
                    "Don't have an account? ",
                    style: theme.textTheme.bodyMedium,
                  ),

                  GestureDetector(
                    onTap: () {
                      context.push('/register');
                    },

                    child: Text(
                      'Register',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _login() {

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    /*if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter email and password',
          ),
        ),
      );

      return;
    }*/

    // Firebase login এখানে হবে

    context.go('/dashboard');
  }
}


// =====================================================
// LOGO
// =====================================================

class _Logo extends StatelessWidget {

  final Color color;

  const _Logo({
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,

      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Icon(
        Icons.inventory_2_outlined,
        color: color,
        size: 40,
      ),
    );
  }
}


// =====================================================
// SOCIAL BUTTON
// =====================================================

class _SocialButton extends StatelessWidget {

  final String icon;
  final String label;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {

    return OutlinedButton(
      onPressed: onPressed,

      style: OutlinedButton.styleFrom(
        minimumSize: const Size(
          double.infinity,
          50,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [

          Text(
            icon,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(width: 10),

          Text(label),
        ],
      ),
    );
  }
}