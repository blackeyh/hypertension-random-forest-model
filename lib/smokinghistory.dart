import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/animation.dart';
import 'HbA1cPage.dart';

class SmokingHistoryPage extends StatefulWidget {
  const SmokingHistoryPage({super.key});

  @override
  _SmokingHistoryPageState createState() => _SmokingHistoryPageState();
}

class _SmokingHistoryPageState extends State<SmokingHistoryPage>
    with TickerProviderStateMixin {
  int smokingHistory = 0;
  late AnimationController _scaleController;
  late AnimationController _impactController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _impactAnimation;
  late Animation<Color?> _colorAnimation;

  final Color _turquoise = const Color(0xFF40E0D0);
  final Color _mintGreen = const Color(0xFF98FF98);
  final Color _deepTurquoise = const Color(0xFF00CED1);

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

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
    _scaleController.dispose();
    _impactController.dispose();
    super.dispose();
  }

  Future<void> _submitSmokingHistory() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.email).set({
          'smoking_history': smokingHistory,
        }, SetOptions(merge: true));

        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => HbA1cPage(),
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
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _showImpact() => _impactController.forward(from: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                const SizedBox(height: 30),
                _buildAnimatedIcon(),
                const SizedBox(height: 30),
                ..._buildSmokingOptions(),
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
          'Smoking History',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: _deepTurquoise,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Help us understand your habits for better care',
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

  Widget _buildAnimatedIcon() {
    return AnimatedBuilder(
      animation: _scaleController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Icon(
            Icons.smoke_free,
            size: 80,
            color: _deepTurquoise.withOpacity(0.8),
          ),
        );
      },
    );
  }

  List<Widget> _buildSmokingOptions() {
    return [
      _buildSmokingOption('Non-Smoker', 0, Icons.health_and_safety),
      _buildSmokingOption('Light Smoker', 1, Icons.smoke_free),
      _buildSmokingOption('Moderate Smoker', 2, Icons.smoking_rooms),
      _buildSmokingOption('Heavy Smoker', 3, Icons.smoking_rooms),
    ];
  }

  Widget _buildSmokingOption(String label, int value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () => setState(() {
          smokingHistory = value;
          _showImpact();
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: smokingHistory == value
                ? _mintGreen.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: smokingHistory == value ? _deepTurquoise : Colors.grey[300]!,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(smokingHistory == value ? 0.1 : 0.05),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: smokingHistory == value ? _deepTurquoise : Colors.grey,
                size: 30,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: smokingHistory == value ? _deepTurquoise : Colors.grey[700],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (smokingHistory == value)
                Icon(
                  Icons.check_circle,
                  color: _deepTurquoise,
                ),
            ],
          ),
        ),
      ),
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
                    _getImpactTitle(smokingHistory),
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
                    _getImpactSubtitle(smokingHistory),
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
                  _getImpactColor(smokingHistory),
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
        onPressed: _submitSmokingHistory,
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
          'Continue',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  String _getImpactTitle(int value) {
    switch (value) {
      case 3:
        return 'High Health Risk';
      case 2:
        return 'Moderate Risk';
      case 1:
        return 'Low Risk';
      default:
        return 'Healthy Choice';
    }
  }

  String _getImpactSubtitle(int value) {
    switch (value) {
      case 3:
        return 'Consider professional support to quit smoking';
      case 2:
        return 'Reducing consumption can improve outcomes';
      case 1:
        return 'Maintain low levels or consider quitting';
      default:
        return 'Keep up the good work staying smoke-free!';
    }
  }

  Color _getImpactColor(int value) {
    switch (value) {
      case 3:
        return Colors.orangeAccent;
      case 2:
        return Colors.amber;
      case 1:
        return _turquoise;
      default:
        return _mintGreen;
    }
  }
}