import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message_model.dart';
import '../models/shop_item_model.dart';
import '../utils/dummy_ai_service.dart';
import '../utils/dummy_shop_data.dart';

/// AI Assistant state management provider
class AIAssistantProvider with ChangeNotifier {
  // AI States
  AIState _currentState = AIState.idle;
  AIEmotion _currentEmotion = AIEmotion.neutral;
  
  // Chat messages
  final List<MessageModel> _messages = [];
  
  // Control states
  bool _isMicActive = false;
  bool _isCameraActive = false;
  
  // Shop integration
  int _messageCount = 0;
  
  // Gender configuration
  String _aiGender = 'female'; // Default
  String _aiName = 'Radhika'; // Default female name

  // Getters
  AIState get currentState => _currentState;
  AIEmotion get currentEmotion => _currentEmotion;
  List<MessageModel> get messages => List.unmodifiable(_messages);
  bool get isMicActive => _isMicActive;
  bool get isCameraActive => _isCameraActive;
  String get aiGender => _aiGender;
  String get aiName => _aiName;

  String get statusText {
    switch (_currentState) {
      case AIState.idle:
        return "Hi! I'm $_aiName";
      case AIState.listening:
        return "Listening...";
      case AIState.thinking:
        return "Thinking...";
      case AIState.speaking:
        return "Speaking...";
    }
  }

  Color get emotionColor {
    switch (_currentEmotion) {
      case AIEmotion.neutral:
        return const Color(0xFF8B5CF6); // Purple
      case AIEmotion.happy:
        return const Color(0xFFEC4899); // Pink
      case AIEmotion.thinking:
        return const Color(0xFF3B82F6); // Blue
    }
  }

  /// Initialize with welcome message
  Future<void> initialize() async {
    // Load AI gender configuration from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    _aiGender = prefs.getString('ai_gender') ?? 'female';
    
    // Load custom AI name from SharedPreferences, or use default based on gender
    _aiName = prefs.getString('ai_custom_name') ?? (_aiGender == 'female' ? 'Radhika' : 'Arjun');
    
    // Debug: Print loaded name
    print('🔍 DEBUG: Loaded AI name from SharedPreferences: $_aiName');
    print('🔍 DEBUG: AI gender: $_aiGender');
    
    _messages.add(MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: "Hello! I'm $_aiName, your AI assistant. How can I help you today?",
      isUser: false,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  /// Handle microphone button press
  /// Simulates: Listening → Thinking → Speaking → Idle cycle
  Future<void> handleMicPress() async {
    if (_isMicActive) return;

    _isMicActive = true;
    notifyListeners();

    // Step 1: Listening
    _currentState = AIState.listening;
    notifyListeners();

    // TODO: Integrate real speech-to-text API here
    final voiceInput = await DummyAIService.simulateVoiceRecognition();
    
    // Add user message
    _messages.add(MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: voiceInput,
      isUser: true,
      timestamp: DateTime.now(),
    ));

    // Step 2: Thinking
    _currentState = AIState.thinking;
    _currentEmotion = AIEmotion.thinking;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    // TODO: Integrate real AI API here
    final aiResponse = await DummyAIService.getAIResponse(voiceInput);
    _messages.add(aiResponse);

    // Step 3: Speaking
    _currentState = AIState.speaking;
    _currentEmotion = AIEmotion.happy;
    notifyListeners();

    // TODO: Integrate text-to-speech API here
    await Future.delayed(const Duration(seconds: 3));

    // Step 4: Return to Idle
    _currentState = AIState.idle;
    _currentEmotion = AIEmotion.neutral;
    _isMicActive = false;
    notifyListeners();
  }

  /// Handle text message send
  Future<void> sendTextMessage(String text, {Function(GiftRequest)? onGiftRequest}) async {
    if (text.trim().isEmpty) return;

    // Add user message
    _messages.add(MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    _messageCount++;
    notifyListeners();

    // Simulate AI thinking
    _currentState = AIState.thinking;
    _currentEmotion = AIEmotion.thinking;
    notifyListeners();

    // TODO: Replace with real API call
    final aiResponse = await DummyAIService.getAIResponse(text);
    _messages.add(aiResponse);

    // Check if AI should make a gift request
    if (DummyShopData.shouldMakeRequest(_messageCount) && onGiftRequest != null) {
      await Future.delayed(const Duration(milliseconds: 500));
      _makeGiftRequest(onGiftRequest);
    }

    // Random emotion for variety
    final emotion = DummyAIService.getRandomEmotion();
    _currentEmotion = emotion == 'happy' 
        ? AIEmotion.happy 
        : emotion == 'thinking' 
            ? AIEmotion.thinking 
            : AIEmotion.neutral;

    _currentState = AIState.idle;
    notifyListeners();
  }
  
  /// Make AI request a gift
  void _makeGiftRequest(Function(GiftRequest) onGiftRequest) {
    final item = DummyShopData.getRandomRequestItem();
    final preferredColor = item.colors.isNotEmpty ? item.colors.first : null;
    final requestMessage = DummyShopData.getRequestMessage(item, preferredColor);
    
    // Add request message to chat
    _messages.add(MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: requestMessage,
      isUser: false,
      timestamp: DateTime.now(),
    ));
    
    // Create gift request
    final request = GiftRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      requestedItem: item,
      preferredColor: preferredColor,
      requestMessage: requestMessage,
      requestDate: DateTime.now(),
    );
    
    // Notify parent to add to shop provider
    onGiftRequest(request);
    
    notifyListeners();
  }
  
  /// Add AI's reaction message to chat
  void addReactionMessage(String reaction) {
    _messages.add(MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: reaction,
      isUser: false,
      timestamp: DateTime.now(),
    ));
    
    // Set emotion based on reaction
    if (reaction.contains('😍') || reaction.contains('🥰') || reaction.contains('💕')) {
      _currentEmotion = AIEmotion.happy;
    } else {
      _currentEmotion = AIEmotion.neutral;
    }
    
    notifyListeners();
  }

  /// Toggle camera
  void toggleCamera() {
    _isCameraActive = !_isCameraActive;
    notifyListeners();
  }

  /// Clear chat history
  void clearChat() {
    _messages.clear();
    initialize();
  }
}

/// AI State enum
enum AIState {
  idle,
  listening,
  thinking,
  speaking,
}

/// AI Emotion enum
enum AIEmotion {
  neutral,
  happy,
  thinking,
}
