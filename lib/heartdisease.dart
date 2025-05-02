import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/animation.dart';
import 'smokinghistory.dart';
import 'dart:math';

class HeartDiseaseInfoPage extends StatefulWidget {
  @override
  _HeartDiseaseInfoPageState createState() => _HeartDiseaseInfoPageState();
}

class _HeartDiseaseInfoPageState extends State<HeartDiseaseInfoPage>
    with TickerProviderStateMixin {
  bool hasHeartDisease = false;
  List<String> selectedConditions = [];
  final TextEditingController additionalInfoController = TextEditingController();
  bool _isSubmitting = false;

  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _scaleAnimation;
  late AnimationController _particleController;

  final Color _primaryColor = const Color(0xFF00CED1);
  final Color _secondaryColor = const Color(0xFF40E0D0);
  final Color _accentColor = const Color(0xFF98FF98);

  final List<String> conditions = [
    'Coronary Artery Disease (CAD)',
    'Heart Failure',
    'Diabetic Cardiomyopathy',
    'Arrhythmias',
    'Left Ventricular Hypertrophy',
  ];

  final List<Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutQuint),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();

    // Initialize particles
    for (int i = 0; i < 50; i++) {
      _particles.add(Particle(
        radius: _random.nextDouble() * 2 + 1,
        color: _primaryColor.withOpacity(_random.nextDouble() * 0.3 + 0.1),
        position: Offset(
          _random.nextDouble() * 400,
          _random.nextDouble() * 800,
        ),
        velocity: Offset(
          _random.nextDouble() * 2 - 1,
          _random.nextDouble() * 2 - 1,
        ),
      ));
    }
  }

  Widget _buildParticles() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(_particles, _particleController.value),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.98),
                  _accentColor.withOpacity(0.1),
                ],
              ),
            ),
            child: Stack(
              children: [
                _buildParticles(),
                Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _opacityAnimation.value,
                            child: Transform.translate(
                              offset: _offsetAnimation.value *
                                  (1 - _opacityAnimation.value),
                              child: Transform.scale(
                                scale: _scaleAnimation.value,
                                child: child,
                              ),
                            ),
                          );
                        },
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildAnimatedHeader(),
                              const SizedBox(height: 40),
                              _buildHeartDiseaseToggle(),
                              if (hasHeartDisease) ...[
                                const SizedBox(height: 20),
                                _buildConditionList(),
                                const SizedBox(height: 20),
                                _buildAdditionalInfoField(),
                              ],
                              const SizedBox(height: 40),
                              _buildSubmitButton(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isSubmitting)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(_primaryColor),
                  strokeWidth: 5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    return Column(
      children: [
        Text(
          'Heart Disease Information',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: _primaryColor,
            shadows: [
              Shadow(
                color: _primaryColor.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(2, 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Help us understand your heart health',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildHeartDiseaseToggle() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Do you have any heart disease?',
              style: TextStyle(
                fontSize: 18,
                color: _primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildToggleButton('Yes', true),
                const SizedBox(width: 20),
                _buildToggleButton('No', false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(String label, bool value) {
    return GestureDetector(
      onTap: () => setState(() => hasHeartDisease = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        decoration: BoxDecoration(
          color: hasHeartDisease == value ? _primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: hasHeartDisease == value ? _primaryColor : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _primaryColor.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: hasHeartDisease == value ? Colors.white : _primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildConditionList() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: conditions.map((condition) {
          return CheckboxListTile(
            title: Text(
              condition,
              style: TextStyle(color: _primaryColor),
            ),
            value: selectedConditions.contains(condition),
            onChanged: (bool? value) {
              setState(() {
                if (value!) {
                  selectedConditions.add(condition);
                } else {
                  selectedConditions.remove(condition);
                }
              });
            },
            activeColor: _primaryColor,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAdditionalInfoField() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: TextField(
        controller: additionalInfoController,
        style: TextStyle(color: _primaryColor),
        maxLines: 3,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: 'Additional Information',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: _primaryColor, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(15),
        elevation: 4,
        child: InkWell(
          onTap: _isSubmitting ? null : _submitHeartDiseaseInfo,
          borderRadius: BorderRadius.circular(15),
          hoverColor: _primaryColor.withOpacity(0.1),
          highlightColor: _primaryColor.withOpacity(0.2),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                colors: [_primaryColor, _secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isSubmitting)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                else
                  const Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitHeartDiseaseInfo() async {
    try {
      setState(() => _isSubmitting = true);
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.email).set({
          'heart_disease': hasHeartDisease,
          'conditions': selectedConditions,
          'additional_info': additionalInfoController.text,
        }, SetOptions(merge: true));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SmokingHistoryPage()),
        );
      }
    } catch (e) {
      print("Error submitting heart disease info: $e");
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}


// Particle and ParticlePainter classes would be defined here
// (implementation details for the particle system)
class Particle {
  double radius;
  Color color;
  Offset position;
  Offset velocity;
  double alpha;
  double alphaSpeed;
  double rotation;
  double rotationSpeed;

  Particle({
    required this.radius,
    required this.color,
    required this.position,
    required this.velocity,
  })  : alpha = 1.0,
        alphaSpeed = Random().nextDouble() * 0.01 + 0.005,
        rotation = Random().nextDouble() * 2 * pi,
        rotationSpeed = Random().nextDouble() * 0.05 - 0.025;

  void update(double deltaTime) {
    position += velocity * deltaTime * 60;
    rotation += rotationSpeed;
    
    // Fade in/out effect
    alpha += alphaSpeed;
    if (alpha > 1.0 || alpha < 0.3) {
      alphaSpeed *= -1;
      alpha = alpha.clamp(0.3, 1.0);
    }

    // Add some random drift
    velocity += Offset(
      (Random().nextDouble() - 0.5) * 0.01,
      (Random().nextDouble() - 0.5) * 0.01,
    );

    // Keep velocity within bounds (corrected code)
    velocity = Offset(
      velocity.dx.clamp(-1.5, 1.5),
      velocity.dy.clamp(-1.5, 1.5),
    );
  }
}
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double time;

  ParticlePainter(this.particles, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;

    for (final particle in particles) {
      // Update particle position
      particle.update(time);

      // Wrap particles around screen edges
      if (particle.position.dx > size.width) particle.position = Offset(0, particle.position.dy);
      if (particle.position.dx < 0) particle.position = Offset(size.width, particle.position.dy);
      if (particle.position.dy > size.height) particle.position = Offset(particle.position.dx, 0);
      if (particle.position.dy < 0) particle.position = Offset(particle.position.dx, size.height);

      // Draw particle with current alpha
      paint.color = particle.color.withOpacity(particle.alpha);
      canvas.save();
      canvas.translate(particle.position.dx, particle.position.dy);
      canvas.rotate(particle.rotation);
      canvas.drawCircle(
        Offset.zero,
        particle.radius,
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}