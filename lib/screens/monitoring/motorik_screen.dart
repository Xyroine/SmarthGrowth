import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../models/child_profile.dart';
import '../../models/milestone.dart';
import '../../widgets/milestone_checklist_item.dart';
import '../../widgets/progress_bar.dart';

class MotorikScreen extends StatefulWidget {
  const MotorikScreen({super.key});
  @override
  State<MotorikScreen> createState() => _MotorikScreenState();
}

class _MotorikScreenState extends State<MotorikScreen> {
  final _db = DatabaseHelper();
  ChildProfile? _child;
  List<Milestone> _kasarMilestones = [];
  List<Milestone> _halusMilestones = [];
  Set<int> _achieved = {};
  bool _loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is ChildProfile) {
      _child = arg;
      _loadData();
    }
  }

  Future<void> _loadData() async {
    if (_child == null) return;
    final age = _child!.ageInMonths;
    _kasarMilestones = await _db.getMilestonesBySubcategory('motorik_kasar', age);
    _halusMilestones = await _db.getMilestonesBySubcategory('motorik_halus', age);
    final records = await _db.getMilestoneRecords(_child!.id!, age);
    _achieved = records.where((r) => r.isAchieved).map((r) => r.milestoneId).toSet();
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _toggle(int milestoneId) async {
    final isNow = !_achieved.contains(milestoneId);
    await _db.upsertMilestoneRecord(_child!.id!, milestoneId, isNow, _child!.ageInMonths);
    setState(() {
      if (isNow) {
        _achieved.add(milestoneId);
      } else {
        _achieved.remove(milestoneId);
      }
    });
  }

  double _progress(List<Milestone> list) =>
      list.isEmpty ? 0 : _achieved.where((id) => list.any((m) => m.id == id)).length / list.length * 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        backgroundColor: AppColors.bgCream,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: Text(
          'Motorik',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Age info
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
                          '${_child?.name ?? ''} • ${_child?.ageInMonths ?? 0} bulan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Motorik Kasar
                  Text(
                    'Motorik Kasar',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kemampuan gerakan tubuh besar',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomProgressBar(
                    label: 'Progress',
                    percentage: _progress(_kasarMilestones),
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  ..._kasarMilestones.map((m) => MilestoneChecklistItem(
                        text: m.description,
                        isChecked: _achieved.contains(m.id),
                        onChanged: (_) => _toggle(m.id!),
                      )),

                  const SizedBox(height: 24),
                  Divider(color: AppColors.divider.withValues(alpha: 0.5)),
                  const SizedBox(height: 24),

                  // Motorik Halus
                  Text(
                    'Motorik Halus',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kemampuan gerakan tangan dan jari',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomProgressBar(
                    label: 'Progress',
                    percentage: _progress(_halusMilestones),
                    color: AppColors.primaryLight,
                  ),
                  const SizedBox(height: 16),
                  ..._halusMilestones.map((m) => MilestoneChecklistItem(
                        text: m.description,
                        isChecked: _achieved.contains(m.id),
                        onChanged: (_) => _toggle(m.id!),
                      )),

                  if (_kasarMilestones.isEmpty && _halusMilestones.isEmpty) ...[
                    const SizedBox(height: 40),
                    Center(
                      child: Column(
                        children: [
                          Icon(Icons.info_outline, size: 48, color: AppColors.textMuted.withValues(alpha: 0.4)),
                          const SizedBox(height: 12),
                          Text(
                            'Belum ada milestone untuk usia ini',
                            style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
