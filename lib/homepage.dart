
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart'; // Replace charts_flutter with fl_chart
import 'package:google_fonts/google_fonts.dart';

class FeatureImportance {
  final String feature;
  final double importance;
  final Color color; // Use Flutter's Color class instead of charts.Color

  FeatureImportance(this.feature, this.importance, this.color);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String resultText = "";
  String userEmail = "";
  List<FeatureImportance> featureImportances = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getCurrentUserEmail();
  }

  void getCurrentUserEmail() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email ?? "";
      });
    } else {
      setState(() {
        resultText = "No user is logged in.";
      });
    }
  }

   Future<void> checkHypertension(String email) async {
    setState(() => isLoading = true);
final url = Uri.parse("https://sharp-enormous-collie.ngrok-free.app/predict");

    try {
      final response = await http.post(
        url,
        body: json.encode({"email": email}),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['prediction'] != null) {
          // Modified section: Sort and take top 5 features
          var features = parseFeatureImportances(responseData['feature_importances']);
          features.sort((a, b) => b.importance.compareTo(a.importance));
          featureImportances = features.take(5).toList();
          
          setState(() {
            resultText = 'Prediction: ${responseData['prediction']['Predicted Class']}\n'
                'Probability: ${responseData['prediction']['Probability of Hypertension']}';
          });
        }
      }
    } catch (e) {
      setState(() => resultText = "Error: ${e.toString()}");
    } finally {
      setState(() => isLoading = false);
    }
  }
  List<FeatureImportance> parseFeatureImportances(String importanceText) {
  List<FeatureImportance> features = [];
  final lines = importanceText.split('\n');
  
  // Turquoise color variants
  final colors = [
    const Color(0xFF40E0D0),
    const Color(0xFF48D1CC),
    const Color(0xFF00CED1),
    const Color(0xFF20B2AA),
    const Color(0xFF5F9EA0),
    const Color(0xFF008B8B),
    const Color(0xFF00CED1),
  ];

  int colorIndex = 0;
  for (var line in lines) {
    final parts = line.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0] != 'Feature' && parts[0] != 'Importance') {
      final feature = parts[0];
      final importance = double.tryParse(parts[1]) ?? 0.0;
      features.add(FeatureImportance(
        feature,
        importance,
        colors[colorIndex % colors.length],
      ));
      colorIndex++;
    }
  }
  return features;
}

  Widget _buildPredictionCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF40E0D0).withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 3,
            )
          ],
        ),
        child: Column(
          children: [
            Text(
              'Hypertension Risk Assessment',
              style: GoogleFonts.poppins(
                color: const Color(0xFF008B8B),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              resultText.isNotEmpty ? resultText : "Press the button to check",
              style: GoogleFonts.poppins(
                color: const Color(0xFF5F9EA0),
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureImportanceChart() {
    if (featureImportances.isEmpty) return const SizedBox();

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        height: 400,
        child: Column(
          children: [
            Text(
              'Top 5 Important Features',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF008B8B),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceBetween,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          final feature = featureImportances[value.toInt()].feature;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Transform.rotate(
                              angle: -45 * (3.1415926535 / 180),
                              child: Text(
                                feature,
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: const Color(0xFF5F9EA0),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(2),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFF5F9EA0),
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: const Color(0xFF40E0D0).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  barGroups: featureImportances
                      .asMap()
                      .entries
                      .map((entry) {
                        final index = entry.key;
                        final feature = entry.value;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: feature.importance,
                              color: feature.color,
                              width: 20,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        );
                      })
                      .toList(),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 0.1,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: const Color(0xFF40E0D0).withOpacity(0.1),
                      strokeWidth: 1,
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hypertension Check',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            )),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF40E0D0), Color(0xFF20B2AA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFE0FFFF)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                userEmail.isNotEmpty
                    ? "Welcome, ${userEmail.split('@').first}!"
                    : "Please login to continue",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: const Color(0xFF5F9EA0),
                ),
              ),
              const SizedBox(height: 30),
              _buildPredictionCard(),
              const SizedBox(height: 30),
              _buildFeatureImportanceChart(),
              const SizedBox(height: 30),
              if (isLoading)
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Color(0xFF40E0D0)),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: userEmail.isNotEmpty && !isLoading
                    ? () => checkHypertension(userEmail)
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                  shadowColor: const Color(0xFF40E0D0).withOpacity(0.3),
                  backgroundColor: const Color(0xFF40E0D0),
                  disabledBackgroundColor: Colors.grey,
                ),
                child: Text(
                  'Analyze Hypertension Risk',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}