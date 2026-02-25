import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

/// 3D Avatar widget with animations
class AvatarWidget extends StatefulWidget {
  final Color emotionColor;
  final bool isActive;

  const AvatarWidget({
    super.key,
    required this.emotionColor,
    this.isActive = false,
  });

  @override
  State<AvatarWidget> createState() => _AvatarWidgetState();
}

class _AvatarWidgetState extends State<AvatarWidget>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _blinkController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();

    // Breathing animation (subtle scale)
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Blink animation (periodic)
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _startBlinking();

    // Glow animation
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  void _startBlinking() {
    Future.delayed(Duration(seconds: 3 + math.Random().nextInt(3)), () {
      if (mounted) {
        _blinkController.forward().then((_) {
          _blinkController.reverse();
          _startBlinking();
        });
      }
    });
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _blinkController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _breathingController,
        _glowController,
      ]),
      builder: (context, child) {
        final breathingScale = 1.0 + (_breathingController.value * 0.05);
        final glowOpacity = 0.3 + (_glowController.value * 0.4);

        return Transform.scale(
          scale: breathingScale,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.emotionColor.withOpacity(glowOpacity),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Animated gradient border
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        widget.emotionColor,
                        widget.emotionColor.withOpacity(0.5),
                        widget.emotionColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                // Inner circle with avatar
                Center(
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1E293B),
                      border: Border.all(
                        color: widget.emotionColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: Stack(
                        children: [
                          // Avatar placeholder with gradient
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  widget.emotionColor.withOpacity(0.3),
                                  const Color(0xFF1E293B),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.person,
                                size: 120,
                                color: widget.emotionColor.withOpacity(0.6),
                              ),
                            ),
                          ),
                          // Blink overlay
                          AnimatedBuilder(
                            animation: _blinkController,
                            builder: (context, child) {
                              if (_blinkController.value > 0.5) {
                                return Positioned(
                                  top: 90,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 4,
                                    color: const Color(0xFF1E293B),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
