import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/Core/router/routes.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';
import 'package:frontend/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:frontend/features/authentication/presentation/cubit/auth_state.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().register(
          displayName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = AppDimensions.screenWidth(context);
    final isWideLayout = screenWidth >= 900;

    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingLg,
              vertical: AppDimensions.paddingLg,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWideLayout ? 1400 : 640,
                  minHeight: AppDimensions.screenHeight(context) -
                      AppDimensions.spacingXxxxl,
                ),
                child: isWideLayout
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 7, child: _buildVisualPanel(cs, textTheme)),
                          const SizedBox(width: AppDimensions.spacingXl),
                          Expanded(flex: 5, child: _buildFormPanel(cs, textTheme)),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: AppDimensions.spacingXxl),
                          _buildBrandHeader(cs, textTheme),
                          const SizedBox(height: AppDimensions.spacingXl),
                          _buildFormPanel(cs, textTheme),
                          const SizedBox(height: AppDimensions.spacingXl),
                          _buildMobileFooter(cs, textTheme),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisualPanel(ColorScheme cs, TextTheme textTheme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCmlgVEi_Xj-O9LS7-1_JONLBboy_Yh5WM27ctIrMH_Ongkvk4zTPZqJkoWgcVDHMzVaPLMOhiCR0XHRENMNGW22zYS-tCFbLwKMRagQ4AN1M5KUUMc3GFwawboTGM5IegLO2AgI2O-Wz9o5mvMk6i4PTkM0JP8J2bl1HxETOUchoJQ1WTri1EOL3KLrCK7ZQW7vlL3UNarYGSHeNd9uM2Da0oaukqK1weZrIloytmr3wGId5UUb6q81yfefEKGQbyKEiivPPSLUJ8',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    cs.surface.withOpacity(0.88),
                    cs.surface.withOpacity(0.35),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          Positioned(
            left: AppDimensions.spacingXl,
            bottom: AppDimensions.spacingXxl,
            right: AppDimensions.spacingXxl,
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.paddingXl),
              decoration: BoxDecoration(
                color: cs.surface.withOpacity(0.72),
                borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                border: Border.all(color: cs.onSurface.withOpacity(0.08)),
                boxShadow: [
                  BoxShadow(
                    color: cs.onSurface.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Elevate Your Palate.',
                    style: textTheme.displayLarge?.copyWith(color: cs.primary),
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  Text(
                    'Join ZestyBite today and discover the most exquisite culinary experiences delivered straight to your door.',
                    style: textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: AppDimensions.spacingXxl,
            right: -AppDimensions.spacingXxl,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -AppDimensions.spacingXxl,
            left: -AppDimensions.spacingXl,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: cs.secondary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandHeader(ColorScheme cs, TextTheme textTheme) {
    return Row(
      children: [
        Container(
          width: AppDimensions.iconXl,
          height: AppDimensions.iconXl,
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMax),
          ),
          child: Icon(
            Icons.restaurant,
            color: cs.onPrimaryContainer,
            size: AppDimensions.iconLg,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingSm),
        Text(
          'ZestyBite',
          style: textTheme.headlineSmall?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildFormPanel(ColorScheme cs, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (AppDimensions.screenWidth(context) >= 900) _buildBrandHeader(cs, textTheme),
        if (AppDimensions.screenWidth(context) >= 900)
          const SizedBox(height: AppDimensions.spacingXxl),
        Text(
          'Create your account',
          style: textTheme.headlineLarge?.copyWith(color: cs.onSurface),
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        Text(
          'Join our community of culinary enthusiasts.',
          style: textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: AppDimensions.spacingXxl),
        Card(
          elevation: 0,
          color: cs.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingXl),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextField(
                    label: 'Full Name',
                    controller: _nameController,
                    hintText: 'Enter your full name',
                    icon: Icons.person,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.spacingLg),
                  _buildTextField(
                    label: 'Email Address',
                    controller: _emailController,
                    hintText: 'name@example.com',
                    icon: Icons.mail,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.spacingLg),
                  _buildTextField(
                    label: 'Password',
                    controller: _passwordController,
                    hintText: 'Create a strong password',
                    icon: Icons.lock,
                    obscureText: _obscurePassword,
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        color: cs.onSurfaceVariant,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.trim().length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.spacingXl),
                  BlocConsumer<AuthCubit, AuthState>(
                    listener: (context, state) {
                      if (state.status == AuthStatus.error && state.errorMessage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.errorMessage!)),
                        );
                      }
                    },
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: state.status == AuthStatus.loading ? null : _submit,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: state.status == AuthStatus.loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Create Account'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  Center(
                    child: TextButton(
                      onPressed: () => context.go(RoutesPath.login),
                      child: Text('Already have an account? Login'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
            suffixIcon: suffix,
            hintText: hintText,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileFooter(ColorScheme cs, TextTheme textTheme) {
    return Align(
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Already have an account?',
            style: textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          TextButton(
            onPressed: () => context.go(RoutesPath.login),
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}
