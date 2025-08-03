import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../models/patient.dart';
import '../services/api_service.dart';
import '../models/nutrition_summary.dart';
import '../utils/file_download_service.dart';
import '../utils/nutrition_pdf_generator.dart';

class PatientOverviewScreen extends StatefulWidget {
  final Patient patient;

  const PatientOverviewScreen({super.key, required this.patient});

  @override
  PatientOverviewScreenState createState() => PatientOverviewScreenState();
}

class PatientOverviewScreenState extends State<PatientOverviewScreen> {
  late Future<NutritionSummary> _nutritionSummary;
  final Color primaryGreen = const Color(0xFF91C788);

  @override
  void initState() {
    super.initState();
    _nutritionSummary = _fetchNutritionSummary();
  }

  Future<NutritionSummary> _fetchNutritionSummary() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    return await apiService.getNutritionSummary(widget.patient.id);
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: primaryGreen.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, size: 24, color: primaryGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.patient.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildInfoChip(
                      'Trimester ${widget.patient.trimester}',
                      Colors.blue[50]!,
                      Colors.blue[800]!,
                    ),
                    const SizedBox(width: 6),
                    _buildInfoChip(
                      widget.patient.language.toUpperCase(),
                      Colors.purple[50]!,
                      Colors.purple[800]!,
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: primaryGreen, size: 20),
            onPressed: () {
              setState(() {
                _nutritionSummary = _fetchNutritionSummary();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildNutritionCard(String title, double percentage) {
    Color statusColor = primaryGreen;
    if (percentage < 50) {
      statusColor = Colors.red;
    } else if (percentage < 80) {
      statusColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        value: percentage / 100,
                        strokeWidth: 6,
                        backgroundColor: Colors.grey[200],
                        color: statusColor,
                      ),
                    ),
                    Text(
                      '${percentage.round()}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getStatusLabel(percentage),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getStatusMessage(percentage),
                      style: TextStyle(color: Colors.grey[600], fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(double percentage) {
    if (percentage < 50) return 'Critical';
    if (percentage < 80) return 'Needs Attention';
    return 'Excellent';
  }

  String _getStatusMessage(double percentage) {
    if (percentage < 50) return 'Take action';
    if (percentage < 80) return 'Monitor';
    return 'On track';
  }

  Widget _buildTrendChart(NutritionSummary summary) {
    final List<String> nutrients = ['Calories', 'Protein', 'Iron'];
    final List<double> percentages = [
      summary.percentMet['calories']?.toDouble() ?? 0,
      summary.percentMet['protein']?.toDouble() ?? 0,
      summary.percentMet['iron']?.toDouble() ?? 0,
    ];

    return Container(
      height: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Nutrition Trends',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: Colors.grey[200], strokeWidth: 1);
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(color: Colors.grey[200], strokeWidth: 1);
                  },
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            nutrients[value.toInt()],
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                      reservedSize: 24,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: const TextStyle(
                            fontSize: 8,
                            color: Colors.grey,
                          ),
                        );
                      },
                      reservedSize: 24,
                    ),
                  ),
                  rightTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                ),
                minX: 0,
                maxX: 2,
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(3, (index) {
                      return FlSpot(index.toDouble(), percentages[index]);
                    }),
                    isCurved: true,
                    color: primaryGreen,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 3,
                          color: primaryGreen,
                          strokeWidth: 1.5,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: primaryGreen.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(List<String> flags, List<String> recommendations) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Nutrition Alerts',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: flags.isEmpty
                      ? primaryGreen.withValues(alpha: 0.2)
                      : Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  flags.isEmpty ? 'All Good' : '${flags.length} Alerts',
                  style: TextStyle(
                    color: flags.isEmpty ? primaryGreen : Colors.red[800],
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (flags.isEmpty)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: primaryGreen, size: 16),
                  const SizedBox(width: 6),
                  const Text(
                    'No critical alerts',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            )
          else
            Column(
              children: List.generate(flags.length, (index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red[800],
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              flags[index],
                              style: TextStyle(
                                color: Colors.red[800],
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Recommendation: ${recommendations[index]}',
                        style: TextStyle(color: Colors.red[800], fontSize: 10),
                      ),
                    ],
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }

  Future<void> _downloadNutritionSummary() async {
    try {
      final summary = await _nutritionSummary;
      final pdf = await NutritionPdfGenerator.generatePdf(summary);

      await FileDownloadService.saveAndOpenPdf(
        pdf,
        'nutrition_summary_${widget.patient.name.replaceAll(' ', '_')}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report downloaded successfully'),
            backgroundColor: primaryGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Patient Overview',
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            backgroundColor: primaryGreen,
            onPressed: () => _downloadNutritionSummary(),
            mini: true,
            child: const Icon(Icons.download, color: Colors.white, size: 20),
          ),
          SizedBox(height: 8),
          FloatingActionButton(
            backgroundColor: primaryGreen,
            onPressed: () => _sendNutritionAlert(),
            mini: true,
            child: const Icon(Icons.sms, color: Colors.white, size: 20),
          ),
        ],
      ),
      body: FutureBuilder<NutritionSummary>(
        future: _nutritionSummary,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF91C788)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load data\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            );
          }

          if (!snapshot.hasData) {
            return Center(
              child: Text(
                'No nutrition data',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            );
          }

          final summary = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  children: [
                    _buildNutritionCard(
                      'Calories',
                      summary.percentMet['calories']?.toDouble() ?? 0,
                    ),
                    _buildNutritionCard(
                      'Protein',
                      summary.percentMet['protein']?.toDouble() ?? 0,
                    ),
                    _buildNutritionCard(
                      'Iron',
                      summary.percentMet['iron']?.toDouble() ?? 0,
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Analysis',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              '${summary.daysAnalyzed}d',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: primaryGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTrendChart(summary),
                const SizedBox(height: 12),
                _buildAlertCard(summary.flags, summary.recommendations),
                const SizedBox(height: 60),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _sendNutritionAlert() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      await apiService.sendNutritionAlert(widget.patient.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Nutrition alert sent via SMS'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: primaryGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send alert: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
