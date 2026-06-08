import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../models/reminder.dart';
import '../../services/notification_service.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});
  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final _db = DatabaseHelper();
  List<Reminder> _reminders = [];
  bool _loading = true;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('user_id');
    if (_userId != null) {
      _reminders = await _db.getReminders(_userId!);
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _toggleComplete(Reminder r, bool isCompleted) async {
    final updated = r.copyWith(isCompleted: isCompleted);
    await _db.updateReminder(updated);
    if (isCompleted) {
      await NotificationService().cancelNotification(updated.id!);
    } else {
      await NotificationService().scheduleNotification(
        id: updated.id!,
        title: updated.title,
        body: updated.description,
        scheduledDate: updated.dateTime,
      );
    }
    _loadData();
  }

  Future<void> _delete(Reminder r) async {
    await _db.deleteReminder(r.id!);
    await NotificationService().cancelNotification(r.id!);
    _loadData();
  }

  void _showAddDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(hours: 1));

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateBuilder) {
            return AlertDialog(
              backgroundColor: AppColors.bgCream,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('Tambah Pengingat', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.textDark)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      decoration: InputDecoration(
                        labelText: 'Judul (Mis. Imunisasi Polio)',
                        labelStyle: GoogleFonts.nunito(color: AppColors.textMuted),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descCtrl,
                      decoration: InputDecoration(
                        labelText: 'Keterangan',
                        labelStyle: GoogleFonts.nunito(color: AppColors.textMuted),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Waktu: ${DateFormat('dd MMM yyyy, HH:mm').format(selectedDate)}',
                        style: GoogleFonts.nunito(color: AppColors.textDark, fontWeight: FontWeight.w600),
                      ),
                      trailing: const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (d != null) {
                          if (!context.mounted) return;
                          final t = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(selectedDate),
                          );
                          if (t != null) {
                            setStateBuilder(() {
                              selectedDate = DateTime(d.year, d.month, d.day, t.hour, t.minute);
                            });
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Batal', style: GoogleFonts.nunito(color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (titleCtrl.text.isEmpty) return;
                    final r = Reminder(
                      userId: _userId!,
                      title: titleCtrl.text,
                      description: descCtrl.text,
                      dateTime: selectedDate,
                    );
                    final id = await _db.insertReminder(r);
                    await NotificationService().scheduleNotification(
                      id: id,
                      title: r.title,
                      body: r.description,
                      scheduledDate: r.dateTime,
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                    _loadData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Simpan', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
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
          'Pengingat',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _reminders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off_rounded, size: 64, color: AppColors.textMuted.withValues(alpha: 0.4)),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada pengingat',
                        style: GoogleFonts.nunito(color: AppColors.textMuted, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _reminders.length,
                  itemBuilder: (ctx, i) {
                    final r = _reminders[i];
                    final isPast = r.dateTime.isBefore(DateTime.now()) && !r.isCompleted;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: isPast ? Border.all(color: Colors.red.withValues(alpha: 0.3)) : null,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.textDark.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Checkbox(
                          value: r.isCompleted,
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          onChanged: (val) => _toggleComplete(r, val ?? false),
                        ),
                        title: Text(
                          r.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: r.isCompleted ? AppColors.textMuted : AppColors.textDark,
                            decoration: r.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            if (r.description.isNotEmpty) ...[
                              Text(
                                r.description,
                                style: GoogleFonts.nunito(
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
                            Row(
                              children: [
                                Icon(Icons.access_time_rounded, size: 14, color: isPast ? Colors.red : AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat('dd MMM yyyy, HH:mm').format(r.dateTime),
                                  style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isPast ? Colors.red : AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                          onPressed: () => _delete(r),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _showAddDialog,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}
