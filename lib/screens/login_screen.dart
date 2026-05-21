import 'package:flutter/material.dart';
import 'package:pilltime/screens/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Importación de Supabase
import '../main.dart'; // Importación de tu instancia de Supabase
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para capturar lo que el usuario escriba
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // Variable para controlar el estado del checkbox
  bool _rememberMe = false;

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- NUEVA LÓGICA DE INICIO DE SESIÓN ---
  Future<void> _signIn() async {
    try {
      final email = _userController.text.trim();
      final password = _passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, llena todos los campos')),
        );
        return;
      }

      // Llamamos a Supabase para hacer login
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user != null) {
        if (!mounted) return;
        
        // Usamos pushReplacement para destruir la pantalla de Login del historial
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on AuthException catch (error) {
      // Manejo de errores específicos de Supabase (ej. contraseña incorrecta)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credenciales incorrectas o usuario no encontrado'), backgroundColor: Colors.red),
      );
    } catch (error) {
      // Manejo de cualquier otro error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ocurrió un error inesperado'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7), // Un gris muy clarito casi blanco
      body: Center(
        child: SingleChildScrollView( // Permite hacer scroll si el teclado se abre
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Logotipo
              Image.asset(
                'assets/Logotipo_2PILLTIME.png',
                width: 150,
              ),
              const SizedBox(height: 50),

              // 2. Campo de Usuario (Correo)
              TextField(
                controller: _userController,
                keyboardType: TextInputType.emailAddress, // Ayuda al teclado a mostrar el '@'
                decoration: InputDecoration(
                  hintText: 'Correo',
                  prefixIcon: const Icon(Icons.person, color: Color(0xFF5A4A42)), // Color oscuro tipo café/gris
                  filled: true,
                  fillColor: const Color(0xFFF9F6F6),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: const BorderSide(color: Colors.grey, width: 0.8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 3. Campo de Contraseña
              TextField(
                controller: _passwordController,
                obscureText: true, // Oculta el texto de la contraseña
                decoration: InputDecoration(
                  hintText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock, color: Color(0xFF5A4A42)),
                  filled: true,
                  fillColor: const Color(0xFFF9F6F6),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: const BorderSide(color: Colors.grey, width: 0.8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                  ),
                ),
              ),
              
              // Opción "Recordar cuenta"
              const SizedBox(height: 10), // Un pequeño espacio
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    activeColor: const Color(0xFF2196F3), // Azul de tu botón
                    onChanged: (bool? value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                  ),
                  const Text(
                    'Recordar cuenta',
                    style: TextStyle(
                      color: Color(0xFF5A4A42), // Color de los iconos para que combine
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20), // Ajusté este espacio para compensar el nuevo elemento

              // 4. Botón "Iniciar Sesión"
              SizedBox(
                width: 200, // Ancho controlado para que no ocupe toda la pantalla
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3), // Color azul
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0), // Bordes bien redondeados
                    ),
                    elevation: 0, // Sin sombra dura para mantener el estilo plano
                  ),
                  onPressed: _signIn, // <--- AQUÍ SE CONECTA LA FUNCIÓN DE SUPABASE
                  child: const Text(
                    'Iniciar Sesión',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // 5. Texto de "¿No tienes cuenta?"
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  );
                },
                child: const Text(
                  '¿No tienes cuenta? Regístrate aquí',
                  style: TextStyle(
                    color: Color(0xFFE53935), // Color rojo
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}