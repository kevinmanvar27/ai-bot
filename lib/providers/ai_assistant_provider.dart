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

  /// Handle microphone button press
  /// Uses Android native speech recognition
  Future<void> handleMicPress() async {
    if (_isMicActive) return;
    
    // Enable continuous listening mode when mic is pressed
    _continuousListening = true;

    _isMicActive = true;
    notifyListeners();

    try {
      // Step 1: Listening (show listening state)
      _currentState = AIState.listening;
      _currentEmotion = AIEmotion.neutral;
      notifyListeners();

      print('🎤 Starting speech recognition...');
      
      // Request microphone permission
      final hasPermission = await _voiceService.requestMicrophonePermission();
      if (!hasPermission) {
        await _voiceService.speak('Please grant microphone permission to use voice features.');
        _currentState = AIState.idle;
        _isMicActive = false;
        notifyListeners();
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
        await _voiceService.speak('Sorry, there was an error with the microphone.');
        _currentState = AIState.idle;
        _isMicActive = false;
        notifyListeners();
        return;
      } catch (e) {
        print('❌ Speech recognition error: $e');
        recognizedText = '';
      }
      
      if (recognizedText.trim().isEmpty) {
        print('⚠️ No speech detected');
        await _voiceService.speak('Sorry, I didn\'t hear anything. Please try again.');
        _currentState = AIState.idle;
        _isMicActive = false;
        notifyListeners();
        return;
      }

      print('✅ User said: $recognizedText');

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
        await _voiceService.speak(aiResponseText);
        
        // Wait for Google TTS to complete (estimate based on text length)
        final estimatedDuration = Duration(
          milliseconds: (aiResponseText.length * 80), // ~80ms per character
        );
        await Future.delayed(estimatedDuration);
      }
      
      // Check if user interrupted during speaking
      if (_isInterrupted) {
        print('⚠️ Speech was interrupted by user');
        return; // Exit early, don't restart mic (interrupt function will handle it)
      }
      
      // ElevenLabs already waits for completion internally
      print('✅ Voice playback completed');
      
      // Step 4: Return to Idle (but keep mic ready)
      _currentState = AIState.idle;
      _currentEmotion = AIEmotion.neutral;
      _isMicActive = false;
      notifyListeners();
      
      // Check if continuous mode is still ON before pausing
      if (!_continuousListening) {
        print('🛑 Continuous mode stopped, not restarting mic');
        return;
      }
      
      // Step 5: Natural pause before restarting mic (like real conversation)
      print('⏸️ Natural pause before listening again...');
      await Future.delayed(const Duration(milliseconds: 1000)); // 1 second pause
      
      // Check again after pause (user might have ended call during pause)
      if (_continuousListening) {
        print('🔄 Auto-restarting mic for continuous conversation...');
        handleMicPress();
      } else {
        print('🛑 Call ended during pause, not restarting mic');
      }

    } catch (e) {
      print('❌ Error in voice call: $e');
      await _voiceService.speak('Sorry, something went wrong. Please try again.');
      
      // Don't restart mic on error
      _continuousListening = false;
    } finally {
      // Step 4: Return to Idle
      _currentState = AIState.idle;
      _currentEmotion = AIEmotion.neutral;
      _isMicActive = false;
      notifyListeners();
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
  Future<void> interruptAndListen() async {
    if (_currentState != AIState.speaking) {
      // Only interrupt if AI is speaking
      return;
    }
    
    print('⚠️ User interrupting AI...');
    _isInterrupted = true;
    
    // Stop AI voice immediately
    _voiceService.stop();
    ElevenLabsService.stop();
    
    // Reset state
    _currentState = AIState.idle;
    _isMicActive = false;
    notifyListeners();
    
    // Small delay for audio to stop
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Start listening to user
    print('🎤 Starting to listen after interruption...');
    handleMicPress();
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
