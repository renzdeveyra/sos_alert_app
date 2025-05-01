import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  final SpeechToText _speech = SpeechToText();
  final Function(String) onTriggerDetected;
  bool _isListening = false;
  String _triggerPhrase = '';

  VoiceService({required this.onTriggerDetected});

  Future<bool> initialize() async {
    final available = await _speech.initialize();
    return available;
  }

  void setTriggerPhrase(String phrase) {
    _triggerPhrase = phrase.toLowerCase();
  }

  void startListening() {
    if (!_isListening && _speech.isAvailable) {
      _speech.listen(
        onResult: (result) {
          if (result.recognizedWords.toLowerCase().contains(_triggerPhrase)) {
            onTriggerDetected(_triggerPhrase);
          }
        },
      );
      _isListening = true;
    }
  }

  void stopListening() {
    if (_isListening) {
      _speech.stop();
      _isListening = false;
    }
  }
}
