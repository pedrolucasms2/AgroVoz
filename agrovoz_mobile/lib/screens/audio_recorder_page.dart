import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:async';

class AudioRecorderPage extends StatefulWidget {
  @override
  _AudioRecorderPageState createState() => _AudioRecorderPageState();
}

class AudioMessage {
  final String filePath;
  final DateTime timestamp;
  final Duration duration;

  AudioMessage({
    required this.filePath,
    required this.timestamp,
    required this.duration,
  });
}

class _AudioRecorderPageState extends State<AudioRecorderPage> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<AudioMessage> _audioMessages = [];
  bool _isRecording = false;
  String? _currentPlayingPath;
  Duration _recordDuration = Duration.zero;
  Timer? _recordTimer;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permissão de microfone necessária!')),
      );
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String filePath = '${appDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: filePath,
        );

        setState(() {
          _isRecording = true;
          _recordDuration = Duration.zero;
        });

        _recordTimer = Timer.periodic(Duration(seconds: 1), (timer) {
          setState(() {
            _recordDuration = Duration(seconds: _recordDuration.inSeconds + 1);
          });
        });
      }
    } catch (e) {
      print('Erro ao iniciar gravação: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      _recordTimer?.cancel();

      if (path != null) {
        final audioMessage = AudioMessage(
          filePath: path,
          timestamp: DateTime.now(),
          duration: _recordDuration,
        );

        setState(() {
          _audioMessages.insert(0, audioMessage); // Adiciona no topo como WhatsApp
          _isRecording = false;
        });
      }
    } catch (e) {
      print('Erro ao parar gravação: $e');
    }
  }

  Future<void> _playAudio(String filePath) async {
    try {
      if (_currentPlayingPath == filePath) {
        // Se já está tocando este áudio, para
        await _audioPlayer.stop();
        setState(() {
          _currentPlayingPath = null;
        });
      } else {
        // Para qualquer áudio atual e toca o novo
        await _audioPlayer.stop();
        await _audioPlayer.setFilePath(filePath);
        await _audioPlayer.play();

        setState(() {
          _currentPlayingPath = filePath;
        });

        _audioPlayer.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            setState(() {
              _currentPlayingPath = null;
            });
          }
        });
      }
    } catch (e) {
      print('Erro ao reproduzir: $e');
    }
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

  Widget _buildAudioMessage(AudioMessage message) {
    final bool isPlaying = _currentPlayingPath == message.filePath;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Align(
        alignment: Alignment.centerRight, // Como mensagens enviadas no WhatsApp
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Color(0xFF128C7E), // Verde do WhatsApp
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(4), // Cantinho típico do WhatsApp
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Botão play/pause
              GestureDetector(
                onTap: () => _playAudio(message.filePath),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),

              SizedBox(width: 8),

              // Barra de áudio (visual)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Simulação de forma de onda
                    Container(
                      height: 30,
                      child: Row(
                        children: List.generate(20, (index) {
                          return Container(
                            width: 3,
                            height: (index % 4 + 1) * 7.0,
                            margin: EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              color: isPlaying ? Colors.white : Colors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        }),
                      ),
                    ),

                    SizedBox(height: 4),

                    // Duração e horário
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(message.duration),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          _formatTime(message.timestamp),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE5DDD5), // Cor de fundo do WhatsApp
      appBar: AppBar(
        title: Text('AgroVoz', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF128C7E), // Verde do WhatsApp
        elevation: 1,
      ),
      body: Column(
        children: [
          // Lista de mensagens de áudio
          Expanded(
            child: _audioMessages.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.mic_none,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Nenhum áudio gravado ainda',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Toque no botão abaixo para gravar',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              reverse: true, // Como no WhatsApp, mensagens mais recentes embaixo
              padding: EdgeInsets.only(bottom: 80),
              itemCount: _audioMessages.length,
              itemBuilder: (context, index) {
                return _buildAudioMessage(_audioMessages[index]);
              },
            ),
          ),
        ],
      ),

      // Botão flutuante de gravação (estilo WhatsApp)
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Barra inferior durante gravação
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
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}
