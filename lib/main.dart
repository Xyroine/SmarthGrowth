import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/profile/child_profile_screen.dart';
import 'screens/profile/growth_chart_screen.dart';
import 'screens/monitoring/motorik_screen.dart';
import 'screens/monitoring/kognitif_screen.dart';
import 'screens/monitoring/bahasa_screen.dart';
import 'screens/monitoring/emosional_screen.dart';
import 'screens/education/article_detail_screen.dart';
import 'navigation/main_navigation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const SmartGrowthApp());
}

class SmartGrowthApp extends StatelessWidget {
  const SmartGrowthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartGrowth',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/main': (_) => const MainNavigation(),
        '/child_profile': (_) => const ChildProfileScreen(),
        '/growth_chart': (_) => const GrowthChartScreen(),
        '/motorik': (_) => const MotorikScreen(),
        '/kognitif': (_) => const KognitifScreen(),
        '/bahasa': (_) => const BahasaScreen(),
        '/emosional': (_) => const EmosionalScreen(),
        '/article_detail': (_) => const ArticleDetailScreen(),
      },
    );
  }
}
