import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/session_provider.dart';
import 'dart:async';

class FarmEntry {
  final String id;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final String status; // 'processando', 'concluido', 'erro'
  final Map<String, dynamic>? extractedData;

  FarmEntry({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    this.status = 'processando',
    this.extractedData,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<FarmEntry> _farmEntries = [];
  bool _isRecording = false;
  Duration _recordDuration = Duration.zero;
  Timer? _recordTimer;

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    setState(() {
      _farmEntries = [
        FarmEntry(
          id: '1',
          title: 'Aplicação de Defensivo - Talhão 5',
          subtitle: 'Cultura: Soja • Valor: R\$ 1.200,00',
          timestamp: DateTime.now().subtract(Duration(hours: 2)),
          status: 'concluido',
          extractedData: {
            'atividade': 'aplicacao_defensivo',
            'cultura': 'soja',
            'talhao': '5',
            'valor': 1200.00,
            'pessoa': 'João Silva',
          },
        ),
        FarmEntry(
          id: '2',
          title: 'Plantio - Talhão 12',
          subtitle: 'Cultura: Milho • Área: 15 hectares',
          timestamp: DateTime.now().subtract(Duration(days: 1)),
          status: 'concluido',
          extractedData: {
            'atividade': 'plantio',
            'cultura': 'milho',
            'talhao': '12',
            'area': 15.0,
            'pessoa': 'Maria Santos',
          },
        ),
        FarmEntry(
          id: '3',
          title: 'Colheita - Talhão 8',
          subtitle: 'Cultura: Soja • Produtividade: 58 sc/ha',
          timestamp: DateTime.now().subtract(Duration(days: 2)),
          status: 'concluido',
          extractedData: {
            'atividade': 'colheita',
            'cultura': 'soja',
            'talhao': '8',
            'produtividade': 58.0,
            'pessoa': 'Pedro Costa',
          },
        ),
      ];
    });
  }

  Future<void> _startRecording() async {
    setState(() {
      _isRecording = true;
      _recordDuration = Duration.zero;
    });

    _recordTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _recordDuration = Duration(seconds: _recordDuration.inSeconds + 1);
      });
    });

    // Simula início da gravação
    if (mounted) {
      context.read<SessionProvider>().setListening(true);
    }
  }

  Future<void> _stopRecording() async {
    _recordTimer?.cancel();

    setState(() {
      _isRecording = false;
    });

    if (mounted) {
      context.read<SessionProvider>().setListening(false);
    }

    // Simula criação de nova entrada
    final newEntry = FarmEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Processando áudio...',
      subtitle: 'Duração: ${_formatDuration(_recordDuration)}',
      timestamp: DateTime.now(),
      status: 'processando',
    );

    setState(() {
      _farmEntries.insert(0, newEntry);
    });

    // Simula processamento
    _processAudio(newEntry.id);
  }

  Future<void> _processAudio(String entryId) async {
    // Simula delay de processamento
    await Future.delayed(Duration(seconds: 3));

    // Lista de exemplos aleatórios
    final examples = [
      {
        'title': 'Aplicação de Fertilizante - Talhão 7',
        'subtitle': 'Cultura: Milho • Valor: R\$ 850,00',
        'data': {
          'atividade': 'aplicacao_fertilizante',
          'cultura': 'milho',
          'talhao': '7',
          'valor': 850.00,
          'pessoa': 'Carlos Lima',
        }
      },
      {
        'title': 'Irrigação - Talhão 3',
        'subtitle': 'Cultura: Tomate • Tempo: 4 horas',
        'data': {
          'atividade': 'irrigacao',
          'cultura': 'tomate',
          'talhao': '3',
          'tempo': 4.0,
          'pessoa': 'Ana Paula',
        }
      },
      {
        'title': 'Controle de Pragas - Talhão 15',
        'subtitle': 'Cultura: Café • Produto: Inseticida',
        'data': {
          'atividade': 'controle_pragas',
          'cultura': 'cafe',
          'talhao': '15',
          'produto': 'inseticida',
          'pessoa': 'Roberto Silva',
        }
      },
    ];

    final example = examples[DateTime.now().second % examples.length];

    setState(() {
      final index = _farmEntries.indexWhere((entry) => entry.id == entryId);
      if (index != -1) {
        _farmEntries[index] = FarmEntry(
          id: entryId,
          title: example['title'] as String,
          subtitle: example['subtitle'] as String,
          timestamp: _farmEntries[index].timestamp,
          status: 'concluido',
          extractedData: example['data'] as Map<String, dynamic>,
        );
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds % 60);
    return '$minutes:$seconds';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final entryDate = DateTime(date.year, date.month, date.day);

    if (entryDate == today) {
      return _formatTime(date);
    } else if (entryDate == yesterday) {
      return 'Ontem';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildFarmEntry(FarmEntry entry) {
    Color statusColor;
    IconData statusIcon;

    switch (entry.status) {
      case 'processando':
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        break;
      case 'concluido':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'erro':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 0.5,
          ),
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Color(0xFF128C7E),
          radius: 25,
          child: Icon(
            Icons.agriculture,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          entry.title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(
            entry.subtitle,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatDate(entry.timestamp),
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
            SizedBox(height: 4),
            if (entry.status == 'processando')
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
              )
            else
              Icon(
                statusIcon,
                color: statusColor,
                size: 16,
              ),
          ],
        ),
        onTap: () {
          if (entry.status == 'concluido') {
            _showEntryDetails(entry);
          } else if (entry.status == 'erro') {
            _showRetryDialog(entry);
          }
        },
      ),
    );
  }

  void _showEntryDetails(FarmEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detalhes do Lançamento',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildDetailRow('Título:', entry.title),
                    _buildDetailRow('Data:', _formatDate(entry.timestamp)),
                    _buildDetailRow('Status:', entry.status.toUpperCase()),
                    if (entry.extractedData != null) ...[
                      SizedBox(height: 20),
                      Text(
                        'Dados Extraídos:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      ...entry.extractedData!.entries.map((e) =>
                          _buildDetailRow('${e.key.capitalize()}:', '${e.value}')
                      ),
                    ],
                    Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF128C7E),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text('Fechar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRetryDialog(FarmEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Erro no Processamento'),
        content: Text('Houve um erro ao processar este áudio. Deseja tentar novamente?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processAudio(entry.id);
            },
            child: Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'AgroVoz',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Color(0xFF128C7E),
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Busca em desenvolvimento')),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$value selecionado')),
              );
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'Configurações', child: Text('Configurações')),
              PopupMenuItem(value: 'Sobre', child: Text('Sobre')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _farmEntries.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.agriculture,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Nenhum lançamento ainda',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Toque no microfone para criar\nseu primeiro lançamento',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: _farmEntries.length,
              itemBuilder: (context, index) {
                return _buildFarmEntry(_farmEntries[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        width: 56,
        height: 56,
        child: FloatingActionButton(
          backgroundColor: _isRecording ? Colors.red : Color(0xFF128C7E),
          onPressed: _isRecording ? _stopRecording : _startRecording,
          child: _isRecording
              ? Icon(Icons.stop, color: Colors.white, size: 28)
              : Icon(Icons.mic, color: Colors.white, size: 28),
          elevation: 8,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomSheet: _isRecording
          ? Container(
        height: 80,
        width: double.infinity,
        color: Colors.red.withOpacity(0.1),
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Gravando...',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            Text(
              _formatDuration(_recordDuration),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
      )
          : null,
    );
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    super.dispose();
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
