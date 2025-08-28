// lib/screens/review_screen.dart (esqueleto)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/session_provider.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<SessionProvider>();
    final data = s.extractedData ?? {};
    final alerts = s.alerts;
    return Scaffold(
      appBar: AppBar(title: const Text('Revisão')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Pessoa: ${data['pessoa'] ?? ''}'),
          Text('Atividade: ${data['atividade'] ?? ''}'),
          Text('Cultura: ${data['cultura'] ?? ''}'),
          Text('Talhão: ${data['talhao'] ?? ''}'),
          Text('Valor: ${data['valor'] ?? ''}'),
          const SizedBox(height: 12),
          const Text('Alertas:'),
          for (final a in alerts) Text('• $a'),
          const SizedBox(height: 20),
          FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Editar novamente')),
          OutlinedButton(onPressed: () {/* confirmar */}, child: const Text('Confirmar')),
        ],
      ),
    );
  }
}
