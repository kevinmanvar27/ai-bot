import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Name selection screen - allows user to enter custom AI assistant's name
class NameSelectionScreen extends StatefulWidget {
  final String userGender;
  final String aiGender;

  const NameSelectionScreen({
    super.key,
    required this.userGender,
    required this.aiGender,
  });

  @override
  State<NameSelectionScreen> createState() => _NameSelectionScreenState();
}

class _NameSelectionScreenState extends State<NameSelectionScreen> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  bool _isValidName(String name) {
    // Name should be 2-20 characters, only letters and spaces
    if (name.trim().isEmpty) return false;
    if (name.trim().length < 2 || name.trim().length > 20) return false;
    
    // Check if name contains only letters and spaces
    final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
    return nameRegex.hasMatch(name.trim());
  }

  void _validateAndUpdateError() {
    final name = _nameController.text.trim();
    
    setState(() {
      if (name.isEmpty) {
        _errorText = null;
      } else if (name.length < 2) {
        _errorText = 'Name must be at least 2 characters';
      } else if (name.length > 20) {
        _errorText = 'Name must be less than 20 characters';
      } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
        _errorText = 'Name can only contain letters and spaces';
      } else {
        _errorText = null;
      }
    });
  }

  Future<void> _saveNameAndContinue() async {
    final name = _nameController.text.trim();
    
    if (!_isValidName(name)) {
      _validateAndUpdateError();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save AI name (capitalize first letter)
      final capitalizedName = name[0].toUpperCase() + name.substring(1).toLowerCase();
      await prefs.setString('ai_custom_name', capitalizedName);
      
      // Debug: Print saved name
      print('✅ DEBUG: Saved custom AI name: $capitalizedName');
      print('✅ DEBUG: Verification - Reading back: ${prefs.getString('ai_custom_name')}');
      
      // Mark that user has completed onboarding
      await prefs.setBool('has_completed_onboarding', true);

      // Navigate to home screen
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving preferences: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = _nameController.text.trim().isNotEmpty && 
                        _errorText == null && 
                        _isValidName(_nameController.text.trim());
    
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E293B),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 48,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                const SizedBox(height: 20),

                // Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.aiGender == 'female' ? Icons.female : Icons.male,
                    size: 50,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 40),

                // Title
                Text(
                  'Name Your AI',
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 12),

                // Subtitle
                Text(
                  'What would you like to call your ${widget.aiGender} AI assistant?',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: const Color(0xFF94A3B8),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 60),

                // Name Input Field
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _nameFocusNode.hasFocus
                          ? const Color(0xFF8B5CF6)
                          : Colors.white.withOpacity(0.1),
                      width: _nameFocusNode.hasFocus ? 2 : 1,
                    ),
                    boxShadow: _nameFocusNode.hasFocus
                        ? [
                            BoxShadow(
                              color: const Color(0xFF8B5CF6).withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: TextField(
                    controller: _nameController,
                    focusNode: _nameFocusNode,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: 'Enter a name...',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      errorText: null, // Hide default error text
                    ),
                    onChanged: (_) => _validateAndUpdateError(),
                    onSubmitted: (_) {
                      if (canContinue) {
                        _saveNameAndContinue();
                      }
                    },
                  ),
                ),

                // Error message
                if (_errorText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Color(0xFFEF4444),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorText!,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: const Color(0xFFEF4444),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // Guidelines
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF8B5CF6).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFF8B5CF6),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Name Guidelines',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFE2E8F0),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _GuidelineItem(text: '2-20 characters long'),
                      const SizedBox(height: 6),
                      _GuidelineItem(text: 'Letters and spaces only'),
                      const SizedBox(height: 6),
                      _GuidelineItem(text: 'Example: Radhika, Alex, Maya'),
                    ],
                  ),
                ),

                const SizedBox(height: 60),

                // Preview text
                if (canContinue)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF10B981).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: Color(0xFF10B981),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your AI assistant will be called "${_nameController.text.trim()[0].toUpperCase()}${_nameController.text.trim().substring(1).toLowerCase()}"',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFFE2E8F0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const Spacer(),

                // Continue Button
                GestureDetector(
                  onTap: canContinue && !_isLoading
                      ? _saveNameAndContinue
                      : null,
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: canContinue
                          ? const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                            )
                          : null,
                      color: canContinue
                          ? null
                          : const Color(0xFF334155),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: canContinue
                          ? [
                              BoxShadow(
                                color: const Color(0xFF8B5CF6).withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : Text(
                              'Continue',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: canContinue
                                    ? Colors.white
                                    : const Color(0xFF64748B),
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GuidelineItem extends StatelessWidget {
  final String text;

  const _GuidelineItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: Color(0xFF8B5CF6),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }
}
