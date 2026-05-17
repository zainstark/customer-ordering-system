import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/Core/utils/app_assets.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/Core/router/routes.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';
import 'package:frontend/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:frontend/features/authentication/presentation/cubit/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isWideLayout = AppDimensions.screenWidth(context) >= 900;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          // ── Main layout ──────────────────────────────────────────────
          if (isWideLayout)
            Row(
              children: [
                // Left: immersive image panel (50%)
                Expanded(child: _buildImagePanel(cs)),
                // Right: form panel (50%)
                Expanded(child: _buildFormPanel(cs, isWide: true)),
              ],
            )
          else
            _buildFormPanel(cs, isWide: false),

          // ── Help FAB (desktop only) ───────────────────────────────────
          if (isWideLayout)
            Positioned(
              bottom: AppDimensions.spacingLg,
              right: AppDimensions.spacingLg,
              child: _buildHelpFab(cs),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LEFT PANEL — image + gradient overlay + bottom branding
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildImagePanel(ColorScheme cs) {
    final textTheme = Theme.of(context).textTheme;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image
        Image.asset(
          AppAssets.login,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(color: cs.surfaceContainerHigh),
        ),

        // Gradient: opaque at bottom → transparent at top
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  cs.surface.withValues(alpha: .9),
                  cs.surface.withValues(alpha: .15),
                  Colors.transparent,
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
        ),

        // Bottom branding block
        Positioned(
          bottom: AppDimensions.spacingXl,
          left: AppDimensions.spacingXl,
          right: AppDimensions.spacingXl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Whatever',
                style: textTheme.displayLarge?.copyWith(
                  color: cs.primary,
                  letterSpacing: -0.96, // −0.02 × 48px
                ),
              ),
              const SizedBox(height: AppDimensions.spacingMd),
              Text(
                'Experience culinary excellence delivered with a touch of elegance and precision.',
                style: textTheme.titleMedium?.copyWith(color: cs.onSurface),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // RIGHT PANEL — form
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildFormPanel(ColorScheme cs, {required bool isWide}) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      color: cs.surface,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingLg,
              vertical: AppDimensions.paddingLg,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Mobile-only ZestyBite heading ───────────────────
                  if (!isWide) ...[
                    Center(
                      child: Text(
                        'ZestyBite',
                        style: textTheme.headlineLarge?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingLg),
                  ],

                  // ── Section title ───────────────────────────────────
                  Text(
                    'Welcome Back',
                    style: textTheme.headlineLarge?.copyWith(
                      color: cs.onSurface,
                    ),
                    textAlign: isWide ? TextAlign.start : TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.spacingXs),
                  Text(
                    'Please enter your details to sign in',
                    style: textTheme.bodyLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    textAlign: isWide ? TextAlign.start : TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.spacingLg),

                  // ── Form ────────────────────────────────────────────
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Email
                        _buildLabelledField(
                          label: 'Email Address',
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: textTheme.bodyLarge?.copyWith(
                              color: cs.onSurface,
                            ),
                            decoration: _fieldDecoration(
                              cs,
                              hint: 'chef@zestybite.com',
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return 'Please enter your email';
                              if (!RegExp(
                                r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                              ).hasMatch(v)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingMd),

                        // Password
                        _buildLabelledField(
                          label: 'Password',
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: textTheme.bodyLarge?.copyWith(
                              color: cs.onSurface,
                            ),
                            decoration: _fieldDecoration(cs, hint: '••••••••')
                                .copyWith(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: cs.onSurfaceVariant,
                                    ),
                                    onPressed: () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                  ),
                                ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return 'Please enter your password';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingXs),

                        // Remember me + Forgot password
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     Row(
                        //       children: [
                        //         SizedBox(
                        //           width: 24,
                        //           height: 24,
                        //           child: Checkbox(
                        //             value: _rememberMe,
                        //             onChanged: (v) => setState(() => _rememberMe = v ?? false),
                        //             activeColor: cs.primaryContainer,
                        //             side: BorderSide(color: cs.outlineVariant),
                        //             shape: RoundedRectangleBorder(
                        //               borderRadius: BorderRadius.circular(4),
                        //             ),
                        //           ),
                        //         ),
                        //         const SizedBox(width: AppDimensions.spacingSm),
                        //         Text(
                        //           'Remember me',
                        //           style: textTheme.bodyMedium?.copyWith(
                        //             color: cs.onSurfaceVariant,
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //     TextButton(
                        //       onPressed: () {},
                        //       style: TextButton.styleFrom(
                        //         padding: EdgeInsets.zero,
                        //         minimumSize: Size.zero,
                        //         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        //       ),
                        //       child: Text(
                        //         'Forgot Password?',
                        //         style: textTheme.bodyMedium?.copyWith(
                        //           color: cs.primary,
                        //           fontWeight: FontWeight.w600,
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        const SizedBox(height: AppDimensions.spacingLg),

                        // Sign In button
                        BlocConsumer<AuthCubit, AuthState>(
                          listener: (context, state) {
                            if (state.status == AuthStatus.error &&
                                state.errorMessage != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(state.errorMessage!)),
                              );
                            } else if (state.status ==
                                AuthStatus.authenticated) {
                              context.go(RoutesPath.menu);
                            }
                          },
                          builder: (context, state) {
                            final isLoading =
                                state.status == AuthStatus.loading;
                            return ElevatedButton(
                              onPressed: isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: cs.primaryContainer,
                                foregroundColor: cs.onPrimaryContainer,
                                disabledBackgroundColor: cs.primaryContainer
                                    .withValues(alpha: .6),
                                elevation: 4,
                                shadowColor: cs.primaryContainer.withValues(
                                  alpha: .4,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusXl,
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                child: isLoading
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: cs.onPrimaryContainer,
                                        ),
                                      )
                                    : Text(
                                        'Sign In',
                                        style: textTheme.titleMedium?.copyWith(
                                          color: cs.onPrimaryContainer,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppDimensions.spacingXxl),

                        // ── Footer ───────────────────────────────────
                        Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: textTheme.bodyMedium?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.go(RoutesPath.signup),
                                child: Text(
                                  'Sign up for free',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: cs.primary,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                    decorationColor: cs.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  /// Wraps a field with a label above it (matching the HTML label-sm style).
  Widget _buildLabelledField({required String label, required Widget child}) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: cs.onSurfaceVariant,
            letterSpacing: 0.6,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingXs),
        child,
      ],
    );
  }

  /// Base InputDecoration shared by all fields.
  InputDecoration _fieldDecoration(ColorScheme cs, {required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: .4)),
      filled: true,
      fillColor: cs.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMd,
        vertical: AppDimensions.paddingMd,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: .3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: .3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        borderSide: BorderSide(color: cs.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        borderSide: BorderSide(color: cs.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        borderSide: BorderSide(color: cs.error, width: 1.5),
      ),
    );
  }

  /// Glass-morphism help button (desktop only).
  Widget _buildHelpFab(ColorScheme cs) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh.withValues(alpha: .85),
        shape: BoxShape.circle,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: .35)),
        boxShadow: [
          BoxShadow(
            color: cs.onSurface.withValues(alpha: .1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(Icons.help_outline, color: cs.primary),
        onPressed: () {},
        tooltip: 'Help',
      ),
    );
  }
}
