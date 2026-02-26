import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message_model.dart';
import '../models/shop_item_model.dart';
import '../utils/dummy_ai_service.dart';
import '../utils/dummy_shop_data.dart';
import '../services/groq_ai_service.dart'; // Groq AI (FREE & FAST)
import '../services/voice_service.dart';
import '../services/elevenlabs_service.dart'; // ElevenLabs AI Voice

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
  bool _isTyping = false; // Typing indicator for AI response
  bool _continuousListening = false; // Flag for continuous conversation mode
  bool _isInterrupted = false; // Flag for user interruption during AI speaking
  bool _isProcessing = false; // Flag to prevent multiple simultaneous AI calls
  
  // Shop integration
  int _messageCount = 0;
  
  // Gender configuration
  String _aiGender = 'female'; // Default
  String _aiName = ''; // Will be loaded from SharedPreferences
  
  // Voice service instance
  final VoiceService _voiceService = VoiceService();
  
  // Platform channel for native speech recognition
  static const platform = MethodChannel('com.rektech.ai_assistant/speech');

  // Getters
  AIState get currentState => _currentState;
  AIEmotion get currentEmotion => _currentEmotion;
  List<MessageModel> get messages => List.unmodifiable(_messages);
  bool get isMicActive => _isMicActive;
  bool get isCameraActive => _isCameraActive;
  bool get isTyping => _isTyping; // Getter for typing state
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
    // Initialize Groq AI Service (FREE & FAST)
    await GroqAIService.initialize();
    
    // Load AI gender configuration from SharedPreferences FIRST
    final prefs = await SharedPreferences.getInstance();
    _aiGender = prefs.getString('ai_gender') ?? 'female';
    
    // Initialize ElevenLabs Voice Service with gender
    await ElevenLabsService.initialize(gender: _aiGender);
    
    // Initialize Voice Service (TTS fallback, recording will be initialized on first use)
    await _voiceService.initializeTTS();
    
    // Load custom AI name from SharedPreferences, or use default based on gender
    final savedName = prefs.getString('ai_custom_name');
    if (savedName != null && savedName.isNotEmpty) {
      _aiName = savedName;
    } else {
      // Only set default if no saved name exists
      _aiName = _aiGender == 'female' ? 'Radhika' : 'Arjun';
    }
    
    // Debug: Print loaded name
    print('🔍 DEBUG: Loaded AI name from SharedPreferences: $_aiName');
    print('🔍 DEBUG: AI gender: $_aiGender');
    print('🤖 Groq AI Status: ${GroqAIService.isInitialized ? "Connected ✅" : "Failed ❌"}');
    print('🎤 ElevenLabs Voice Status: ${ElevenLabsService.isInitialized ? "Connected ✅" : "Fallback to Google TTS"}');
    print('🎤 Voice Service Status: Ready ✅');
    
    _messages.add(MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: "Hello! I'm $_aiName, your AI assistant. How can I help you today?",
      isUser: false,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  /// Handle microphone button press (Start voice call)
  /// Mic stays ON throughout the call - like real phone call
  Future<void> handleMicPress() async {
    if (_isMicActive) return;
    
    // Enable continuous listening mode when call starts
    _continuousListening = true;
    _isMicActive = true; // Mic visually ALWAYS ON during call
    notifyListeners();
    
    print('📞 Voice call started - Mic ALWAYS ON');
    
    // Start continuous listening loop
    _startContinuousListeningLoop();
  }
  
  /// Continuous listening loop - like real phone call
  /// Mic listens ONLY when AI is not speaking (to avoid self-interruption)
  Future<void> _startContinuousListeningLoop() async {
    while (_continuousListening) {
      try {
        // CRITICAL FIX: Don't listen while AI is speaking or thinking
        // This prevents AI from hearing its own voice and interrupting itself
        if (_currentState == AIState.speaking || _currentState == AIState.thinking || _isProcessing) {
          print('🔇 AI is busy - skipping mic activation to avoid self-interruption');
          await Future.delayed(const Duration(milliseconds: 1000));
          continue;
        }
        
        // Step 1: Listening (only when AI is idle)
        _currentState = AIState.listening;
        _currentEmotion = AIEmotion.neutral;
        notifyListeners();

        print('🎤 Listening for user speech...');
        
        // Request microphone permission (first time only)
        final hasPermission = await _voiceService.requestMicrophonePermission();
        if (!hasPermission) {
          await _voiceService.speak('Please grant microphone permission to use voice features.');
          stopContinuousListening();
          return;
        }

        // Use Android's native speech recognition
        String recognizedText = '';
        try {
          final result = await platform.invokeMethod('startSpeechRecognition');
          recognizedText = result?.toString() ?? '';
          print('✅ Recognized text: "$recognizedText"');
        } on PlatformException catch (e) {
          print('❌ Speech recognition platform error: ${e.message}');
          // Continue listening on error (don't break the loop)
          await Future.delayed(const Duration(milliseconds: 2000));
          continue;
        } catch (e) {
          print('❌ Speech recognition error: $e');
          recognizedText = '';
        }
        
        // If no speech detected, continue listening immediately
        if (recognizedText.trim().isEmpty) {
          print('⚠️ No speech detected, continuing to listen...');
          await Future.delayed(const Duration(milliseconds: 2000));
          continue;
        }

        print('✅ User said: $recognizedText');
        
        // Double-check AI is not speaking before processing
        // (In case state changed during recognition)
        if (_currentState == AIState.speaking || _isProcessing) {
          print('⚠️ AI started speaking during recognition - discarding input to avoid self-interruption');
          await Future.delayed(const Duration(milliseconds: 2000));
          continue;
        }
        
        // Process the speech in a separate task (non-blocking)
        _processSpeech(recognizedText);
        
        // Continue listening immediately (don't wait for AI response)
        await Future.delayed(const Duration(milliseconds: 2000));
        
      } catch (e) {
        print('❌ Error in continuous listening loop: $e');
        await Future.delayed(const Duration(milliseconds: 500));
        // Continue loop on error
      }
    }
    
    // Loop ended - call was ended
    print('📞 Voice call ended');
    _currentState = AIState.idle;
    _currentEmotion = AIEmotion.neutral;
    _isMicActive = false;
    notifyListeners();
  }
  
  /// Process user speech (separate from listening loop)
  Future<void> _processSpeech(String recognizedText) async {
    if (_isProcessing) return;
    
    _isProcessing = true;
    
    try {
      // Step 2: Processing (Thinking)
      _currentState = AIState.thinking;
      _currentEmotion = AIEmotion.thinking;
      notifyListeners();

      print('🤖 Sending to AI...');
      
      // Get AI response using Groq AI
      String aiResponseText;
      if (GroqAIService.isInitialized) {
        aiResponseText = await GroqAIService.sendMessage(recognizedText);
      } else {
        aiResponseText = 'Sorry, Groq AI is currently unavailable.';
      }

      print('✅ AI response: $aiResponseText');
      
      // Detect if AI is requesting a gift
      _detectAndHandleGiftRequest(aiResponseText);

      // Step 3: Speaking
      _currentState = AIState.speaking;
      _currentEmotion = AIEmotion.happy;
      _isInterrupted = false; // Reset interruption flag
      notifyListeners();

      print('🔊 Speaking AI response...');
      
      // Try ElevenLabs first (high quality), fallback to Google TTS
      bool elevenLabsSuccess = false;
      if (ElevenLabsService.isInitialized) {
        elevenLabsSuccess = await ElevenLabsService.speak(aiResponseText);
      }
      
      if (!elevenLabsSuccess) {
        print('🔄 Falling back to Google TTS');
        // Google TTS speak() now waits for completion internally
        await _voiceService.speak(aiResponseText);
      }
      
      // Check if user interrupted during speaking
      if (_isInterrupted) {
        print('⚠️ Speech was interrupted by user');
        _isInterrupted = false; // Reset flag
      }
      
      // Both ElevenLabs and Google TTS now wait for completion
      print('✅ Voice playback completed');
      
      // Return to listening state
      if (_continuousListening) {
        _currentState = AIState.listening;
        _currentEmotion = AIEmotion.neutral;
        notifyListeners();
      }
      
    } catch (e) {
      print('❌ Error processing speech: $e');
    } finally {
      _isProcessing = false;
    }
  }

  /// Stop continuous listening mode (when call ends)
  void stopContinuousListening() {
    _continuousListening = false;
    _isMicActive = false;
    _currentState = AIState.idle;
    _currentEmotion = AIEmotion.neutral;
    
    // Stop all voice playback immediately
    _voiceService.stop();
    ElevenLabsService.stop();
    
    notifyListeners();
    print('🛑 Continuous listening stopped');
    print('🔇 All voice playback stopped');
  }
  
  /// Interrupt AI speaking (when user wants to speak during AI response)
  /// Note: Auto-interrupt is now handled in the listening loop
  Future<void> interruptAndListen() async {
    if (_currentState != AIState.speaking) {
      return;
    }
    
    print('⚠️ Manual interrupt triggered...');
    _isInterrupted = true;
    
    // Stop AI voice immediately
    _voiceService.stop();
    ElevenLabsService.stop();
    
    // Reset state to listening (loop will continue automatically)
    _currentState = AIState.listening;
    _currentEmotion = AIEmotion.neutral;
    notifyListeners();
    
    print('🎤 Interrupted - mic continues listening...');
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

    // Show typing indicator
    _isTyping = true;
    _currentState = AIState.thinking;
    _currentEmotion = AIEmotion.thinking;
    notifyListeners();

    // Get AI response using Groq AI
    String aiResponseText;
    if (GroqAIService.isInitialized) {
      aiResponseText = await GroqAIService.sendMessage(text);
    } else {
      aiResponseText = 'Sorry, Groq AI is currently unavailable.';
    }
    
    // Create AI message model
    final aiResponse = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: aiResponseText,
      isUser: false,
      timestamp: DateTime.now(),
    );
    
    // Hide typing indicator
    _isTyping = false;
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
  
  /// Add AI's reaction message to chat and speak it in voice call
  Future<void> addReactionMessage(String reaction) async {
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
    
    // If in voice call mode (continuous listening), speak the reaction
    if (_continuousListening && !_isProcessing) {
      print('🎁 Speaking gift reaction in voice call...');
      
      // CRITICAL: Set processing flag to prevent listening loop interference
      _isProcessing = true;
      
      // Set speaking state
      _currentState = AIState.speaking;
      notifyListeners();
      
      // Remove emojis for voice
      final cleanReaction = reaction.replaceAll(RegExp(r'[😍🥰💕😐😔🥺💖✨😊]'), '').trim();
      
      try {
        // Speak the reaction
        bool elevenLabsSuccess = false;
        if (ElevenLabsService.isInitialized) {
          elevenLabsSuccess = await ElevenLabsService.speak(cleanReaction);
        }
        
        if (!elevenLabsSuccess) {
          await _voiceService.speak(cleanReaction);
        }
        
        print('✅ Gift reaction spoken');
      } finally {
        // Always release processing flag
        _isProcessing = false;
        
        // Return to listening state
        if (_continuousListening) {
          _currentState = AIState.listening;
          notifyListeners();
        }
      }
    }
  }
  
  /// Detect if AI is requesting a gift from the response
  void _detectAndHandleGiftRequest(String aiResponse) {
    final lowerResponse = aiResponse.toLowerCase();
    
    // Gift request keywords
    final requestKeywords = [
      'want', 'need', 'buy', 'get me', 'gift', 'give me',
      'would you', 'can you', 'please', 'i like', 'i love',
      'chahiye', 'chaiye', 'de do', 'la do', 'kharid do', // Hindi
      'joie', 'apo', 'lavo', 'khariduvu', // Gujarati
    ];
    
    // Check if AI is requesting something
    bool isRequest = requestKeywords.any((keyword) => lowerResponse.contains(keyword));
    if (!isRequest) return;
    
    // Get all shop items
    final allItems = DummyShopData.getAllItems();
    
    // Try to find matching item in the response
    ShopItem? matchedItem;
    String? matchedColor;
    
    for (var item in allItems) {
      // Check if item name is mentioned
      if (lowerResponse.contains(item.name.toLowerCase())) {
        matchedItem = item;
        
        // Try to find color mention
        for (var color in item.colors) {
          if (lowerResponse.contains(color.toLowerCase())) {
            matchedColor = color;
            break;
          }
        }
        break;
      }
      
      // Check for category keywords
      if (item.category == 'gifts') {
        if ((lowerResponse.contains('flower') || lowerResponse.contains('phool')) && 
            item.name.contains('Rose')) {
          matchedItem = item;
        } else if ((lowerResponse.contains('perfume') || lowerResponse.contains('scent')) && 
                   item.name.contains('Perfume')) {
          matchedItem = item;
        } else if ((lowerResponse.contains('teddy') || lowerResponse.contains('bear')) && 
                   item.name.contains('Teddy')) {
          matchedItem = item;
        }
      } else if (item.category == 'clothing') {
        if ((lowerResponse.contains('dress') || lowerResponse.contains('kapde')) && 
            item.name.contains('Dress')) {
          matchedItem = item;
        } else if ((lowerResponse.contains('jacket') || lowerResponse.contains('coat')) && 
                   item.name.contains('Jacket')) {
          matchedItem = item;
        } else if ((lowerResponse.contains('shoe') || lowerResponse.contains('jute')) && 
                   item.name.contains('Sneakers')) {
          matchedItem = item;
        }
      } else if (item.category == 'accessories') {
        if ((lowerResponse.contains('bag') || lowerResponse.contains('purse')) && 
            item.name.contains('Handbag')) {
          matchedItem = item;
        } else if ((lowerResponse.contains('ring') || lowerResponse.contains('anguthi')) && 
                   item.name.contains('Ring')) {
          matchedItem = item;
        } else if ((lowerResponse.contains('watch') || lowerResponse.contains('ghadi')) && 
                   item.name.contains('Watch')) {
          matchedItem = item;
        }
      } else if (item.category == 'food') {
        if ((lowerResponse.contains('cake') || lowerResponse.contains('pastry')) && 
            item.name.contains('Cake')) {
          matchedItem = item;
        } else if ((lowerResponse.contains('coffee') || lowerResponse.contains('chai')) && 
                   item.name.contains('Coffee')) {
          matchedItem = item;
        } else if ((lowerResponse.contains('ice cream') || lowerResponse.contains('icecream')) && 
                   item.name.contains('Ice Cream')) {
          matchedItem = item;
        }
      }
      
      if (matchedItem != null) {
        // Try to find color in response
        for (var color in matchedItem.colors) {
          if (lowerResponse.contains(color.toLowerCase())) {
            matchedColor = color;
            break;
          }
        }
        break;
      }
    }
    
    // If item matched, create gift request
    if (matchedItem != null) {
      print('🎁 Gift request detected: ${matchedItem.name} ${matchedColor ?? ""}');
      
      // Create gift request
      final request = GiftRequest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        requestedItem: matchedItem,
        preferredColor: matchedColor,
        requestMessage: aiResponse,
        requestDate: DateTime.now(),
      );
      
      // Store request for later retrieval
      _lastGiftRequest = request;
      print('🎁 Gift request created: ${matchedItem.name} in ${matchedColor ?? "any color"}');
    }
  }
  
  // Store last gift request
  GiftRequest? _lastGiftRequest;
  GiftRequest? get lastGiftRequest => _lastGiftRequest;
  void clearLastGiftRequest() => _lastGiftRequest = null;

  /// Toggle camera
  void toggleCamera() {
    _isCameraActive = !_isCameraActive;
    notifyListeners();
  }

  /// Clear chat history
  void clearChat() {
    _messages.clear();
    GroqAIService.clearHistory(); // Reset AI conversation context
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
