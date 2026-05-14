import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../models/child_profile.dart';
import '../../models/growth_record.dart';

class GrowthChartScreen extends StatefulWidget {
  const GrowthChartScreen({super.key});
  @override
  State<GrowthChartScreen> createState() => _GrowthChartScreenState();
}

class _GrowthChartScreenState extends State<GrowthChartScreen> {
  final _db = DatabaseHelper();
  ChildProfile? _child;
  List<GrowthRecord> _records = [];
  bool _loading = true;
  bool _showWeight = true;

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId != null) {
      final children = await _db.getChildren(userId);
      if (children.isNotEmpty) {
        _child = children.first;
        _records = await _db.getGrowthRecords(_child!.id!);
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark, foregroundColor: Colors.white,
        title: Text('Grafik Pertumbuhan', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (_child != null) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.primaryPale.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(14)),
                    child: Row(children: [
                      Icon(Icons.child_care_rounded, color: AppColors.primaryDark, size: 22),
                      const SizedBox(width: 10),
                      Text('${_child!.name} • ${_child!.shortAgeString}',
                          style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryDark)),
                    ]),
                  ),
                  const SizedBox(height: 20),
                ],

                // Toggle buttons
                Row(children: [
                  Expanded(child: _toggleBtn('Berat Badan', Icons.monitor_weight_outlined, true)),
                  const SizedBox(width: 10),
                  Expanded(child: _toggleBtn('Tinggi Badan', Icons.height_rounded, false)),
                ]),
                const SizedBox(height: 20),

                // Chart
                Container(
                  height: 250,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                  ),
                  child: _records.isEmpty
                      ? Center(child: Text('Belum ada data pertumbuhan', style: GoogleFonts.nunito(color: AppColors.textMuted)))
                      : LineChart(_buildChart()),
                ),
                const SizedBox(height: 24),

                // Add record button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _addRecord,
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: Text('Tambah Data Pertumbuhan', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Records list
                if (_records.isNotEmpty) ...[
                  Text('Riwayat', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  ..._records.reversed.map((r) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.textMuted),
                      const SizedBox(width: 10),
                      Text('${r.recordDate.day}/${r.recordDate.month}/${r.recordDate.year}',
                          style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textMuted)),
                      const Spacer(),
                      Text('${r.weight} kg', style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF4CAF50))),
                      const SizedBox(width: 16),
                      Text('${r.height} cm', style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF2196F3))),
                    ]),
                  )),
                ],
              ]),
            ),
    );
  }

  Widget _toggleBtn(String label, IconData icon, bool isWeight) {
    final sel = _showWeight == isWeight;
    return GestureDetector(
      onTap: () => setState(() => _showWeight = isWeight),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: sel ? AppColors.primaryDark : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: sel ? null : Border.all(color: AppColors.divider.withValues(alpha: 0.4)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 18, color: sel ? Colors.white : AppColors.textMuted),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: sel ? Colors.white : AppColors.textMuted)),
        ]),
      ),
    );
  }

  LineChartData _buildChart() {
    final spots = _records.asMap().entries.map((e) =>
        FlSpot(e.key.toDouble(), _showWeight ? e.value.weight : e.value.height)).toList();
    final color = _showWeight ? const Color(0xFF4CAF50) : const Color(0xFF2196F3);
    return LineChartData(
      gridData: FlGridData(show: true, drawVerticalLine: false,
          horizontalInterval: _showWeight ? 2 : 10,
          getDrawingHorizontalLine: (_) => FlLine(color: AppColors.divider.withValues(alpha: 0.3), strokeWidth: 1)),
      titlesData: FlTitlesData(rightTitles: const AxisTitles(), topTitles: const AxisTitles(),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30,
              getTitlesWidget: (v, _) => Text('${v.toInt() + 1}', style: GoogleFonts.nunito(fontSize: 10, color: AppColors.textMuted)))),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40,
              getTitlesWidget: (v, _) => Text(v.toStringAsFixed(0), style: GoogleFonts.nunito(fontSize: 10, color: AppColors.textMuted))))),
      borderData: FlBorderData(show: false),
      lineBarsData: [LineChartBarData(spots: spots, isCurved: true, color: color, barWidth: 3,
          dotData: FlDotData(show: true, getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(radius: 4, color: color, strokeWidth: 2, strokeColor: Colors.white)),
          belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.1)))],
    );
  }

  Future<void> _addRecord() async {
    if (_child == null) return;
    final wCtrl = TextEditingController();
    final hCtrl = TextEditingController();
    final result = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Tambah Data', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 18)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: wCtrl, keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Berat (kg)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
        const SizedBox(height: 14),
        TextField(controller: hCtrl, keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Tinggi (cm)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Batal', style: GoogleFonts.nunito(color: AppColors.textMuted))),
        ElevatedButton(
          onPressed: () async {
            final w = double.tryParse(wCtrl.text);
            final h = double.tryParse(hCtrl.text);
            if (w != null && h != null) {
              await _db.insertGrowthRecord(GrowthRecord(childId: _child!.id!, weight: w, height: h, recordDate: DateTime.now()));
              Navigator.pop(context, true);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: Text('Simpan', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        ),
      ],
    ));
    if (result == true) { setState(() => _loading = true); _loadData(); }
  }
}
