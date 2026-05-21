import 'package:flutter/material.dart';
import 'login_screen.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  _navigateToNextScreen() async {
    // Simula un tiempo de carga de 3 segundos
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;
    // Navegación hacia el LoginScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagen del logo
            Image.asset(
              'assets/Logotipo_2PILLTIME.png', // Asegúrate de que la ruta coincida con tu imagen
              width: 200, // Ajusta el tamaño según tu imagen
            ),
            
            // Texto PILLTIME
            
          ],
        ),
      ),
    );
  }
}