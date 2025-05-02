import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/animation.dart';
import 'sugar.dart';
import 'package:intl/intl.dart';

class HbA1cPage extends StatefulWidget {
  @override
  _HbA1cPageState createState() => _HbA1cPageState();
}

class _HbA1cPageState extends State<HbA1cPage> with TickerProviderStateMixin {
  final TextEditingController _hbA1cController = TextEditingController();
  DateTime? _selectedDate;
  final double _normalHbA1c = 5.6;

  late AnimationController _submitController;
  late AnimationController _chartController;
  late Animation<double> _buttonScale;
  late Animation<double> _chartAnimation;

  final Color _turquoise = const Color(0xFF40E0D0);
  final Color _mintGreen = const Color(0xFF98FF98);
  final Color _deepTurquoise = const Color(0xFF00CED1);

  @override
  void initState() {
    super.initState();

    _submitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _chartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    _buttonScale = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _submitController, curve: Curves.easeInOut),
    );

    _chartAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _chartController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _hbA1cController.dispose();
    _submitController.dispose();
    _chartController.dispose();
    super.dispose();
  }

  Future<void> _submitHbA1c() async {
    if (_hbA1cController.text.isEmpty || _selectedDate == null) {
      _showSnackBar('Please fill all fields');
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.email)
            .set({
          'hbA1c_level': _hbA1cController.text,
          'date': _selectedDate,
        }, SetOptions(merge: true));

        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => DiabetesPage(),
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
      _showSnackBar('Error: ${e.toString()}');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: _deepTurquoise,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _deepTurquoise,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

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
                _buildAnimatedChart(),
                const SizedBox(height: 40),
                _buildInputSection(),
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
          'HbA1c Tracker',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: _deepTurquoise,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Track your 3-month average blood glucose levels',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedChart() {
    return AnimatedBuilder(
      animation: _chartController,
      builder: (context, child) {
        return Transform.scale(
          scale: _chartAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _mintGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _deepTurquoise, width: 2),
            ),
            child: Column(
              children: [
                Icon(Icons.show_chart, size: 50, color: _deepTurquoise),
                const SizedBox(height: 15),
                Text(
                  'Normal Range: 4.0 - 5.6%',
                  style: TextStyle(
                    color: _deepTurquoise,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: _normalHbA1c / 10,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(_turquoise),
                  minHeight: 12,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputSection() {
    return Column(
      children: [
        _buildHbA1cInput(),
        const SizedBox(height: 20),
        _buildDateInput(),
      ],
    );
  }

  Widget _buildHbA1cInput() {
    return TextField(
      controller: _hbA1cController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'HbA1c Level (%)',
        labelStyle: TextStyle(color: _deepTurquoise),
        floatingLabelStyle: TextStyle(color: _deepTurquoise),
        prefixIcon: Icon(Icons.bloodtype, color: _turquoise),
        filled: true,
        fillColor: _mintGreen.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: _deepTurquoise, width: 2),
        ),
      ),
      style: TextStyle(color: _deepTurquoise, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildDateInput() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: TextField(
          controller: TextEditingController(
            text: _selectedDate != null
                ? DateFormat('MMM dd, yyyy').format(_selectedDate!)
                : '',
          ),
          decoration: InputDecoration(
            labelText: 'Test Date',
            labelStyle: TextStyle(color: _deepTurquoise),
            floatingLabelStyle: TextStyle(color: _deepTurquoise),
            prefixIcon: Icon(Icons.calendar_today, color: _turquoise),
            filled: true,
            fillColor: _mintGreen.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: _deepTurquoise, width: 2),
            ),
          ),
          style: TextStyle(color: _deepTurquoise, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return AnimatedBuilder(
      animation: _submitController,
      builder: (context, child) {
        return Transform.scale(
          scale: _buttonScale.value,
          child: ElevatedButton(
            onPressed: _submitHbA1c,
            style: ElevatedButton.styleFrom(
              backgroundColor: _deepTurquoise,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
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
      },
    );
  }
}