import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../models/child_profile.dart';
import '../../models/milestone.dart';
import '../../widgets/milestone_checklist_item.dart';
import '../../widgets/progress_bar.dart';

class EmosionalScreen extends StatefulWidget {
  const EmosionalScreen({super.key});
  @override
  State<EmosionalScreen> createState() => _EmosionalScreenState();
}

class _EmosionalScreenState extends State<EmosionalScreen> {
  final _db = DatabaseHelper();
  ChildProfile? _child;
  List<Milestone> _milestones = [];
  Set<int> _achieved = {};
  bool _loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is ChildProfile) { _child = arg; _loadData(); }
  }

  Future<void> _loadData() async {
    if (_child == null) return;
    _milestones = await _db.getMilestones('sosial_emosional', _child!.ageInMonths);
    final records = await _db.getMilestoneRecords(_child!.id!, _child!.ageInMonths);
    _achieved = records.where((r) => r.isAchieved).map((r) => r.milestoneId).toSet();
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _toggle(int id) async {
    final isNow = !_achieved.contains(id);
    await _db.upsertMilestoneRecord(_child!.id!, id, isNow, _child!.ageInMonths);
    setState(() {
      if (isNow) {
        _achieved.add(id);
      } else {
        _achieved.remove(id);
      }
    });
  }

  double get _progress => _milestones.isEmpty ? 0 : _achieved.where((id) => _milestones.any((m) => m.id == id)).length / _milestones.length * 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(backgroundColor: const Color(0xFFE91E63), foregroundColor: Colors.white,
        title: Text('Sosial & Emosional', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)), elevation: 0),
      body: _loading ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFE91E63).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                child: Row(children: [const Icon(Icons.child_care_rounded, color: Color(0xFFE91E63), size: 22), const SizedBox(width: 10),
                  Text('${_child?.name ?? ''} • ${_child?.ageInMonths ?? 0} bulan', style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFFE91E63)))])),
              const SizedBox(height: 20),
              Text('Perkembangan Sosial & Emosional', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const SizedBox(height: 4),
              Text('Kemampuan berinteraksi dan mengelola emosi', style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textMuted)),
              const SizedBox(height: 10),
              CustomProgressBar(label: 'Progress', percentage: _progress, color: const Color(0xFFE91E63)),
              const SizedBox(height: 8),
              ..._milestones.map((m) => MilestoneChecklistItem(text: m.description, isChecked: _achieved.contains(m.id), onChanged: (_) => _toggle(m.id!))),
              if (_milestones.isEmpty) ...[const SizedBox(height: 40), Center(child: Column(children: [
                Icon(Icons.info_outline, size: 48, color: AppColors.textMuted.withValues(alpha: 0.4)), const SizedBox(height: 12),
                Text('Belum ada milestone untuk usia ini', style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textMuted))]))],
            ])),
    );
  }
}
