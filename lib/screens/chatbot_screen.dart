import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Lista para guardar los mensajes en la pantalla
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  // Variables de Gemini
  late final GenerativeModel _model;
  late final ChatSession _chat;

  @override
  void initState() {
    super.initState();
    _initializeGemini();
  }

  void _initializeGemini() {
    // ⚠️ REEMPLAZA ESTO CON TU API KEY REAL DE GOOGLE AI STUDIO ⚠️
    const apiKey = 'AIzaSyCFCnyEBsRBVZV0ytZ4JdU1Zc4q5XOtnb8';

    // Configuramos el modelo y le damos "Instrucciones de Sistema"
   _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.system(
        'Eres el asistente virtual médico de la aplicación PillTime. '
        'Tu creador es Edgar. Tu objetivo es responder dudas sobre medicamentos, '
        'recordatorios y dar consejos generales de salud. Sé muy amable, empático '
        'y conciso. Siempre recuerda al usuario que no eres un médico real y que '
        'ante síntomas graves deben consultar a un especialista.'
      ),
    );

    // Iniciamos una sesión de chat para que recuerde el contexto
    _chat = _model.startChat();

    // Mensaje de bienvenida inicial
    _messages.add({
      'text': '¡Hola! Soy tu asistente de PillTime. ¿En qué te puedo ayudar hoy con tus medicamentos o salud?',
      'isUser': false,
    });
  }

Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    // 1. Agregamos el mensaje del usuario a la pantalla
    setState(() {
      _messages.add({'text': text, 'isUser': true});
      _isLoading = true;
    });
    _textController.clear();
    _scrollToBottom();

    try {
      // 2. Enviamos el mensaje a Gemini
      final response = await _chat.sendMessage(Content.text(text));

      // 3. Agregamos la respuesta de Gemini a la pantalla
      setState(() {
        _messages.add({
          'text': response.text ?? 'Lo siento, no pude procesar eso.',
          'isUser': false,
        });
      });
    } catch (e) {
      // AQUÍ ESTÁ EL CAMBIO: Ahora la app nos mostrará el error real de la consola
      setState(() {
        _messages.add({
          'text': 'Error del sistema: $e',
          'isUser': false,
        });
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('Asistente PillTime'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          // Área de mensajes
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(15.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['isUser'];
                return _buildMessageBubble(msg['text'], isUser);
              },
            ),
          ),
          
          // Indicador de "Escribiendo..."
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: CircularProgressIndicator(color: Colors.blue),
            ),

          // Caja de texto inferior
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Escribe tu duda médica...',
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.blue,
                    radius: 24,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Diseño de la burbuja de chat
  Widget _buildMessageBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue : const Color(0xFFFDEEEF), // Azul para usuario, Rosa para bot
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(0),
            bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(20),
          ),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75, // Que no ocupe toda la pantalla
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}