import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  print('🔍 Testing Gemini AI connection...');
  
  try {
    // Load .env
    await dotenv.load(fileName: ".env");
    print('✅ .env file loaded');
    
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    print('🔑 API Key: ${apiKey?.substring(0, 10)}...');
    
    if (apiKey == null || apiKey.isEmpty) {
      print('❌ API key is null or empty');
      return;
    }
    
    // Initialize model
    print('🔄 Creating Gemini model...');
    final model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: apiKey,
    );
    
    print('✅ Model created successfully');
    
    // Test simple generation
    print('🔄 Testing simple generation...');
    final response = await model.generateContent([
      Content.text('Say hello in one sentence')
    ]);
    
    print('✅ Response received: ${response.text}');
    
    // Test chat session
    print('🔄 Testing chat session...');
    final chat = model.startChat();
    final chatResponse = await chat.sendMessage(
      Content.text('What is 2+2?')
    );
    
    print('✅ Chat response: ${chatResponse.text}');
    print('🎉 All tests passed!');
    
  } catch (e, stackTrace) {
    print('❌ Error: $e');
    print('Stack trace: $stackTrace');
  }
}
