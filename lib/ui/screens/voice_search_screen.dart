import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:ai_based_farmer_query_app/services/rag_service.dart';
import 'package:ai_based_farmer_query_app/services/voice_search_service.dart';
import 'package:ai_based_farmer_query_app/ui/widgets/search_result_item.dart';
import 'package:ai_based_farmer_query_app/ui/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

class VoiceSearchScreen extends StatefulWidget {
  const VoiceSearchScreen({super.key});

  @override
  State<VoiceSearchScreen> createState() => _VoiceSearchScreenState();
}

class _VoiceSearchScreenState extends State<VoiceSearchScreen> {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _hasSpeech = false;
  bool _isListening = false;
  String _spokenText = '';
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    bool hasSpeech = await _speechToText.initialize(
      onStatus: (status) {
        print('Speech status: $status');
      },
      onError: (error) {
        print('Speech error: $error');
        setState(() {
          _errorMessage = 'Speech recognition error: ${error.errorMsg}';
        });
      },
    );

    if (mounted) {
      setState(() {
        _hasSpeech = hasSpeech;
      });
    }
  }

  Future<void> _startListening() async {
    if (!_hasSpeech || _isListening) return;

    setState(() {
      _isListening = true;
      _spokenText = '';
      _searchResults = [];
      _errorMessage = '';
    });

    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          _spokenText = result.recognizedWords;
          if (result.finalResult) {
            _isListening = false;
            _performSearch(_spokenText);
          }
        });
      },
      localeId: 'en_IN', // Indian English
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
    );
  }

  Future<void> _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
    
    if (_spokenText.isNotEmpty) {
      _performSearch(_spokenText);
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _searchResults = [];
      _errorMessage = '';
      _lastQuery = query;
    });

    try {
      final ragService = Provider.of<RAGService>(context, listen: false);
      final results = await ragService.search(query);
      
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error performing search: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Search'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Voice Input Section
            _buildVoiceInputSection(),
            
            const SizedBox(height: 20),
            
            // Instructions
            _buildInstructions(),
            
            const SizedBox(height: 20),
            
            // Results Section
            Expanded(
              child: _buildResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceInputSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Microphone Icon and Status
            _buildMicrophoneStatus(),
            
            const SizedBox(height: 20),
            
            // Voice Input Text
            _buildVoiceInputText(),
            
            const SizedBox(height: 20),
            
            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildMicrophoneStatus() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer circle
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: _isListening
                ? const LinearGradient(
                    colors: [Color(0xFFFF5252), Color(0xFFFF1744)],
                  )
                : const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                  ),
            boxShadow: [
              BoxShadow(
                color: _isListening ? Colors.red.withOpacity(0.3) : Colors.green.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        
        // Inner microphone icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            _isListening ? Icons.mic : Icons.mic_none,
            size: 40,
            color: _isListening ? const Color(0xFFFF5252) : const Color(0xFF4CAF50),
          ),
        ),
        
        // Listening animation rings
        if (_isListening)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _AnimationController(
                duration: const Duration(seconds: 2),
                vsync: this,
              )..repeat(),
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.5,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFF5252).withOpacity(0.5),
                        width: 4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildVoiceInputText() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _spokenText.isNotEmpty
            ? _spokenText
            : _isListening
                ? 'Listening... Speak now'
                : 'Tap the microphone to start speaking',
        style: TextStyle(
          fontSize: _spokenText.isNotEmpty ? 16 : 14,
          color: _spokenText.isNotEmpty ? Colors.black87 : Colors.black54,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Start Listening Button
        ElevatedButton(
          onPressed: _hasSpeech && !_isListening ? _startListening : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.mic, size: 20),
              SizedBox(width: 8),
              Text('Start Listening'),
            ],
          ),
        ),
        
        // Stop Listening Button
        ElevatedButton(
          onPressed: _isListening ? _stopListening : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF5252),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.stop, size: 20),
              SizedBox(width: 8),
              Text('Stop'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Voice Search Tips',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          _buildInstructionItem('Speak clearly and naturally'),
          _buildInstructionItem('Use specific farming terms'),
          _buildInstructionItem('Try queries like: "How to treat crop disease?"'),
          _buildInstructionItem('You can speak in Hindi or English'),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 16, color: Color(0xFF4CAF50)),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_isLoading) {
      return const LoadingIndicator();
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          _errorMessage,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_searchResults.isEmpty && _lastQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No results found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Query: "$_lastQuery"',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black38,
              ),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Results for: "$_lastQuery"',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final result = _searchResults[index];
                return SearchResultItem(
                  title: result['title'] ?? 'Query Result',
                  description: result['content'] ?? result['description'] ?? '',
                  category: result['category'] ?? 'General',
                  onTap: () {
                    _showResultDetails(result);
                  },
                );
              },
            ),
          ),
        ],
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.mic,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Ready to Listen',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the microphone to start your voice query',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  void _showResultDetails(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(result['title'] ?? 'Query Result'),
        content: SingleChildScrollView(
          child: Text(result['content'] ?? result['description'] ?? ''),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// Simple animation controller for the listening rings
class _AnimationController extends AnimationController {
  _AnimationController({required Duration duration, required TickerProvider vsync})
      : super(duration: duration, vsync: vsync);
}