import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../models/child_profile.dart';

class ChildProfileScreen extends StatefulWidget {
  const ChildProfileScreen({super.key});
  @override
  State<ChildProfileScreen> createState() => _ChildProfileScreenState();
}

class _ChildProfileScreenState extends State<ChildProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  String _gender = 'Laki-laki';
  DateTime _birthDate = DateTime.now().subtract(const Duration(days: 365));
  ChildProfile? _existing;
  bool _isLoading = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is ChildProfile) {
      _existing = arg;
      _nameCtrl.text = arg.name;
      _gender = arg.gender;
      _birthDate = arg.birthDate;
      _weightCtrl.text = arg.weight?.toString() ?? '';
      _heightCtrl.text = arg.height?.toString() ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        title: Text(_existing != null ? 'Edit Profil Anak' : 'Tambah Anak',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primaryPale.withValues(alpha: 0.3),
                  child: Icon(
                    _gender == 'Laki-laki' ? Icons.boy_rounded : Icons.girl_rounded,
                    size: 50, color: AppColors.primaryDark,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              _label('Nama Anak'),
              TextFormField(
                controller: _nameCtrl,
                decoration: _deco('Masukkan nama anak', Icons.person_outline),
                validator: (v) => v == null || v.isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 18),
              _label('Jenis Kelamin'),
              Row(children: [
                Expanded(child: _genderCard('Laki-laki', Icons.boy_rounded, const Color(0xFF42A5F5))),
                const SizedBox(width: 12),
                Expanded(child: _genderCard('Perempuan', Icons.girl_rounded, const Color(0xFFEC407A))),
              ]),
              const SizedBox(height: 18),
              _label('Tanggal Lahir'),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.inputBg.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(children: [
                    const Icon(Icons.calendar_today_rounded, color: AppColors.textMuted, size: 20),
                    const SizedBox(width: 12),
                    Text(DateFormat('dd MMMM yyyy').format(_birthDate),
                        style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textDark)),
                  ]),
                ),
              ),
              const SizedBox(height: 18),
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _label('Berat (kg)'),
                  TextFormField(controller: _weightCtrl, keyboardType: TextInputType.number,
                      decoration: _deco('kg', Icons.monitor_weight_outlined)),
                ])),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _label('Tinggi (cm)'),
                  TextFormField(controller: _heightCtrl, keyboardType: TextInputType.number,
                      decoration: _deco('cm', Icons.height_rounded)),
                ])),
              ]),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : Text('Simpan', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(t, style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textDark)),
  );

  InputDecoration _deco(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
    filled: true, fillColor: AppColors.inputBg.withValues(alpha: 0.5),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
  );

  Widget _genderCard(String label, IconData icon, Color color) {
    final sel = _gender == label;
    return GestureDetector(
      onTap: () => setState(() => _gender = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: sel ? color.withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: sel ? color : AppColors.divider.withValues(alpha: 0.4), width: sel ? 2 : 1),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: sel ? color : AppColors.textMuted, size: 22),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: sel ? color : AppColors.textMuted)),
        ]),
      ),
    );
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context, initialDate: _birthDate,
      firstDate: DateTime(2018), lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primaryDark)),
        child: child!,
      ),
    );
    if (d != null) setState(() => _birthDate = d);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id')!;
    final db = DatabaseHelper();
    final child = ChildProfile(
      id: _existing?.id, userId: userId, name: _nameCtrl.text.trim(),
      gender: _gender, birthDate: _birthDate,
      weight: double.tryParse(_weightCtrl.text),
      height: double.tryParse(_heightCtrl.text),
    );
    if (_existing != null) { await db.updateChild(child); } else { await db.insertChild(child); }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Data anak berhasil disimpan!'),
        backgroundColor: AppColors.primary, behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      Navigator.pop(context, true);
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() { _nameCtrl.dispose(); _weightCtrl.dispose(); _heightCtrl.dispose(); super.dispose(); }
}
