import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../components/add_alarm_dialog.dart';
import '../services/db_helper.dart';
import '../services/email_service.dart';
import '../services/notification_helper.dart'; // Importamos el servicio de notificaciones
import 'inventory_screen.dart';
import 'chatbot_screen.dart';
import 'parental_link_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String _currentTime;
  late Timer _timer;
  
  List<Map<String, dynamic>> _upcomingMeds = [];
  List<Map<String, dynamic>> _takenMedsHistory = [];

  @override
  void initState() {
    super.initState();
    _currentTime = _formatDateTime(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateCurrentTime());
    _loadData(); 
    
    // Novedad: Pedimos los permisos de notificación al usuario la primera vez que entra
    NotificationHelper.requestPermissions();
  }

  Future<void> _loadData() async {
    final alarms = await DatabaseHelper.getAlarms();
    final history = await DatabaseHelper.getHistory();
    setState(() {
      _upcomingMeds = alarms;
      _takenMedsHistory = history;
    });
  }

  Future<void> _takeMedication(String medName) async {
    final timeNow = DateFormat('hh:mm a').format(DateTime.now()); 
    
    await DatabaseHelper.insertHistory({
      'med_name': medName,
      'time_taken': timeNow,
    });
    
    _loadData();
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Registraste la toma de $medName'), backgroundColor: Colors.green),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateCurrentTime() {
    setState(() {
      _currentTime = _formatDateTime(DateTime.now());
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('hh:mm:ss a').format(dateTime);
  }

  // Novedad: Lógica mejorada para manejar el resultado del diálogo de alarma
 // Lógica mejorada para manejar el resultado del diálogo de alarma
  void _showAddAlarmDialog() async {
    // Recibimos los datos del diálogo (si el usuario le dio a "Programar")
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddAlarmDialog(),
    );
    
    // Validamos que el resultado no sea nulo (es decir, que no haya presionado Cancelar)
    if (result != null) {
      // 1. Guardamos en la BD Local
      await DatabaseHelper.insertAlarm({
        'med_name': result['med_name'],
        'interval': result['interval'],
        'start_date': result['start_date'],
        'end_date': result['end_date'],
      });

      // 2. AQUÍ ESTÁ LA MAGIA QUE FALTABA: Calculamos los minutos
      int intervalValue = int.tryParse(result['interval'].split(' ')[0]) ?? 0;
      bool isHours = result['interval'].contains('horas');
      int delayInMinutes = isHours ? (intervalValue * 60) : intervalValue;

      // 3. ¡PROGRAMAMOS LA NOTIFICACIÓN FUTURA!
      await NotificationHelper.scheduleNotification(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000), // Genera un ID único
        title: '¡Hora de tu medicina!',
        body: 'Te toca tomar: ${result['med_name']}',
        delayInMinutes: delayInMinutes, 
      );

   await NotificationHelper.scheduleNotification(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000), 
        title: '¡Hora de tu medicina!',
        body: 'Te toca tomar: ${result['med_name']}',
        delayInMinutes: delayInMinutes, 
      );

      // 4. --- TRAMPA PARA LEER EL ERROR EN EL CELULAR ---
      try {
        await NotificationHelper.showSimpleNotification();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ERROR DE ANDROID: $e'), 
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 10), // Dura 10 segundos en pantalla
          ),
        );
      }

      _loadData();
    }
  
    if (result != null) {
      // 1. Guardamos en la BD Local
      await DatabaseHelper.insertAlarm({
        'med_name': result['med_name'],
        'interval': result['interval'],
        'start_date': result['start_date'],
        'end_date': result['end_date'],
      });

      // 2. Extraemos el número del intervalo (ej. de "8 horas" extraemos el 8)
      int intervalValue = int.tryParse(result['interval'].split(' ')[0]) ?? 0;
      bool isHours = result['interval'].contains('horas');
      
      // Convertimos todo a minutos para el temporizador de notificaciones
      int delayInMinutes = isHours ? (intervalValue * 60) : intervalValue;

      // 3. ¡PROGRAMAMOS LA NOTIFICACIÓN NATIVA!
      await NotificationHelper.scheduleNotification(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000), // Genera un ID único
        title: '¡Hora de tu medicina!',
        body: 'Te toca tomar: ${result['med_name']}',
        delayInMinutes: delayInMinutes, 
      );
     Future<void> _takeMedication(String medName) async {
    final timeNow = DateFormat('hh:mm a').format(DateTime.now()); 
    
    // 1. Lo guardamos en el historial local
    await DatabaseHelper.insertHistory({
      'med_name': medName,
      'time_taken': timeNow,
    });

    // 2. ENVIAMOS EL CORREO AL CUIDADOR
    // (Asegúrate de cambiar 'correo_del_cuidador@gmail.com' por un correo real al que tengas acceso para probar)
    await EmailService.sendMedicationAlert(
      caregiverEmail: 'correo_del_cuidador@gmail.com', 
      patientName: 'Edgar', // Tu nombre
      medicationName: medName,
    );

      _loadData();
  if (!mounted) return;
    
    // Mostramos un mensajito confirmando ambas acciones
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Registraste la toma de $medName y se notificó a tu cuidador'), 
        backgroundColor: Colors.green
      ),
    );
  }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PILL/TIME'),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Color(0xFFFFEEEE)],
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircleAvatar(radius: 35, backgroundColor: Colors.white, child: Icon(Icons.person, size: 45, color: Colors.blue)),
                  SizedBox(height: 10),
                  Text('Edgar', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('edgarhdzm132000@gmail.com', style: TextStyle(color: Colors.black, fontSize: 12)),
                ],
              ),
            ),
            _buildDrawerItem(Icons.inventory, 'Inventario de Medicamentos', onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const InventoryScreen())).then((_) => _loadData());
            }),
            _buildDrawerItem(Icons.chat_bubble, 'Chatbot', onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatbotScreen()));
            }),
            _buildDrawerItem(Icons.supervisor_account, 'Enlace Parental', onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ParentalLinkScreen()));
            }),
            const Divider(),
            _buildDrawerItem(Icons.logout, 'Cerrar sesion', onTap: () {}),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 120, width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Colors.blue, Colors.red], begin: Alignment.centerLeft, end: Alignment.centerRight),
            ),
            child: Center(
              child: Text(_currentTime, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Medicamentos por tomar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  
                  _upcomingMeds.isEmpty 
                    ? const Text('No hay alarmas programadas', style: TextStyle(color: Colors.grey))
                    : Column(
                        children: _upcomingMeds.map((med) => GestureDetector(
                          onTap: () => _takeMedication(med['med_name']), 
                          child: _buildMedicationTile(
                              med['med_name'], 
                              'Cada ${med['interval']} - Toca para tomar', 
                              Icons.alarm,
                          ),
                        )).toList(),
                      ),
                  
                  const SizedBox(height: 30),
                  const Text('Historial de Medicamentos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  
                  _takenMedsHistory.isEmpty
                    ? const Text('Aún no has registrado tomas', style: TextStyle(color: Colors.grey))
                    : Column(
                        children: _takenMedsHistory.map((med) => _buildMedicationTile(
                            'Tomaste ${med['med_name']}', 
                            'A las ${med['time_taken']}', 
                            Icons.medical_services_outlined,
                        )).toList(),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddAlarmDialog,
        icon: const Icon(Icons.alarm_add, color: Colors.black),
        label: const Text('Agregar Alarma', style: TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xFFFDE1E1),
        elevation: 2,
      ),
    );
  }

  Widget _buildMedicationTile(String title, String subtitle, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: ListTile(
        leading: Icon(icon, color: Colors.brown[700], size: 30),
        title: Text(title, style: const TextStyle(fontSize: 16)),
        subtitle: Text(subtitle),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        dense: true,
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      onTap: onTap ?? () => Navigator.pop(context),
    );
  }
}