import 'package:flutter/material.dart';
import 'route_names.dart';
import '../screens/auth/registration_screen.dart';
import '../screens/auth/verify_email_screen.dart';
import '../screens/auth/name_registration_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/profile_screen.dart';

class AppRouter {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
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
          builder: (_) => const ProfileScreen(),
        );

      case RouteNames.registration:
        return MaterialPageRoute(
          builder: (_) => const RegistrationScreen(),
        );

      case RouteNames.verifyEmail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => VerifyEmailScreen(
            email: args?['email'],
            password: args?['password'],
          ),
        );

      case RouteNames.nameRegistration:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => NameRegistrationScreen(
            email: args?['email'] ?? '',
            password: args?['password'],
          ),
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

