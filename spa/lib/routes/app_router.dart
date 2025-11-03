import 'package:flutter/material.dart';
import 'route_names.dart';

// Импорты экранов будут добавлены позже
// import '../screens/home/home_screen.dart';

class AppRouter {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.home:
        // TODO: добавить HomeScreen
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Home')),
            body: const Center(child: Text('Home Screen')),
          ),
        );

      case RouteNames.settings:
        // TODO: добавить SettingsScreen
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Settings')),
            body: const Center(child: Text('Settings Screen')),
          ),
        );

      case RouteNames.profile:
        // TODO: добавить ProfileScreen
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Profile')),
            body: const Center(child: Text('Profile Screen')),
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

