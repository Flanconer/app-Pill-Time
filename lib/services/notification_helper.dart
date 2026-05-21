import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

 static Future<void> init() async {
    // 1. Inicializamos la base de datos de tiempos
    tz.initializeTimeZones();

    // 2. ¡LA MAGIA!: Detectamos tu zona horaria y extraemos su identificador
    final TimezoneInfo tzInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzInfo.identifier)); // <-- Aquí sacamos el texto exacto

    // 3. Configuramos el ícono
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(android: androidSettings);
    
    await _notificationsPlugin.initialize(settings: settings);
  }
  // Pedir permisos en Android 13+
  static Future<void> requestPermissions() async {
    final androidImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();
    await androidImplementation?.requestExactAlarmsPermission();
  }

  // Programar la alarma futura
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required int delayInMinutes,
  }) async {
    final scheduledTime = tz.TZDateTime.now(tz.local).add(Duration(minutes: delayInMinutes));

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'pilltime_channel_id',
      'Alarmas de Medicamentos',
      channelDescription: 'Notificaciones para recordar la toma de medicamentos',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledTime,
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
  
  // ---> MÉTODO NUEVO: CAZADOR DE ERRORES <---
  static Future<void> showSimpleNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'canal_prueba', 
      'Canal de Prueba',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    // Al no tener try-catch aquí, si Android lo bloquea, el error viajará a la pantalla
  await _notificationsPlugin.show(
      id: 888,
      title: '¡Permisos listos!',
      body: 'Si ves esto, las notificaciones ya funcionan.',
      notificationDetails: notificationDetails,
    );
  }
}