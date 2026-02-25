import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/ai_assistant_provider.dart';
import '../widgets/avatar_3d_widget.dart';
import 'shop_screen.dart';

/// Voice Call Screen - 3D Model with simple controls
class AICallScreen extends StatefulWidget {
  const AICallScreen({super.key});

  @override
  State<AICallScreen> createState() => _AICallScreenState();
}

class _AICallScreenState extends State<AICallScreen> {
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
            onPressed: () => Navigator.pop(context, true), // Allow pop
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
    // Direct call cut - no dialog
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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

                      // End Call Button (Center, Bigger)
                      GestureDetector(
                        onTap: () => _handleEndCall(context),
                        child: Container(
                          width: 70,
                          height: 70,
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
                            size: 32,
                          ),
                        ),
                      ),

                      const SizedBox(width: 40),

                      // Spacer to balance the layout (same width as shop button)
                      const SizedBox(width: 60),
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
