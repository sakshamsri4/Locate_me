import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';

import '../login/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Lottie.asset('assets/animation/splash_map_animation.json'),
      splashIconSize: 200,
      duration: 3000,
      backgroundColor: Colors.deepPurple,
      splashTransition: SplashTransition.decoratedBoxTransition,
      nextScreen: PermissionHandlerScreen(),
    );
  }
}

class PermissionHandlerScreen extends StatefulWidget {
  const PermissionHandlerScreen({Key? key}) : super(key: key);

  @override
  State<PermissionHandlerScreen> createState() =>
      _PermissionHandlerScreenState();
}

class _PermissionHandlerScreenState extends State<PermissionHandlerScreen> {
  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    // Request foreground location permission
    PermissionStatus foregroundStatus = await Permission.location.request();

    if (foregroundStatus.isGranted) {
      // Request background location permission if foreground is granted
      PermissionStatus backgroundStatus =
          await Permission.locationAlways.request();

      if (backgroundStatus.isGranted) {
        // Navigate to the next screen if all permissions are granted
        _navigateToNextScreen();
      } else if (backgroundStatus.isDenied) {
        // Show rationale or denied message for background permission
        _showPermissionRationale(
          "Background location permission is necessary for tracking. Please grant it to proceed.",
        );
      } else if (backgroundStatus.isPermanentlyDenied) {
        // Open app settings if background permission is permanently denied
        openAppSettings();
      }
    } else if (foregroundStatus.isDenied) {
      // Show rationale or denied message for foreground permission
      _showPermissionRationale(
        "Location permission is necessary to use the app. Please grant it to proceed.",
      );
    } else if (foregroundStatus.isPermanentlyDenied) {
      // Open app settings if foreground permission is permanently denied
      openAppSettings();
    }
  }

  void _showPermissionRationale(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permission Required"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close the dialog
              PermissionStatus status =
                  await Permission.locationAlways.request();
              if (status.isGranted) {
                _navigateToNextScreen();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Permission is required to proceed."),
                  ),
                );
              }
            },
            child: const Text("Grant Permission"),
          ),
        ],
      ),
    );
  }

  void _navigateToNextScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Center(
        child: Lottie.asset('assets/animation/splash_map_animation.json'),
      ),
    );
  }
}
