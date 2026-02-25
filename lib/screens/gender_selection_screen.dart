import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gender selection screen for new users
class GenderSelectionScreen extends StatefulWidget {
  const GenderSelectionScreen({super.key});

  @override
  State<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  String? _selectedGender;
  bool _isLoading = false;

  Future<void> _saveGenderAndContinue() async {
    if (_selectedGender == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save user's gender
      await prefs.setString('user_gender', _selectedGender!);
      
      // Set AI gender (opposite of user's gender)
      final aiGender = _selectedGender == 'male' ? 'female' : 'male';
      await prefs.setString('ai_gender', aiGender);
      
      // Debug: Verify saved values
      print('✅ DEBUG: Saved user_gender: $_selectedGender');
      print('✅ DEBUG: Saved ai_gender: $aiGender');
      print('✅ DEBUG: Verification - user_gender: ${prefs.getString('user_gender')}');
      print('✅ DEBUG: Verification - ai_gender: ${prefs.getString('ai_gender')}');

      // Navigate to name selection screen
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(
          '/name-selection',
          arguments: {
            'userGender': _selectedGender!,
            'aiGender': aiGender,
          },
        );
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
    return Scaffold(
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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                    ),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: const Color(0xFF8B5CF6).withOpacity(0.5),
                    //     blurRadius: 30,
                    //     spreadRadius: 10,
                    //   ),
                    // ],
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    size: 50,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 20),

                // Title
                Text(
                  'Welcome!',
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 12),

                // Subtitle
                Text(
                  'Let\'s personalize your AI assistant',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: const Color(0xFF94A3B8),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 60),

                // Question
                Text(
                  'What is your gender?',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 32),

                // Gender Options
                Row(
                  children: [
                    Expanded(
                      child: _GenderCard(
                        icon: Icons.male,
                        label: 'Male',
                        isSelected: _selectedGender == 'male',
                        onTap: () {
                          setState(() {
                            _selectedGender = 'male';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _GenderCard(
                        icon: Icons.female,
                        label: 'Female',
                        isSelected: _selectedGender == 'female',
                        onTap: () {
                          setState(() {
                            _selectedGender = 'female';
                          });
                        },
                      ),
                    ),
                  ],
                ),

                // const SizedBox(height: ),

                // Info text
                if (_selectedGender != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    // decoration: BoxDecoration(
                    //   color: const Color(0xFF8B5CF6).withOpacity(0.1),
                    //   borderRadius: BorderRadius.circular(12),
                    //   border: Border.all(
                    //     color: const Color(0xFF8B5CF6).withOpacity(0.3),
                    //   ),
                    // ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_rounded,
                          color: Color(0xFF8B5CF6),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedGender == 'male'
                                ? 'Your AI assistant will be female'
                                : 'Your AI assistant will be male',
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
                  onTap: _selectedGender != null && !_isLoading
                      ? _saveGenderAndContinue
                      : null,
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: _selectedGender != null
                          ? const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                            )
                          : null,
                      color: _selectedGender == null
                          ? const Color(0xFF334155)
                          : null,
                      borderRadius: BorderRadius.circular(30),
                      /*boxShadow: _selectedGender != null
                          ? [
                              BoxShadow(
                                color:
                                    const Color(0xFF8B5CF6).withOpacity(0.5),
                                blurRadius: 100,
                                // spreadRadius: ,
                              ),
                            ]
                          : null,*/
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
                                color: _selectedGender != null
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
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                )
              : null,
          color: isSelected ? null : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF8B5CF6)
                : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
         /* boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.5),
                    blurRadius: 20,
                    // spreadRadius: 2,
                  ),
                ]
              : null,*/
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 60,
              color: isSelected ? Colors.white : const Color(0xFF94A3B8),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
