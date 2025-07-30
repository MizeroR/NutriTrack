class NutritionSummary {
  final String patientId;
  final int daysAnalyzed;
  final Map<String, num> totals;
  final Map<String, num> targets;
  final Map<String, num> percentMet;
  final List<String> flags;
  final List<String> recommendations;

  NutritionSummary({
    required this.patientId,
    required this.daysAnalyzed,
    required this.totals,
    required this.targets,
    required this.percentMet,
    required this.flags,
    required this.recommendations,
  });

  factory NutritionSummary.fromJson(Map<String, dynamic> json) {
    return NutritionSummary(
      patientId: json['patientId'] as String,
      daysAnalyzed: json['daysAnalyzed'] as int,
      totals: Map<String, num>.from(json['totals']),
      targets: Map<String, num>.from(json['targets']),
      percentMet: Map<String, num>.from(json['percentMet']),
      flags: List<String>.from(json['flags']),
      recommendations: List<String>.from(json['recommendations']),
    );
  }

  // Helper getters
  int get ironPercent => percentMet['iron']?.round() ?? 0;
  bool get isCritical => flags.isNotEmpty;
}
