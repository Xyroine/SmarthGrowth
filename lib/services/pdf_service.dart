import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/child_profile.dart';
import '../../models/growth_record.dart';

class PdfService {
  static Future<void> generateGrowthReport(ChildProfile child, List<GrowthRecord> records) async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.nunitoRegular();
    final fontBold = await PdfGoogleFonts.nunitoBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Laporan Pertumbuhan Anak', style: pw.TextStyle(font: fontBold, fontSize: 24, color: PdfColors.teal)),
                    pw.Text('SmartGrowth', style: pw.TextStyle(font: font, fontSize: 16, color: PdfColors.grey700)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Informasi Anak', style: pw.TextStyle(font: fontBold, fontSize: 16, color: PdfColors.teal800)),
                    pw.SizedBox(height: 10),
                    _buildInfoRow('Nama', child.name, font, fontBold),
                    _buildInfoRow('Jenis Kelamin', child.gender, font, fontBold),
                    _buildInfoRow('Usia', child.ageString, font, fontBold),
                    _buildInfoRow('Status Gizi (Saat ini)', child.nutritionStatus, font, fontBold),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),
              pw.Text('Riwayat Pertumbuhan', style: pw.TextStyle(font: fontBold, fontSize: 18, color: PdfColors.teal800)),
              pw.SizedBox(height: 10),
              if (records.isEmpty)
                pw.Text('Belum ada data pertumbuhan dicatat.', style: pw.TextStyle(font: font, color: PdfColors.grey600))
              else
                pw.TableHelper.fromTextArray(
                  headers: ['Tanggal', 'Berat Badan (kg)', 'Tinggi Badan (cm)'],
                  data: records.map((r) {
                    final d = r.recordDate;
                    return ['${d.day}/${d.month}/${d.year}', r.weight.toString(), r.height.toString()];
                  }).toList(),
                  headerStyle: pw.TextStyle(font: fontBold, color: PdfColors.white),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.teal),
                  cellStyle: pw.TextStyle(font: font),
                  cellAlignment: pw.Alignment.center,
                  border: pw.TableBorder.all(color: PdfColors.grey400),
                ),
              pw.Spacer(),
              pw.Divider(),
              pw.Center(
                child: pw.Text('Laporan dihasilkan otomatis oleh aplikasi SmartGrowth', style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey600)),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Laporan_Pertumbuhan_${child.name.replaceAll(' ', '_')}.pdf',
    );
  }

  static pw.Widget _buildInfoRow(String label, String value, pw.Font font, pw.Font fontBold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 120, child: pw.Text(label, style: pw.TextStyle(font: font, color: PdfColors.grey800))),
          pw.Text(':', style: pw.TextStyle(font: font, color: PdfColors.grey800)),
          pw.SizedBox(width: 10),
          pw.Expanded(child: pw.Text(value, style: pw.TextStyle(font: fontBold, color: PdfColors.black))),
        ],
      ),
    );
  }
}
