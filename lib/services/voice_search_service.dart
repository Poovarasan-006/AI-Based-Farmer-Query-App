import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceSearchService {
  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  String _recognizedText = '';

  VoiceSearchService() {
    _speechToText = stt.SpeechToText();
  }

  Future<void> initializeSpeechToText() async {
    try {
      bool available = await _speechToText.initialize(
        onError: (error) => print('Error: $error'),
        onStatus: (status) => print('Status: $status'),
      );
      if (!available) {
        print('Speech to Text not available');
      }
    } catch (e) {
      print('Error initializing speech to text: $e');
    }
  }

  Future<void> startListening(
      {Function(String)? onRecognitionResult}) async {
    if (!_isListening) {
      try {
        bool available = await _speechToText.initialize();
        if (available) {
          _isListening = true;
          _speechToText.listen(
            onResult: (result) {
              _recognizedText = result.recognizedWords;
              if (onRecognitionResult != null) {
                onRecognitionResult(_recognizedText);
              }
            },
          );
        }
      } catch (e) {
        print('Error starting to listen: $e');
      }
    }
  }

  void stopListening() {
    if (_isListening) {
      _speechToText.stop();
      _isListening = false;
    }
  }

  String getRecognizedText() {
    return _recognizedText;
  }

  bool isListening() {
    return _isListening;
  }

  void clearRecognizedText() {
    _recognizedText = '';
  }
}