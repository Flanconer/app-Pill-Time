import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  // Configura aquí el correo desde donde se enviarán las alertas de PillTime
  static const String _senderEmail = 'predatorberserquerq@gmail.com';
  // Pega aquí las 16 letras de la contraseña de aplicación de Google (sin espacios)
  static const String _appPassword = ''; 

  static Future<void> sendMedicationAlert({
    required String caregiverEmail,
    required String patientName,
    required String medicationName,
  }) async {
    // Configurar el servidor SMTP de Gmail
    final smtpServer = gmail(_senderEmail, _appPassword);

    // Crear el diseño del mensaje
    final message = Message()
      ..from = Address(_senderEmail, 'PillTime Alertas')
      ..recipients.add(caregiverEmail) // Correo del familiar/cuidador
      ..subject = '🚨 Alerta de Medicamento: $patientName'
      ..html = '''
        <div style="font-family: Arial, sans-serif; padding: 20px; border: 1px solid #FDEEEF; border-radius: 15px; background-color: #FDF9F9;">
          <h2 style="color: #2196F3; text-align: center;">Recordatorio de PillTime</h2>
          <p>Hola,</p>
          <p>Este es un aviso automático de la red de apoyo de <strong>$patientName</strong>.</p>
          <div style="background-color: #FDEEEF; padding: 15px; border-radius: 10px; margin: 20px 0; text-align: center;">
            <span style="font-size: 18px; color: #5A4A42;">Es hora de tomar el medicamento:</span><br>
            <strong style="font-size: 24px; color: #E53935;">$medicationName</strong>
          </div>
          <p style="font-size: 12px; color: Colors.gray; text-align: center;">Por favor, confirma con el paciente si ya realizó la toma correspondiente.</p>
        </div>
      ''';

    try {
      // Enviar el correo por internet
      await send(message, smtpServer);
      print('Correo de alerta enviado con éxito a $caregiverEmail');
    } catch (e) {
      print('Error al enviar el correo: $e');
    }
  }
}
