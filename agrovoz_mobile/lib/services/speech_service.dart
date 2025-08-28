import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final _stt = SpeechToText();

  Future<bool> initialize() => _stt.initialize();

  Future<void> listen({
    required void Function(String) onText,
    String? localeId,
  }) async {
    await _stt.listen(
      localeId: localeId,
      onResult: (res) => onText(res.recognizedWords),
    );
  }

  Future<void> stop() => _stt.stop();
  bool get isListening => _stt.isListening;
}
