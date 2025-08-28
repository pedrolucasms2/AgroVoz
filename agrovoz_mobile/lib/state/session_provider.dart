import 'package:flutter/foundation.dart';

class SessionProvider extends ChangeNotifier {
  bool _isListening = false;
  String _recognizedText = '';
  Map<String, dynamic>? _extractedData;
  List<String> _alerts = [];

  bool get isListening => _isListening;
  String get recognizedText => _recognizedText;
  Map<String, dynamic>? get extractedData => _extractedData;
  List<String> get alerts => _alerts;

  void setListening(bool listening) {
    _isListening = listening;
    notifyListeners();
  }

  void setRecognizedText(String text) {
    _recognizedText = text;
    notifyListeners();
  }

  void setNlpResult(Map<String, dynamic> data, List<String> alerts) {
    _extractedData = data;
    _alerts = alerts;
    notifyListeners();
  }

  void clearSession() {
    _isListening = false;
    _recognizedText = '';
    _extractedData = null;
    _alerts = [];
    notifyListeners();
  }
}
