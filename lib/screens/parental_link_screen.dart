import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Asegúrate de importar tu servicio de email correctamente según tu estructura de carpetas
import '../services/email_service.dart'; 

class ParentalLinkScreen extends StatefulWidget {
  const ParentalLinkScreen({super.key});

  @override
  State<ParentalLinkScreen> createState() => _ParentalLinkScreenState();
}

class _ParentalLinkScreenState extends State<ParentalLinkScreen> {
  final TextEditingController _emailController = TextEditingController();
  
  // Lista vacía que llenaremos desde la memoria del teléfono
  List<String> _linkedEmails = [];

  @override
  void initState() {
    super.initState();
    _loadSavedEmails(); // Cargamos los correos al abrir la pantalla
  }

  // --- NUEVO: Leer de la memoria ---
  Future<void> _loadSavedEmails() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _linkedEmails = prefs.getStringList('saved_emails') ?? [];
    });
  }

  // --- NUEVO: Guardar en la memoria ---
  Future<void> _saveEmailsToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('saved_emails', _linkedEmails);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Lógica para agregar un nuevo correo
  void _linkEmail() {
    final email = _emailController.text.trim();
    if (email.isNotEmpty && email.contains('@')) {
      setState(() {
        _linkedEmails.add(email);
      });
      _saveEmailsToDisk(); // Guardamos el cambio en el disco duro
      _emailController.clear();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Correo vinculado exitosamente.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa un correo válido.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // Lógica para eliminar un correo vinculado
  void _removeEmail(int index) {
    setState(() {
      _linkedEmails.removeAt(index);
    });
    _saveEmailsToDisk(); // Actualizamos el disco duro
  }

  // --- NUEVO: Función de Prueba de Correo ---
  Future<void> _testEmail(String emailToTest) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Enviando alerta de prueba...'), backgroundColor: Colors.blue),
    );

    await EmailService.sendMedicationAlert(
      caregiverEmail: emailToTest,
      patientName: 'Usuario de Prueba',
      medicationName: 'Paracetamol (Prueba)',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Alerta enviada! Revisa la bandeja de entrada.'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Enlace Parental',
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Color(0xFFFDEEEF),
                    child: Icon(Icons.supervisor_account, size: 40, color: Color(0xFF2196F3)),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Red de Apoyo',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Vincula el correo de un familiar o cuidador. Ellos recibirán una notificación simultánea cuando sea hora de tomar tus medicamentos.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            const Text(
              'Vincular nueva cuenta',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'ejemplo@correo.com',
                      prefixIcon: const Icon(Icons.email, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _linkEmail,
                  child: const Text(
                    'Vincular',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            const Text(
              'Cuentas vinculadas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            _linkedEmails.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'Aún no has vinculado ninguna cuenta.',
                        style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _linkedEmails.length,
                    itemBuilder: (context, index) {
                      final correo = _linkedEmails[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFF9F6F6),
                            child: Icon(Icons.person, color: Color(0xFF5A4A42)),
                          ),
                          title: Text(
                            correo,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                          // Botón extra para enviar correo de prueba
                          subtitle: GestureDetector(
                            onTap: () => _testEmail(correo),
                            child: const Text('Toca aquí para probar conexión', style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                            onPressed: () => _removeEmail(index),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}