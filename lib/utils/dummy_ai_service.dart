import 'dart:math';
import '../models/message_model.dart';

/// Dummy AI service that simulates AI responses
/// TODO: Replace with real API integration in production
class DummyAIService {
  static final List<String> _dummyResponses = [
    "Hello! How can I help you today?",
    "That sounds interesting. Tell me more.",
    "Can you explain more about that?",
    "I understand what you mean.",
    "Let's think about that together.",
    "That's a great question!",
    "I'm here to assist you with anything you need.",
    "Could you provide more details?",
    "I see what you're saying.",
    "Let me help you with that.",
  ];

  static final Random _random = Random();

  /// Simulates AI response with random delay
  /// TODO: Replace with actual API call
  static Future<MessageModel> getAIResponse(String userMessage) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 1500 + _random.nextInt(1000)));

    final response = _dummyResponses[_random.nextInt(_dummyResponses.length)];

    return MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: response,
      isUser: false,
      timestamp: DateTime.now(),
    );
  }

  /// Returns a random emotion state
  static String getRandomEmotion() {
    final emotions = ['neutral', 'happy', 'thinking'];
    return emotions[_random.nextInt(emotions.length)];
  }

  /// Simulates voice recognition
  /// TODO: Integrate with real speech-to-text API
  static Future<String> simulateVoiceRecognition() async {
    await Future.delayed(const Duration(seconds: 2));
    final dummyVoiceInputs = [
      "Hello there",
      "What's the weather today?",
      "Tell me a joke",
      "How are you?",
      "Can you help me?",
    ];
    return dummyVoiceInputs[_random.nextInt(dummyVoiceInputs.length)];
  }
}
