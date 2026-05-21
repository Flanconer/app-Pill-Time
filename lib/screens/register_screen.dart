import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart'; // Asegúrate de que esta ruta apunte correctamente a tu main.dart

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controladores para cada campo
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Lógica de registro con Supabase
  Future<void> _signUp() async {
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final fullName = _fullNameController.text.trim();
      final username = _usernameController.text.trim();
      final dob = _dobController.text.trim();
      final address = _addressController.text.trim();

      // Validación básica
      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El correo y la contraseña son obligatorios')),
        );
        return;
      }

      // Llamamos a Supabase para crear el usuario y guardamos todos sus datos extra
      final AuthResponse res = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'username': username,
          'dob': dob,
          'address': address,
        },
      );

      if (res.user != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Registro exitoso! Por favor inicia sesión.'),
            backgroundColor: Colors.green,
          ),
        );
        // Regresamos a la pantalla de Login después de registrarse
        Navigator.pop(context);
      }
    } on AuthException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message), backgroundColor: Colors.red),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ocurrió un error inesperado'), backgroundColor: Colors.red),
      );
    }
  }

  // Método auxiliar para construir los campos de texto y no repetir código
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0), // Espacio entre cada campo
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon, color: const Color(0xFF5A4A42)), // Color consistente
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7), // Mismo fondo que el Login
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Barra transparente
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5A4A42)),
          onPressed: () => Navigator.pop(context), // Regresa a la pantalla anterior
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Título
              const Text(
                'Regístrate en PillTime',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3), // Azul para resaltar el título
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Usamos nuestro método auxiliar para crear los 6 campos fácilmente
              _buildTextField(
                controller: _fullNameController,
                hintText: 'Nombre completo',
                icon: Icons.person,
              ),
              _buildTextField(
                controller: _usernameController,
                hintText: 'Nombre de usuario',
                icon: Icons.account_circle,
              ),
              _buildTextField(
                controller: _dobController,
                hintText: 'Fecha de nacimiento',
                icon: Icons.calendar_today,
                keyboardType: TextInputType.datetime,
              ),
              _buildTextField(
                controller: _emailController,
                hintText: 'Correo',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              _buildTextField(
                controller: _addressController,
                hintText: 'Dirección',
                icon: Icons.location_on,
              ),
              _buildTextField(
                controller: _passwordController,
                hintText: 'Contraseña',
                icon: Icons.lock,
                isPassword: true,
              ),

              const SizedBox(height: 10),

              // Botón "Registrar"
              SizedBox(
                width: double.infinity, // Ocupa el ancho disponible respetando el padding
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 250, 17, 17),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _signUp, // Aquí conectamos el botón con la función de Supabase
                  child: const Text(
                    'Registrar',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}