import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl; // ex.: 'http://10.0.2.2:8000'
  ApiService(this.baseUrl);

  Future<Map<String, dynamic>> processarFala({
    required String texto,
    required String usuarioId,
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/processar-fala');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'texto': texto, 'usuario_id': usuarioId}),
    );
    if (res.statusCode != 200) {
      throw Exception('Erro HTTP ${res.statusCode}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
