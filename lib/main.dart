import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 1. Importa Supabase
import 'screens/splash_screen.dart';
import 'services/notification_helper.dart';

// 2. Transforma el main a asíncrono
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 3. Inicializa Supabase con tus credenciales
  await Supabase.initialize(
    url: 'https://zdbdwzblxzsgzzjcsndy.supabase.co/',
    anonKey: '',
  );
await NotificationHelper.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PillTime',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

// 4. Creamos un atajo para usar el cliente de Supabase fácilmente en otras pantallas
final supabase = Supabase.instance.client;
