import 'package:billing_app/presentation/home.dart';
import 'package:flutter/material.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    // Wait for 2 seconds before navigating to the Dashboard
    Future.delayed(const Duration(seconds: 2), () {
      // Navigate to the Dashboard with a fade transition
      Navigator.pushReplacement(
        context,
        _createFadeRoute(),
      );
    });

    return Scaffold(
      backgroundColor: Colors.white, // Background color for the splash screen
      body: Center(
        child: Image.asset('assets/icons/icon.png'), // Your splash image
      ),
    );
  }

  // Creates a fade route transition for the next screen (Dashboard)
  PageRouteBuilder _createFadeRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const DashboardScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeIn;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        animation.drive(tween);

        return FadeTransition(
          opacity: animation, // Fade effect
          child: child,
        );
      },
    );
  }
}
