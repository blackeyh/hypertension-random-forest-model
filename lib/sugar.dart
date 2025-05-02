import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'homepage.dart';

class DiabetesPage extends StatefulWidget {
  @override
  _DiabetesPageState createState() => _DiabetesPageState();
}

class _DiabetesPageState extends State<DiabetesPage> with TickerProviderStateMixin {
  bool? _hasDiabetes;
  final TextEditingController _bloodGlucoseController = TextEditingController();
  final FocusNode _glucoseFocusNode = FocusNode();

  late AnimationController _impactController;
  late Animation<double> _impactAnimation;
  late Animation<Color?> _colorAnimation;

  final Color _turquoise = const Color(0xFF40E0D0);
  final Color _mintGreen = const Color(0xFF98FF98);
  final Color _deepTurquoise = const Color(0xFF00CED1);

  @override
  void initState() {
    super.initState();
    _impactController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _impactAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _impactController, curve: Curves.easeOutCubic),
    );

    _colorAnimation = ColorTween(
      begin: _turquoise.withOpacity(0.3),
      end: _deepTurquoise.withOpacity(0.8),
    ).animate(_impactController);
  }

  @override
  void dispose() {
    _impactController.dispose();
    _bloodGlucoseController.dispose();
    _glucoseFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submitDiabetesData() async {
    final bloodGlucoseLevel = _bloodGlucoseController.text.trim();

    if (_hasDiabetes == null || bloodGlucoseLevel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill all fields'),
          backgroundColor: _deepTurquoise,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.email)
            .set({
          'has_diabetes': _hasDiabetes,
          'blood_glucose_level': bloodGlucoseLevel,
        }, SetOptions(merge: true));

        // Navigation with fade transition
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImpact() => _impactController.forward(from: 0);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: isKeyboardVisible ? screenHeight * 0.2 : 24,
              top: 24,
              left: 24,
              right: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                const SizedBox(height: 30),
                _buildDiabetesSelector(),
                const SizedBox(height: 30),
                _buildBloodGlucoseInput(),
                const SizedBox(height: 40),
                _buildImpactVisualizer(),
                const SizedBox(height: 40),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Diabetes Management',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: _deepTurquoise,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Track your health metrics seamlessly',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDiabetesSelector() {
    return Column(
      children: [
        Text(
          'Diabetes Status',
          style: TextStyle(
            fontSize: 20,
            color: _deepTurquoise,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildRadioOption("Yes", true),
            const SizedBox(width: 20),
            _buildRadioOption("No", false),
          ],
        ),
      ],
    );
  }

  Widget _buildRadioOption(String label, bool value) {
    return GestureDetector(
      onTap: () => setState(() {
        _hasDiabetes = value;
        _showImpact();
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        decoration: BoxDecoration(
          color: _hasDiabetes == value ? _mintGreen.withOpacity(0.15) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: _hasDiabetes == value ? _deepTurquoise : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            )
          ],
        ),
        child: Row(
          children: [
            Icon(
              _hasDiabetes == value ? Icons.check_circle : Icons.radio_button_unchecked,
              color: _hasDiabetes == value ? _deepTurquoise : Colors.grey,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: _hasDiabetes == value ? _deepTurquoise : Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBloodGlucoseInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Blood Glucose Level (mg/dL)',
          style: TextStyle(
            color: _deepTurquoise,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _bloodGlucoseController,
          focusNode: _glucoseFocusNode,
          decoration: InputDecoration(
            filled: true,
            fillColor: _mintGreen.withOpacity(0.08),
            hintText: 'Enter current glucose level',
            prefixIcon: Icon(Icons.monitor_heart_outlined, color: _turquoise),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _deepTurquoise, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          ),
          keyboardType: TextInputType.number,
          style: TextStyle(
            color: _deepTurquoise,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildImpactVisualizer() {
    return AnimatedBuilder(
      animation: _impactController,
      builder: (context, child) {
        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _colorAnimation.value!.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _colorAnimation.value!, width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    _getImpactTitle(_hasDiabetes),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _colorAnimation.value,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _getImpactSubtitle(_hasDiabetes),
                    style: TextStyle(
                      fontSize: 16,
                      color: _deepTurquoise,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _impactAnimation.value,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getImpactColor(_hasDiabetes),
                ),
                minHeight: 12,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitDiabetesData,
        style: ElevatedButton.styleFrom(
          backgroundColor: _deepTurquoise,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          shadowColor: _turquoise.withOpacity(0.3),
        ),
        child: const Text(
          'Save & Continue',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  String _getImpactTitle(bool? hasDiabetes) {
    if (hasDiabetes == null) return 'Select Diabetes Status';
    return hasDiabetes ? 'Personalized Care Plan' : 'Preventive Measures';
  }

  String _getImpactSubtitle(bool? hasDiabetes) {
    if (hasDiabetes == null) return 'Your selection will help us provide tailored recommendations';
    return hasDiabetes
        ? 'Focus on regular monitoring and medication adherence'
        : 'Maintain balanced diet and regular exercise';
  }

  Color _getImpactColor(bool? hasDiabetes) {
    if (hasDiabetes == null) return Colors.grey;
    return hasDiabetes ? Colors.orangeAccent : _turquoise;
  }
}