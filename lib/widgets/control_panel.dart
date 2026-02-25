import 'package:flutter/material.dart';
import 'dart:ui';

/// Bottom control panel with glassmorphism effect
class ControlPanel extends StatelessWidget {
  final VoidCallback onMicPressed;
  final VoidCallback onCameraToggle;
  final VoidCallback onEndCall;
  final VoidCallback onChatPressed;
  final bool isMicActive;
  final bool isCameraActive;

  const ControlPanel({
    super.key,
    required this.onMicPressed,
    required this.onCameraToggle,
    required this.onEndCall,
    required this.onChatPressed,
    required this.isMicActive,
    required this.isCameraActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: const Color(0xFF1E293B).withOpacity(0.8),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Camera toggle
              _ControlButton(
                icon: isCameraActive ? Icons.videocam : Icons.videocam_off,
                onPressed: onCameraToggle,
                color: isCameraActive ? const Color(0xFF8B5CF6) : Colors.white,
                size: 50,
              ),
              
              // Mic button (large, center)
              _ControlButton(
                icon: isMicActive ? Icons.mic : Icons.mic_none,
                onPressed: onMicPressed,
                color: const Color(0xFF8B5CF6),
                size: 70,
                isActive: isMicActive,
              ),
              
              // Chat button
              _ControlButton(
                icon: Icons.chat_bubble_outline,
                onPressed: onChatPressed,
                color: Colors.white,
                size: 50,
              ),
              
              // End call button
              _ControlButton(
                icon: Icons.call_end,
                onPressed: onEndCall,
                color: const Color(0xFFEF4444),
                size: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final double size;
  final bool isActive;

  const _ControlButton({
    required this.icon,
    required this.onPressed,
    required this.color,
    required this.size,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive 
              ? color.withOpacity(0.3) 
              : Colors.white.withOpacity(0.1),
          border: Border.all(
            color: color.withOpacity(isActive ? 1.0 : 0.5),
            width: 2,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: color,
          size: size * 0.5,
        ),
      ),
    );
  }
}
