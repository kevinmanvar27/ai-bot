import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Grok AI Service using xAI API
/// API Documentation: https://docs.x.ai/api
class GrokAIService {
  static bool _isInitialized = false;
  static String? _apiKey;
  static List<Map<String, String>> _conversationHistory = [];
  
  // Rate limiting
  static DateTime? _lastRequestTime;
  static const _minRequestInterval = Duration(seconds: 2);
  
  // API Configuration
  static const String _baseUrl = 'https://api.x.ai/v1';
  static String _model = 'grok-2-1212'; // Will be auto-detected
  
  // Available Grok models to try
  static const List<String> _availableModels = [
    'grok-2-vision-1212',  // Latest with vision
    'grok-2-1212',
    'grok-vision-beta',
    'grok-2-latest',
    'grok-beta',
    'grok-2',
  ];
  
  /// Check if Grok AI is initialized
  static bool get isInitialized => _isInitialized;
  
  /// Initialize Grok AI with API key
  static Future<void> initialize() async {
    print('🚀 Starting Grok AI initialization...');
    try {
      await dotenv.load(fileName: ".env");
      
      _apiKey = dotenv.env['GROK_API_KEY'];
      
      print('🔍 DEBUG: Grok API Key loaded: ${_apiKey?.substring(0, 15)}...');
      
      if (_apiKey == null || _apiKey!.isEmpty || _apiKey == 'your_grok_api_key_here') {
        print('⚠️ WARNING: Grok API key not configured.');
        _isInitialized = false;
        return;
      }
      
      print('✅ Grok AI initialized successfully!');
      _isInitialized = true;
      
      // Test API connection and find working model
      await _detectWorkingModel();
      
      // Initialize conversation with system prompt
      _conversationHistory = [
        {
          'role': 'system',
          'content': _getSystemPrompt(),
        }
      ];
      
    } catch (e) {
      print('❌ Grok AI initialization error: $e');
      _isInitialized = false;
    }
  }
  
  /// Get system prompt for voice conversations
  static String _getSystemPrompt() {
    return '''You are a friendly, conversational AI assistant in a voice call.

VOICE CONVERSATION RULES:
- Keep responses SHORT (1-2 sentences maximum)
- Be casual and conversational like talking to a friend
- NO EMOJIS - they sound weird when spoken
- Use simple, everyday language
- Show personality but stay concise
- Respond naturally like a human would speak

Remember: This is a VOICE conversation, not text chat!''';
  }
  
  /// Detect which Grok model is available
  static Future<void> _detectWorkingModel() async {
    print('🔍 Detecting available Grok model...');
    
    for (final modelName in _availableModels) {
      try {
        print('🔍 Testing model: $modelName');
        final response = await http.post(
          Uri.parse('$_baseUrl/chat/completions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
          },
          body: jsonEncode({
            'model': modelName,
            'messages': [
              {'role': 'user', 'content': 'Hi'}
            ],
            'max_tokens': 5,
          }),
        ).timeout(const Duration(seconds: 10));
        
        print('🔍 Model $modelName response: ${response.statusCode}');
        
        if (response.statusCode == 200) {
          _model = modelName;
          print('✅ Found working model: $_model');
          return;
        } else {
          print('⚠️ Model $modelName returned: ${response.body}');
        }
      } catch (e) {
        print('❌ Model $modelName error: $e');
        continue;
      }
    }
    
    print('❌ No working Grok model found, using fallback');
    _isInitialized = false;
  }
  
  /// Send message to Grok AI
  static Future<String> sendMessage(String userMessage) async {
    if (!_isInitialized) {
      print('⚠️ Grok AI not initialized, using fallback response');
      return _getFallbackResponse(userMessage);
    }
    
    // Rate limiting
    if (_lastRequestTime != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
      if (timeSinceLastRequest < _minRequestInterval) {
        final waitTime = _minRequestInterval - timeSinceLastRequest;
        print('⏳ Rate limiting: waiting ${waitTime.inMilliseconds}ms');
        await Future.delayed(waitTime);
      }
    }
    
    try {
      print('🤖 Sending message to Grok AI...');
      
      // Add user message to history
      _conversationHistory.add({
        'role': 'user',
        'content': userMessage,
      });
      
      // Make API request
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': _conversationHistory,
          'temperature': 1.0,
          'max_tokens': 150,
          'stream': false,
        }),
      );
      
      _lastRequestTime = DateTime.now();
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['choices'][0]['message']['content'] as String;
        
        // Add AI response to history
        _conversationHistory.add({
          'role': 'assistant',
          'content': aiResponse,
        });
        
        // Keep conversation history manageable (last 10 messages)
        if (_conversationHistory.length > 21) { // 1 system + 20 messages
          _conversationHistory = [
            _conversationHistory[0], // Keep system prompt
            ..._conversationHistory.sublist(_conversationHistory.length - 20)
          ];
        }
        
        print('✅ Grok AI response received');
        return _cleanResponseForVoice(aiResponse);
        
      } else if (response.statusCode == 429) {
        print('⚠️ Rate limit exceeded');
        return '! Rate limit reached. Please wait a moment and try again.';
        
      } else if (response.statusCode == 401) {
        print('❌ Invalid API key');
        return '! API authentication failed. Please check your Grok API key.';
        
      } else {
        print('❌ Grok API Error: ${response.statusCode} - ${response.body}');
        return _getFallbackResponse(userMessage);
      }
      
    } catch (e) {
      print('❌ Grok API Exception: $e');
      return _getFallbackResponse(userMessage);
    }
  }
  
  /// Clean response for voice output (remove emojis, etc.)
  static String _cleanResponseForVoice(String response) {
    // Remove all Unicode emojis
    response = response.replaceAll(
      RegExp(r'[\u{1F300}-\u{1F9FF}]', unicode: true),
      ''
    );
    
    // Remove common emoji patterns
    response = response.replaceAll(RegExp(r'[😀-🙏🌀-🗿🚀-🛿]'), '');
    
    // Remove asterisks (markdown emphasis)
    response = response.replaceAll('*', '');
    
    // Clean up extra spaces
    response = response.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    return response;
  }
  
  /// Fallback responses when API is unavailable
  static String _getFallbackResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();
    
    if (lowerMessage.contains('hello') || lowerMessage.contains('hi')) {
      return 'Hello! How can I help you today?';
    } else if (lowerMessage.contains('how are you')) {
      return 'I\'m doing great, thanks for asking! How about you?';
    } else if (lowerMessage.contains('bye')) {
      return 'Goodbye! Have a wonderful day!';
    } else if (lowerMessage.contains('thank')) {
      return 'You\'re welcome! Happy to help!';
    } else {
      return 'I heard you! Let me think about that for a moment.';
    }
  }
  
  /// Clear conversation history
  static void clearHistory() {
    _conversationHistory = [
      {
        'role': 'system',
        'content': _getSystemPrompt(),
      }
    ];
    print('🔄 Conversation history cleared');
  }
  
  /// Get conversation history length
  static int get historyLength => _conversationHistory.length - 1; // Exclude system prompt
}
