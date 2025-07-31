import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/nutrition_summary.dart';

class NutritionPdfGenerator {
  static Future<pw.Document> generatePdf(NutritionSummary summary) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('yyyy-MM-dd');

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(level: 0, child: pw.Text('Nutrition Summary Report')),
            pw.SizedBox(height: 10),
            pw.Text('Patient ID: ${summary.patientId}'),
            pw.Text('Period: ${summary.daysAnalyzed} days'),
            pw.Text('Generated on: ${dateFormat.format(DateTime.now())}'),
            pw.Divider(),
            pw.Header(level: 1, child: pw.Text('Nutrition Intake')),
            pw.TableHelper.fromTextArray(
              headers: ['Nutrient', 'Consumed', 'Target', '% Met'],
              data: [
                [
                  'Calories',
                  '${summary.totals['calories']?.toStringAsFixed(1)}',
                  '${summary.targets['calories']}',
                  '${summary.percentMet['calories']}%',
                ],
                [
                  'Protein',
                  '${summary.totals['protein']?.toStringAsFixed(1)}g',
                  '${summary.targets['protein']}g',
                  '${summary.percentMet['protein']}%',
                ],
                [
                  'Iron',
                  '${summary.totals['iron']?.toStringAsFixed(1)}mg',
                  '${summary.targets['iron']}mg',
                  '${summary.percentMet['iron']}%',
                ],
              ],
            ),
            pw.SizedBox(height: 20),
            if (summary.flags.isNotEmpty) ...[
              pw.Header(level: 1, child: pw.Text('Alerts')),
              pw.Bullet(text: summary.flags.join('\n')),
              pw.SizedBox(height: 10),
              pw.Header(level: 1, child: pw.Text('Recommendations')),
              pw.Bullet(text: summary.recommendations.join('\n')),
            ],
          ],
        ),
      ),
    );

    return pdf;
  }
}
