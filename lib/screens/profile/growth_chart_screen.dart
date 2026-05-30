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
  void initState() {
    super.initState();
    _loadData();
  }

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
        backgroundColor: AppColors.bgCream,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: Text(
          'Grafik Pertumbuhan',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_child != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.child_care_rounded, color: AppColors.primary, size: 22),
                          const SizedBox(width: 10),
                          Text(
                            '${_child!.name} • ${_child!.shortAgeString}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Toggle buttons
                  Row(
                    children: [
                      Expanded(child: _toggleBtn('Berat Badan', Icons.monitor_weight_outlined, true)),
                      const SizedBox(width: 12),
                      Expanded(child: _toggleBtn('Tinggi Badan', Icons.height_rounded, false)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Chart Card
                  Container(
                    height: 270,
                    padding: const EdgeInsets.fromLTRB(16, 24, 20, 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.textDark.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: _records.isEmpty
                        ? Center(
                            child: Text(
                              'Belum ada data pertumbuhan',
                              style: GoogleFonts.nunito(color: AppColors.textMuted, fontSize: 13),
                            ),
                          )
                        : LineChart(_buildChart()),
                  ),
                  const SizedBox(height: 24),

                  // Add record button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addRecord,
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: Text(
                        'Tambah Data Pertumbuhan',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Records list
                  if (_records.isNotEmpty) ...[
                    Text(
                      'Riwayat Pertumbuhan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._records.reversed.map((r) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.textDark.withValues(alpha: 0.04),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.calendar_today_rounded,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${r.recordDate.day}/${r.recordDate.month}/${r.recordDate.year}',
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${r.weight} kg',
                                  style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF2D6A4F),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE3F2FD),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${r.height} cm',
                                  style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1E88E5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ],
              ),
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
          color: sel ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: sel ? null : Border.all(color: AppColors.divider),
          boxShadow: sel
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: sel ? Colors.white : AppColors.textMuted),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: sel ? Colors.white : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _buildChart() {
    final spots = _records
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), _showWeight ? e.value.weight : e.value.height))
        .toList();

    // Weight curve is Soft Sage Green, Height curve is Soft Blue Pastel with shadow
    final color = _showWeight ? const Color(0xFF52B788) : const Color(0xFF70A1FF);

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: _showWeight ? 2 : 10,
        getDrawingHorizontalLine: (_) => FlLine(
          color: AppColors.divider.withValues(alpha: 0.4),
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(),
        topTitles: const AxisTitles(),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (v, _) => Text(
              '${v.toInt() + 1}',
              style: GoogleFonts.nunito(fontSize: 10, color: AppColors.textMuted),
            ),
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (v, _) => Text(
              v.toStringAsFixed(0),
              style: GoogleFonts.nunito(fontSize: 10, color: AppColors.textMuted),
            ),
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: color,
          barWidth: 4,
          shadow: Shadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
          dotData: FlDotData(
            show: true,
            getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
              radius: 6,
              color: color,
              strokeWidth: 3,
              strokeColor: Colors.white,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            color: color.withValues(alpha: 0.08),
          ),
        ),
      ],
    );
  }

  Future<void> _addRecord() async {
    if (_child == null) return;
    final wCtrl = TextEditingController();
    final hCtrl = TextEditingController();
    final result = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
              backgroundColor: AppColors.bgCream,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                'Tambah Data',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.textDark),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: wCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Berat (kg)',
                      labelStyle: GoogleFonts.nunito(color: AppColors.textMuted),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: hCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Tinggi (cm)',
                      labelStyle: GoogleFonts.nunito(color: AppColors.textMuted),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: Text(
                    'Batal',
                    style: GoogleFonts.nunito(color: AppColors.textMuted, fontWeight: FontWeight.w600),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final w = double.tryParse(wCtrl.text);
                    final h = double.tryParse(hCtrl.text);
                    if (w != null && h != null) {
                      await _db.insertGrowthRecord(GrowthRecord(
                        childId: _child!.id!,
                        weight: w,
                        height: h,
                        recordDate: DateTime.now(),
                      ));
                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext, true);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size(100, 40),
                  ),
                  child: Text(
                    'Simpan',
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ],
            ));
    if (result == true) {
      setState(() => _loading = true);
      _loadData();
    }
  }
}
