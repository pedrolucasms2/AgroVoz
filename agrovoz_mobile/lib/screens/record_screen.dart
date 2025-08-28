// lib/screens/record_screen.dart (esqueleto)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/session_provider.dart';
import '../services/speech_service.dart';
import '../services/api_service.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});
  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  final speech = SpeechService();
  final api = ApiService('http://10.0.2.2:8000'); // ajuste conforme ambiente

  Future<void> _start() async {
    // garantir permissão e iniciar escuta
  }

  Future<void> _stop() async {
    await speech.stop();
    context.read<SessionProvider>().setListening(false);
  }

  Future<void> _send() async {
    final text = context.read<SessionProvider>().recognizedText;
    final res = await api.processarFala(texto: text, usuarioId: 'dev');
    context.read<SessionProvider>().setNlpResult(
      res['dados_extraidos'] ?? {},
      List<String>.from(res['alertas'] ?? const []),
    );
    if (!mounted) return;
    Navigator.of(context).pushNamed('/review');
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SessionProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Gravação')),
      body: Column(
        children: [
          Text(state.isListening ? 'Escutando...' : 'Parado'),
          Expanded(child: SingleChildScrollView(child: Text(state.recognizedText))),
          Row(
            children: [
              ElevatedButton(onPressed: _start, child: const Text('Iniciar')),
              ElevatedButton(onPressed: _stop, child: const Text('Parar')),
              FilledButton(onPressed: _send, child: const Text('Enviar')),
            ],
          ),
        ],
      ),
    );
  }
}
