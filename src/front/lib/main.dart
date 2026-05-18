import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:frontend/Core/injector/injector.dart';
import 'package:frontend/Core/router/app_router.dart';
import 'package:frontend/Core/theme/app_theme.dart';
import 'package:frontend/Core/utils/observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = 'pk_test_YOUR_STRIPE_PUBLISHABLE_KEY';
  await Stripe.instance.applySettings();
  setupDependencies();
  Bloc.observer = MyBlocObserver();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, _) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Restaurant Ordering',
        theme: appLightTheme(),
        darkTheme: appDarkTheme(),
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
