import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'sign_up_page.dart';
import 'userinfo.dart';
import 'dart:math';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
    final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late AnimationController _controller;
  late AnimationController _particleController;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _logoScale;
  late Animation<double> _buttonScale;
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  final Random _random = Random();

  final Color _turquoise = const Color(0xFF40E0D0);
  final Color _mintGreen = const Color(0xFF98FF98);
  final Color _deepTurquoise = const Color(0xFF00CED1);

  final List<Particle> _particles = [];

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

    _logoScale = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _buttonScale = Tween<double>(begin: 0.9, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();

    // Initialize particles
    for (int i = 0; i < 50; i++) {
      _particles.add(Particle(
        radius: _random.nextDouble() * 2 + 1,
        color: _turquoise.withOpacity(_random.nextDouble() * 0.3 + 0.1),
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

  // Particle class and build method omitted for brevity (see note below)

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
                  _mintGreen.withOpacity(0.1),
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
                              offset: _offsetAnimation.value * (1 - _opacityAnimation.value),
                              child: child,
                            ),
                          );
                        },
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ScaleTransition(
                                scale: _logoScale,
                                child: _buildLogo(),
                              ),
                              const SizedBox(height: 40),
                              _buildEmailField(),
                              const SizedBox(height: 20),
                              _buildPasswordField(),
                              const SizedBox(height: 30),
                              ScaleTransition(
                                scale: _buttonScale,
                                child: _buildLoginButton(),
                              ),
                              const SizedBox(height: 20),
                              _buildSignUpLink(),
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
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(_deepTurquoise),
                  strokeWidth: 5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _turquoise.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 5,
          )
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.circle, color: _turquoise.withOpacity(0.1), size: 120),
          Image.asset(
            'assets/logo.jpg',
            width: 80,
            height: 80,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: _turquoise.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: TextField(
        controller: _emailController,
        style: TextStyle(color: _deepTurquoise),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(Icons.email, color: _deepTurquoise),
          hintText: 'Email',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: _turquoise, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: _turquoise.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: !_isPasswordVisible,
        style: TextStyle(color: _deepTurquoise),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(Icons.lock, color: _deepTurquoise),
          suffixIcon: IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                color: _deepTurquoise,
                key: ValueKey<bool>(_isPasswordVisible),
              ),
            ),
            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
          ),
          hintText: 'Password',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: _turquoise, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: _turquoise.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(15),
        elevation: 4,
        child: InkWell(
          onTap: _isLoading ? null : _login,
          borderRadius: BorderRadius.circular(15),
          hoverColor: _turquoise.withOpacity(0.1),
          highlightColor: _turquoise.withOpacity(0.2),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                colors: [_deepTurquoise, _turquoise],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading)
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
                    'Login',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 1, 1, 1),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpPage()));
          },
          style: TextButton.styleFrom(
            foregroundColor: _deepTurquoise,
          ),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: _deepTurquoise),
              children: const [
                TextSpan(text: "Don't have an account? "),
                TextSpan(
                  text: "Sign up",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    try {
      setState(() => _isLoading = true);
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Navigator.push(context, MaterialPageRoute(builder: (context) => const UserInfoPage()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Invalid credentials"),
          backgroundColor: _turquoise,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
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