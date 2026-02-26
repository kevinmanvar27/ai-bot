import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/ai_assistant_provider.dart';
import '../providers/shop_provider.dart';
import '../widgets/avatar_3d_widget.dart';
import 'shop_screen.dart';

/// Voice Call Screen - 3D Model with simple controls
class AICallScreen extends StatefulWidget {
  const AICallScreen({super.key});

  @override
  State<AICallScreen> createState() => _AICallScreenState();
}

class _AICallScreenState extends State<AICallScreen> {
  
  @override
  void dispose() {
    // Stop continuous listening when screen is disposed
    final aiProvider = Provider.of<AIAssistantProvider>(context, listen: false);
    aiProvider.stopContinuousListening();
    super.dispose();
  }
  
  Future<bool> _onWillPop() async {
    // Show dialog on back button press
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'End Call?',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Consumer<AIAssistantProvider>(
          builder: (context, aiProvider, child) => Text(
            'Are you sure you want to end this call with ${aiProvider.aiName}?',
            style: GoogleFonts.inter(
              color: const Color(0xFF94A3B8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Don't pop
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: const Color(0xFF94A3B8),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              // Stop continuous listening before ending
              final aiProvider = Provider.of<AIAssistantProvider>(context, listen: false);
              aiProvider.stopContinuousListening();
              Navigator.pop(context, true); // Allow pop
            },
            child: Text(
              'End Call',
              style: GoogleFonts.inter(
                color: const Color(0xFFEF4444),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    
    return shouldPop ?? false;
  }

  void _handleEndCall(BuildContext context) {
    // Stop continuous listening before ending call
    final aiProvider = Provider.of<AIAssistantProvider>(context, listen: false);
    aiProvider.stopContinuousListening();
    
    // Direct call cut - no dialog
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Check for gift requests from AI
    final aiProvider = Provider.of<AIAssistantProvider>(context, listen: false);
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    
    // Add gift request to shop if detected
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (aiProvider.lastGiftRequest != null) {
        shopProvider.addGiftRequest(aiProvider.lastGiftRequest!);
        aiProvider.clearLastGiftRequest();
        print('🎁 Gift request added to shop');
      }
    });
    
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Stack(
        children: [
          // Full screen 3D Model
          Positioned.fill(
            child: Consumer<AIAssistantProvider>(
              builder: (context, provider, child) {
                return Avatar3DWidget(
                  emotionColor: provider.emotionColor,
                  isActive: provider.currentState == AIState.speaking,
                );
              },
            ),
          ),

          // Status Text at Top
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Consumer<AIAssistantProvider>(
              builder: (context, aiProvider, child) {
                String statusText = '';
                Color statusColor = Colors.white;
                
                switch (aiProvider.currentState) {
                  case AIState.listening:
                    statusText = '🎤 Listening... (Speak now)';
                    statusColor = const Color(0xFF8B5CF6);
                    break;
                  case AIState.thinking:
                    statusText = '🤔 Thinking...';
                    statusColor = const Color(0xFF6366F1);
                    break;
                  case AIState.speaking:
                    statusText = '🔊 Speaking... (Tap to interrupt)';
                    statusColor = const Color(0xFFEC4899);
                    break;
                  default:
                    statusText = 'Tap mic to start conversation';
                    statusColor = const Color(0xFF94A3B8);
                }
                
                return Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      statusText,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Controls - Always Visible
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Shop Button
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ShopScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF1E293B),
                            border: Border.all(
                              color: const Color(0xFF8B5CF6).withOpacity(0.5),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF8B5CF6).withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.shopping_bag_outlined,
                            color: Color(0xFF8B5CF6),
                            size: 28,
                          ),
                        ),
                      ),

                      const SizedBox(width: 40),

                      // Microphone Button (Center)
                      Consumer<AIAssistantProvider>(
                        builder: (context, aiProvider, child) {
                          final isActive = aiProvider.isMicActive;
                          final isListening = aiProvider.currentState == AIState.listening;
                          final isSpeaking = aiProvider.currentState == AIState.speaking;
                          
                          return GestureDetector(
                            onTap: () {
                              if (isSpeaking) {
                                // If AI is speaking, interrupt and listen to user
                                aiProvider.interruptAndListen();
                              } else if (!isActive) {
                                // Normal mic press
                                aiProvider.handleMicPress();
                              }
                            },
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: isListening
                                    ? const LinearGradient(
                                        colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                                      )
                                    : isSpeaking
                                        ? const LinearGradient(
                                            colors: [Color(0xFFEC4899), Color(0xFFF97316)],
                                          )
                                        : null,
                                color: (isListening || isSpeaking) ? null : const Color(0xFF1E293B),
                                border: Border.all(
                                  color: isActive
                                      ? const Color(0xFF8B5CF6)
                                      : const Color(0xFF8B5CF6).withOpacity(0.5),
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isActive
                                        ? const Color(0xFF8B5CF6).withOpacity(0.6)
                                        : const Color(0xFF8B5CF6).withOpacity(0.3),
                                    blurRadius: isActive ? 25 : 15,
                                    spreadRadius: isActive ? 5 : 2,
                                  ),
                                ],
                              ),
                              child: Icon(
                                isListening 
                                    ? Icons.mic 
                                    : isSpeaking 
                                        ? Icons.pan_tool_rounded // Hand icon = "Stop & Listen"
                                        : Icons.mic_none,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(width: 40),

                      // End Call Button
                      GestureDetector(
                        onTap: () => _handleEndCall(context),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFEF4444),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFEF4444).withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.call_end,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
