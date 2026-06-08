import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../models/child_profile.dart';
import '../../models/growth_record.dart';
import '../../services/pdf_service.dart';

class GrowthChartScreen extends StatefulWidget {
  const GrowthChartScreen({super.key});
  @override
  State<GrowthChartScreen> createState() => _GrowthChartScreenState();
}

class _GrowthChartScreenState extends State<GrowthChartScreen> {
  final _db = DatabaseHelper();
  List<ChildProfile> _children = [];
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
      final selectedChildId = prefs.getInt('selected_child_id');
      _children = await _db.getChildren(userId);
      if (_children.isNotEmpty) {
        if (selectedChildId != null) {
          _child = _children.firstWhere(
            (c) => c.id == selectedChildId,
            orElse: () => _children.first,
          );
        } else {
          _child = _children.first;
        }
        _records = await _db.getGrowthRecords(_child!.id!);
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _switchChild(ChildProfile child) async {
    if (_child?.id == child.id) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_child_id', child.id!);
    setState(() {
      _child = child;
      _loading = true;
    });
    _records = await _db.getGrowthRecords(child.id!);
    setState(() {
      _loading = false;
    });
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
        actions: [
          if (_child != null)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.primary),
              onPressed: () => PdfService.generateGrowthReport(_child!, _records),
            ),
        ],
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
                          if (_child!.photoPath != null && _child!.photoPath!.isNotEmpty)
                            ClipOval(
                              child: Image.file(
                                File(_child!.photoPath!),
                                width: 26,
                                height: 26,
                                fit: BoxFit.cover,
                              ),
                            )
                          else
                            const Icon(Icons.child_care_rounded, color: AppColors.primary, size: 26),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${_child!.name} • ${_child!.shortAgeString}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (_children.length > 1)
                            _buildChildDropdown(),
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

  int _getAgeInMonths(DateTime recordDate) {
    if (_child == null) return 0;
    int months = (recordDate.year - _child!.birthDate.year) * 12 + (recordDate.month - _child!.birthDate.month);
    if (recordDate.day < _child!.birthDate.day) months--;
    return months < 0 ? 0 : months;
  }

  // Simplified WHO medians for 0-24 months
  final List<double> _whoWeightMedian = [
    3.3, 4.5, 5.6, 6.4, 7.0, 7.5, 7.9, 8.3, 8.6, 8.9, 9.2, 9.4, 9.6, 9.9, 10.1, 10.3, 10.5, 10.7, 10.9, 11.1, 11.3, 11.5, 11.8, 12.0, 12.2
  ];
  final List<double> _whoHeightMedian = [
    49.9, 54.7, 58.4, 61.4, 63.9, 65.9, 67.6, 69.2, 70.6, 72.0, 73.3, 74.5, 75.7, 76.9, 78.0, 79.1, 80.2, 81.2, 82.3, 83.2, 84.2, 85.1, 86.0, 86.9, 87.8
  ];

  LineChartData _buildChart() {
    if (_child == null) return LineChartData();

    // Sort records by date just to be sure
    final sortedRecords = List<GrowthRecord>.from(_records)
      ..sort((a, b) => a.recordDate.compareTo(b.recordDate));

    final spots = sortedRecords.map((r) {
      final months = _getAgeInMonths(r.recordDate);
      return FlSpot(months.toDouble(), _showWeight ? r.weight : r.height);
    }).toList();

    // Calculate max X (age in months)
    double maxX = 24.0; // Default max is 2 years
    if (spots.isNotEmpty && spots.last.x > maxX) {
      maxX = spots.last.x + 2;
    }

    // Reference WHO curve
    final List<FlSpot> whoSpots = [];
    final limit = maxX > 24 ? 24 : maxX.toInt();
    for (int i = 0; i <= limit; i++) {
      whoSpots.add(FlSpot(i.toDouble(), _showWeight ? _whoWeightMedian[i] : _whoHeightMedian[i]));
    }

    final color = _showWeight ? const Color(0xFF52B788) : const Color(0xFF70A1FF);
    final refColor = Colors.orangeAccent.withValues(alpha: 0.8);

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: _showWeight ? 2 : 10,
        verticalInterval: 2,
        getDrawingHorizontalLine: (_) => FlLine(
          color: AppColors.divider.withValues(alpha: 0.4),
          strokeWidth: 1,
        ),
        getDrawingVerticalLine: (_) => FlLine(
          color: AppColors.divider.withValues(alpha: 0.2),
          strokeWidth: 1,
          dashArray: [4, 4],
        ),
      ),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(),
        topTitles: const AxisTitles(),
        bottomTitles: AxisTitles(
          axisNameWidget: Text('Usia (Bulan)', style: GoogleFonts.nunito(fontSize: 10, color: AppColors.textMuted)),
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 26,
            interval: 2,
            getTitlesWidget: (v, _) => Text(
              v.toInt().toString(),
              style: GoogleFonts.nunito(fontSize: 10, color: AppColors.textMuted),
            ),
          ),
        ),
        leftTitles: AxisTitles(
          axisNameWidget: Text(_showWeight ? 'Berat (kg)' : 'Tinggi (cm)', style: GoogleFonts.nunito(fontSize: 10, color: AppColors.textMuted)),
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            interval: _showWeight ? 2 : 10,
            getTitlesWidget: (v, _) => Text(
              v.toStringAsFixed(0),
              style: GoogleFonts.nunito(fontSize: 10, color: AppColors.textMuted),
            ),
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: maxX,
      lineBarsData: [
        // WHO Reference Curve
        LineChartBarData(
          spots: whoSpots,
          isCurved: true,
          color: refColor,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          dashArray: [5, 5],
        ),
        // Actual Data Curve
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
              radius: 5,
              color: color,
              strokeWidth: 2,
              strokeColor: Colors.white,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            color: color.withValues(alpha: 0.1),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final isRef = spot.barIndex == 0;
              return LineTooltipItem(
                isRef ? 'WHO: ${spot.y.toStringAsFixed(1)}' : spot.y.toStringAsFixed(1),
                GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
        ),
      ),
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

  Widget _buildChildDropdown() {
    return PopupMenuButton<ChildProfile>(
      onSelected: _switchChild,
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.swap_horiz_rounded, size: 16, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              'Ganti',
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
      itemBuilder: (_) => _children.map((child) {
        final isBoy = child.gender == 'Laki-laki';
        final isSelected = _child?.id == child.id;
        return PopupMenuItem<ChildProfile>(
          value: child,
          child: Row(
            children: [
              Icon(
                isBoy ? Icons.boy_rounded : Icons.girl_rounded,
                size: 22,
                color: isBoy ? const Color(0xFF42A5F5) : const Color(0xFFEC407A),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  child.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.primary : AppColors.textDark,
                  ),
                ),
              ),
              Text(
                '${child.ageInMonths} bln',
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.primary),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}
