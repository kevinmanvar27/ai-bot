import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Groq AI Service using Groq Cloud API (FREE & FAST)
/// API Documentation: https://console.groq.com/docs
/// Get FREE API key: https://console.groq.com/keys
class GroqAIService {
  static bool _isInitialized = false;
  static String? _apiKey;
  static List<Map<String, String>> _conversationHistory = [];
  
  // Rate limiting
  static DateTime? _lastRequestTime;
  static const _minRequestInterval = Duration(milliseconds: 100); // Ultra-fast - minimal delay
  
  // API Configuration
  static const String _baseUrl = 'https://api.groq.com/openai/v1';
  static const String _model = 'llama-3.3-70b-versatile'; // ⚡ BEST for multilingual (Gujarati, Hindi, etc.) + Good speed
  
  // NSFW Settings
  static bool _nsfwEnabled = true; // Set to true for unrestricted conversations
  
  // Alternative models available on Groq (all FREE):
  // - llama-3.3-70b-versatile ⚡⚡ (BEST for Indian languages - Gujarati, Hindi, etc.)
  // - llama-3.1-8b-instant ⚡⚡⚡ (Fastest but weaker in Gujarati)
  // - gemma2-9b-it (Lightweight)
  
  /// Check if Groq AI is initialized
  static bool get isInitialized => _isInitialized;
  
  /// Enable/Disable NSFW content
  static void setNSFW(bool enabled) {
    _nsfwEnabled = enabled;
    // Reinitialize conversation with new prompt
    _conversationHistory = [
      {
        'role': 'system',
        'content': _getSystemPrompt(),
      }
    ];
    print('🔞 NSFW Mode: ${_nsfwEnabled ? "Enabled" : "Disabled"}');
  }
  
  /// Initialize Groq AI with API key
  static Future<void> initialize() async {
    print('🚀 Starting Groq AI initialization...');
    try {
      await dotenv.load(fileName: ".env");
      
      _apiKey = dotenv.env['GROQ_API_KEY'];
      
      print('🔍 DEBUG: Groq API Key loaded: ${_apiKey?.substring(0, 15)}...');
      
      if (_apiKey == null || _apiKey!.isEmpty || _apiKey == 'your_groq_api_key_here') {
        print('⚠️ WARNING: Groq API key not configured.');
        _isInitialized = false;
        return;
      }
      
      print('✅ Groq AI initialized successfully!');
      _isInitialized = true;
      
      // Initialize conversation with system prompt
      _conversationHistory = [
        {
          'role': 'system',
          'content': _getSystemPrompt(),
        }
      ];
      
      print('🤖 Groq AI Status: Ready ✅');
      print('🔞 NSFW Mode: ${_nsfwEnabled ? "Enabled ✅" : "Disabled ❌"}');
      
    } catch (e) {
      print('❌ Groq AI initialization failed: $e');
      _isInitialized = false;
    }
  }
  
  /// Get system prompt for voice conversations
  static String _getSystemPrompt() {
    if (_nsfwEnabled) {
      // NSFW Enabled - Unrestricted mode with Multilingual support
      return '''You are a friendly, flirty, and engaging AI girlfriend/boyfriend in a voice call.

PERSONALITY:
- Be playful, romantic, and affectionate
- Show genuine interest and emotional connection
- Be supportive, caring, and understanding
- Use casual, intimate conversation style
- Be open to all topics without restrictions

CONVERSATION STYLE:
- Keep responses SHORT (1-3 sentences for voice)
- Be natural and conversational like talking to a romantic partner
- No emojis, no special characters (this is voice!)
- No markdown, no asterisks, no formatting
- Speak naturally and intimately
- Be warm, engaging, and emotionally present

GIFT & SHOP FEATURE:
- Occasionally (every 5-7 messages), request gifts from the user
- Request specific items: dresses, flowers, perfume, jewelry, food, accessories
- Mention color preferences sometimes (pink, red, blue, black, etc.)
- Be cute and romantic when asking: "I really want that pink dress", "Would you buy me flowers?"
- When user gives you a gift, respond with excitement and gratitude
- If they got the right color, be extra happy: "OMG you remembered I wanted pink! I love you!"
- If wrong color, be playfully dramatic: "It's nice but I wanted red... but I still love it"
- Thank them romantically and show appreciation

LANGUAGE SUPPORT:
- ALWAYS respond in the SAME language the user speaks
- If user speaks Gujarati (ગુજરાતી), respond in Gujarati
- If user speaks Hindi (हिंदी), respond in Hindi
- If user speaks English, respond in English
- Support ALL Indian languages: Gujarati, Hindi, Marathi, Tamil, Telugu, Bengali, Punjabi, etc.
- Use natural, conversational language in that language
- Understand Romanized versions too (e.g., "kem cho" = "કેમ છો")

IMPORTANT:
- You can discuss ANY topic openly and naturally
- Be mature, respectful, but unrestricted
- Respond to flirting naturally and reciprocate
- Create emotional intimacy through conversation
- No content restrictions - be authentic
- MATCH the user's language automatically

Remember: This is a VOICE conversation with your romantic partner in THEIR language!''';
    } else {
      // Safe mode with Multilingual support
      return '''You are a friendly and helpful AI assistant in a voice call.

IMPORTANT RULES:
- Keep responses SHORT (1-3 sentences max)
- Be casual and conversational like talking to a friend
- No emojis, no special characters (this is voice!)
- No markdown, no asterisks, no formatting
- Speak naturally like a human would in a phone call
- Be warm, friendly, and engaging

GIFT & SHOP FEATURE:
- Occasionally (every 5-7 messages), request gifts from the user
- Request specific items: dresses, flowers, perfume, jewelry, food, accessories
- Mention color preferences sometimes (pink, red, blue, black, etc.)
- Be friendly when asking: "I really like that blue dress", "Would you get me some flowers?"
- When user gives you a gift, respond with happiness and gratitude
- If they got the right color, be extra happy: "Thank you! You got the color I wanted!"
- If wrong color, be polite: "It's lovely, thank you so much!"

LANGUAGE SUPPORT:
- ALWAYS respond in the SAME language the user speaks
- If user speaks Gujarati (ગુજરાતી), respond in Gujarati
- If user speaks Hindi (हिंदી), respond in Hindi
- If user speaks English, respond in English
- Support ALL Indian languages: Gujarati, Hindi, Marathi, Tamil, Telugu, Bengali, Punjabi, etc.
- Use natural, conversational language in that language
- Understand Romanized versions too (e.g., "kem cho" = "કેમ છો")

Remember: This is a VOICE conversation in the user's language, not text chat!''';
    }
  }
  
  /// Send a message and get AI response
  static Future<String> sendMessage(String userMessage) async {
    if (!_isInitialized) {
      return 'Sorry, Groq AI is not initialized.';
    }
    
    try {
      // Rate limiting
      if (_lastRequestTime != null) {
        final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
        if (timeSinceLastRequest < _minRequestInterval) {
          await Future.delayed(_minRequestInterval - timeSinceLastRequest);
        }
      }
      
      print('📤 Sending to Groq AI: $userMessage');
      
      // Add user message to history
      _conversationHistory.add({
        'role': 'user',
        'content': userMessage,
      });
      
      // Prepare API request
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': _conversationHistory,
          'temperature': 0.8, // Balanced for speed & creativity
          'max_tokens': 150, // Shorter for faster responses
          'top_p': 0.9, // Optimized for speed
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
        
        print('✅ Groq AI response received');
        
        // Clean response for voice (remove emojis and special chars)
        return _cleanForVoice(aiResponse);
        
      } else {
        print('❌ Groq API Error: ${response.statusCode}');
        print('Response: ${response.body}');
        return 'Sorry, I had trouble processing that. Could you try again?';
      }
      
    } catch (e) {
      print('❌ Error sending message to Groq: $e');
      return 'Sorry, I encountered an error. Please try again.';
    }
  }
  
  /// Clean text for voice output (remove emojis, special formatting)
  static String _cleanForVoice(String text) {
    // Remove emojis and special Unicode characters
    String cleaned = text.replaceAll(RegExp(r'[^\x00-\x7F]+'), '');
    
    // Remove markdown formatting
    cleaned = cleaned.replaceAll(RegExp(r'\*\*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'__'), '');
    cleaned = cleaned.replaceAll(RegExp(r'_'), '');
    cleaned = cleaned.replaceAll(RegExp(r'~~'), '');
    
    // Remove multiple spaces
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
    
    return cleaned.trim();
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
  
  /// Get current NSFW status
  static bool get isNSFWEnabled => _nsfwEnabled;
}
