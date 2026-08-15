import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController =
  TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool _acceptedTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

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

              const SizedBox(height: 20),

              // Back button

              IconButton(
                onPressed: () {
                  context.pop();
                },

                icon: const Icon(
                  Icons.arrow_back_ios_new,
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: _Logo(
                  color: colorScheme.primary,
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: Text(
                  'Create Account',
                  style: theme.textTheme.headlineLarge,
                ),
              ),

              const SizedBox(height: 8),

              Center(
                child: Text(
                  'Fill in the details to get started',
                  style: theme.textTheme.bodyMedium,
                ),
              ),

              const SizedBox(height: 38),

              // Full Name

              Text(
                'Full Name',
                style: theme.textTheme.labelLarge,
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _nameController,

                decoration: const InputDecoration(
                  hintText: 'Enter your full name',

                  prefixIcon: Icon(
                    Icons.person_outline,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Email

              Text(
                'Email',
                style: theme.textTheme.labelLarge,
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _emailController,

                keyboardType:
                TextInputType.emailAddress,

                decoration: const InputDecoration(
                  hintText: 'Enter your email',

                  prefixIcon: Icon(
                    Icons.email_outlined,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Password

              Text(
                'Password',
                style: theme.textTheme.labelLarge,
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _passwordController,

                obscureText: _obscurePassword,

                decoration: InputDecoration(
                  hintText: 'Create a password',

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

              const SizedBox(height: 18),

              // Confirm password

              Text(
                'Confirm Password',
                style: theme.textTheme.labelLarge,
              ),

              const SizedBox(height: 8),

              TextField(
                controller:
                _confirmPasswordController,

                obscureText:
                _obscureConfirmPassword,

                decoration: InputDecoration(
                  hintText: 'Confirm your password',

                  prefixIcon: const Icon(
                    Icons.lock_outline,
                  ),

                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword =
                        !_obscureConfirmPassword;
                      });
                    },

                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Terms

              Row(
                children: [

                  Checkbox(
                    value: _acceptedTerms,

                    onChanged: (value) {
                      setState(() {
                        _acceptedTerms =
                            value ?? false;
                      });
                    },
                  ),

                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style:
                        theme.textTheme.bodySmall,

                        children: [

                          const TextSpan(
                            text: 'I agree to the ',
                          ),

                          TextSpan(
                            text: 'Terms & Conditions',
                            style: TextStyle(
                              color:
                              colorScheme.primary,
                              fontWeight:
                              FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Register button

              SizedBox(
                width: double.infinity,
                height: 52,

                child: ElevatedButton(
                  onPressed: _register,

                  child: const Text(
                    'Register',
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Row(
                mainAxisAlignment:
                MainAxisAlignment.center,

                children: [

                  Text(
                    'Already have an account? ',
                    style:
                    theme.textTheme.bodyMedium,
                  ),

                  GestureDetector(
                    onTap: () {
                      context.go('/login');
                    },

                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight:
                        FontWeight.w600,
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

  void _register() {

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    final password = _passwordController.text;
    final confirmPassword =
        _confirmPasswordController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill all fields',
          ),
        ),
      );

      return;
    }

    if (password != confirmPassword) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Passwords do not match',
          ),
        ),
      );

      return;
    }

    if (!_acceptedTerms) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please accept Terms & Conditions',
          ),
        ),
      );

      return;
    }

    // Firebase registration এখানে হবে

    // context.go('/dashboard');
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