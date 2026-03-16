import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'services/auth_service.dart';
import 'screens/landing_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = AuthService();
  await authService.initialize();
  runApp(
    ChangeNotifierProvider.value(
      value: authService,
      child: const BookTrackerApp(),
    ),
  );
}

class BookTrackerApp extends StatelessWidget {
  const BookTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookTracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: context.watch<AuthService>().isLoggedIn
          ? const HomeScreen()
          : const LandingScreen(),
    );
  }
}
