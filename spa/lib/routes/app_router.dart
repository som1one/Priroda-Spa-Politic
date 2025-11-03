import 'package:flutter/material.dart';
import 'route_names.dart';
import '../screens/auth/registration_screen.dart';
import '../screens/auth/verify_email_screen.dart';

class AppRouter {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.home:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Home')),
            body: const Center(child: Text('Home Screen')),
          ),
        );

      case RouteNames.settings:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Settings')),
            body: const Center(child: Text('Settings Screen')),
          ),
        );

      case RouteNames.profile:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Profile')),
            body: const Center(child: Text('Profile Screen')),
          ),
        );

      case RouteNames.registration:
        return MaterialPageRoute(
          builder: (_) => const RegistrationScreen(),
        );

      case RouteNames.verifyEmail:
        return MaterialPageRoute(
          builder: (_) => const VerifyEmailScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
    }
  }
}

