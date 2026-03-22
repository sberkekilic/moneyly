import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../models/investment_models.dart';

// ════════════════════════════════════════════════════════════
// GOAL CARD — The main card with +/- buttons
// ════════════════════════════════════════════════════════════

class GoalCard extends StatelessWidget {
  final Investment investment;
  final InvestmentModel model;
  final String currencySymbol;
  final Function(double) onAdd;
  final Function(double) onRemove;
  final VoidCallback onDelete;

  const GoalCard({
    super.key,
    required this.investment,
    required this.model,
    required this.currencySymbol,
    required this.onAdd,
    required this.onRemove,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final mutedColor = isDark ? Colors.white54 : Colors.grey.shade600;
    final cardBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;

    final target = double.tryParse(investment.amount) ?? 0.0;
    final saved = model.aim;
    final remaining = (target - saved).clamp(0.0, double.infinity);
    final progress = target > 0 ? (saved / target).clamp(0.0, 1.0) : 0.0;
    final isComplete = progress >= 1.0;

    final hasDeadline = investment.deadline != null;
    final dateText = hasDeadline
        ? DateFormat('d MMM yyyy', 'tr').format(investment.deadline!)
        : 'Tarih yok';
    final daysLeft = hasDeadline ? investment.deadline!.difference(DateTime.now()).inDays : 0;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
          boxShadow: isDark
              ? []
              : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: Avatar + Name + Delete ──
            Row(
              children: [
                _MonogramAvatar(name: investment.name, size: 44),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        investment.name,
                        style: GoogleFonts.montserrat(fontSize: 15.sp, fontWeight: FontWeight.w600, color: textColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Hedef: ${_fmtCurrency(target)} $currencySymbol',
                        style: GoogleFonts.montserrat(fontSize: 13.sp, color: mutedColor),
                      ),
                    ],
                  ),
                ),
                _IconBtn(icon: LucideIcons.trash2, color: Colors.red, onTap: () => _confirmDelete(context)),
              ],
            ),

            SizedBox(height: 16.h),

            // ── Saved vs Remaining ──
            Row(
              children: [
                Expanded(
                  child: _InfoBlock(
                    label: 'Biriken',
                    value: '${_fmtCurrency(saved)} $currencySymbol',
                    valueColor: Colors.blueAccent,
                    isDark: isDark,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _InfoBlock(
                    label: 'Kalan',
                    value: '${_fmtCurrency(remaining)} $currencySymbol',
                    valueColor: isComplete ? Colors.green : Colors.orange,
                    isDark: isDark,
                  ),
                ),
              ],
            ),

            SizedBox(height: 14.h),

            // ── Progress ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('İlerleme', style: GoogleFonts.montserrat(fontSize: 12.sp, color: mutedColor)),
                Text(
                  '%${(progress * 100).toStringAsFixed(1)}',
                  style: GoogleFonts.montserrat(fontSize: 12.sp, fontWeight: FontWeight.bold, color: textColor),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8.h,
                backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
                color: isComplete ? Colors.green : Colors.blueAccent,
              ),
            ),

            SizedBox(height: 14.h),

            // ── Date Info ──
            Row(
              children: [
                Icon(LucideIcons.calendar, size: 14.r, color: mutedColor),
                SizedBox(width: 4.w),
                Text(dateText, style: GoogleFonts.montserrat(fontSize: 12.sp, color: mutedColor)),
                const Spacer(),
                if (hasDeadline && daysLeft >= 0)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: daysLeft < 30 ? Colors.red.withOpacity(0.08) : Colors.green.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      '$daysLeft gün kaldı',
                      style: GoogleFonts.montserrat(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: daysLeft < 30 ? Colors.red : Colors.green,
                      ),
                    ),
                  ),
              ],
            ),

            Divider(height: 24.h, color: isDark ? Colors.white10 : Colors.grey.shade200),

            // ── +/- Buttons ──
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: LucideIcons.plus,
                    label: 'Para Ekle',
                    color: Colors.green,
                    onTap: () => _showAmountSheet(context, 'Para Ekle', Colors.green, onAdd),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _ActionButton(
                    icon: LucideIcons.minus,
                    label: 'Para Çıkar',
                    color: Colors.orange,
                    onTap: () => _showAmountSheet(context, 'Para Çıkar', Colors.orange, onRemove),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Hedefi Sil', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        content: Text('"${investment.name}" hedefini silmek istediğinize emin misiniz?',
            style: GoogleFonts.montserrat()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              onDelete();
              Navigator.pop(ctx);
            },
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _showAmountSheet(BuildContext context, String title, Color color, Function(double) onConfirm) {
    final controller = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Preset amounts
    final presets = [50.0, 100.0, 250.0, 500.0, 1000.0];

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20.r, right: 20.r, top: 12.r,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.r,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36.w, height: 4.h,
                decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            SizedBox(height: 20.h),

            // Title
            Row(
              children: [
                Icon(LucideIcons.coins, color: color, size: 22.r),
                SizedBox(width: 8.w),
                Text(title, style: GoogleFonts.montserrat(fontSize: 18.sp, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              investment.name,
              style: GoogleFonts.montserrat(fontSize: 13.sp, color: Colors.blueAccent, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 20.h),

            // Quick amounts
            Text('Hızlı Seçim', style: GoogleFonts.montserrat(fontSize: 12.sp, color: Colors.grey)),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: presets.map((amount) {
                return ActionChip(
                  label: Text('$currencySymbol${amount.toInt()}'),
                  labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 13.sp),
                  backgroundColor: color.withOpacity(0.08),
                  side: BorderSide(color: color.withOpacity(0.2)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  onPressed: () {
                    onConfirm(amount);
                    Navigator.pop(ctx);
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 20.h),

            // Custom amount
            Text('Özel Miktar', style: GoogleFonts.montserrat(fontSize: 12.sp, color: Colors.grey)),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    autofocus: false,
                    style: GoogleFonts.montserrat(),
                    decoration: InputDecoration(
                      hintText: 'Miktar girin',
                      prefixIcon: Icon(LucideIcons.dollarSign, size: 18.r, color: Colors.grey),
                      filled: true,
                      fillColor: isDark ? Colors.black12 : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                SizedBox(
                  height: 48.h,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: color,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    onPressed: () {
                      final val = double.tryParse(controller.text);
                      if (val != null && val > 0) {
                        onConfirm(val);
                        Navigator.pop(ctx);
                      }
                    },
                    child: Text(
                      title.split(' ').last,
                      style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }

  String _fmtCurrency(double v) => NumberFormat.currency(locale: 'tr', symbol: '', decimalDigits: 2).format(v);
}

// ════════════════════════════════════════════════════════════
// INTERNAL WIDGETS
// ════════════════════════════════════════════════════════════

class _InfoBlock extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final bool isDark;

  const _InfoBlock({required this.label, required this.value, required this.valueColor, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.montserrat(fontSize: 11.sp, color: isDark ? Colors.white38 : Colors.grey)),
          SizedBox(height: 4.h),
          Text(
            value,
            style: GoogleFonts.montserrat(fontSize: 14.sp, fontWeight: FontWeight.w600, color: valueColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18.r, color: color),
              SizedBox(width: 6.w),
              Text(
                label,
                style: GoogleFonts.montserrat(color: color, fontWeight: FontWeight.w600, fontSize: 13.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10.r)),
        child: Icon(icon, size: 16.r, color: color),
      ),
    );
  }
}

class _MonogramAvatar extends StatelessWidget {
  final String name;
  final double size;

  const _MonogramAvatar({required this.name, this.size = 48});

  String _initials(String t) {
    if (t.trim().isEmpty) return '?';
    final p = t.trim().split(' ');
    return p.length > 1 ? '${p[0][0]}${p[1][0]}' : p[0][0];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hue = (name.hashCode.abs() % 360).toDouble();
    final bg = HSLColor.fromAHSL(1, hue, isDark ? 0.3 : 0.35, isDark ? 0.2 : 0.92).toColor();
    final fg = HSLColor.fromAHSL(1, hue, isDark ? 0.5 : 0.6, isDark ? 0.7 : 0.3).toColor();

    return Container(
      width: size.r,
      height: size.r,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        _initials(name).toUpperCase(),
        style: GoogleFonts.montserrat(color: fg, fontSize: size * 0.38, fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// ADD INVESTMENT BOTTOM SHEET
// ════════════════════════════════════════════════════════════

class AddInvestmentBottomSheet extends StatefulWidget {
  final String category;
  final Function(Investment, InvestmentModel) onSave;
  final Function(double) onCategoryValueAdded;

  const AddInvestmentBottomSheet({
    super.key,
    required this.category,
    required this.onSave,
    required this.onCategoryValueAdded,
  });

  @override
  State<AddInvestmentBottomSheet> createState() => _AddInvestmentBottomSheetState();
}

class _AddInvestmentBottomSheetState extends State<AddInvestmentBottomSheet> {
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  DateTime? _selectedDate;
  String _selectedCurrency = 'Türk Lirası';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final mutedColor = isDark ? Colors.white54 : Colors.grey.shade600;

    return Container(
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      padding: EdgeInsets.only(
        left: 20.r, right: 20.r, top: 12.r,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.r,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36.w, height: 4.h,
                decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            SizedBox(height: 20.h),
            Text('Yeni Birikim Hedefi', style: GoogleFonts.montserrat(fontSize: 20.sp, fontWeight: FontWeight.bold, color: textColor)),
            SizedBox(height: 4.h),
            Text(widget.category, style: GoogleFonts.montserrat(fontSize: 14.sp, color: Colors.blueAccent, fontWeight: FontWeight.w500)),
            SizedBox(height: 24.h),

            // Currency
            _label('Döviz Cinsi', mutedColor),
            SizedBox(height: 10.h),
            Row(children: [
              _chip('Dolar', r'$', isDark),
              SizedBox(width: 8.w),
              _chip('Euro', '€', isDark),
              SizedBox(width: 8.w),
              _chip('Türk Lirası', '₺', isDark),
            ]),
            SizedBox(height: 20.h),

            _label('Hedef İsmi', mutedColor),
            SizedBox(height: 8.h),
            _field(ctrl: _nameCtrl, icon: LucideIcons.tag, hint: 'Örn: Ev peşinatı', isDark: isDark),
            SizedBox(height: 16.h),

            _label('Hedef Miktarı', mutedColor),
            SizedBox(height: 8.h),
            _field(ctrl: _amountCtrl, icon: LucideIcons.dollarSign, hint: 'Örn: 50000', isDark: isDark, isNum: true),
            SizedBox(height: 16.h),

            _label('Hedef Tarihi', mutedColor),
            SizedBox(height: 8.h),
            _datePicker(isDark, textColor, mutedColor),
            SizedBox(height: 32.h),

            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                ),
                onPressed: _submit,
                child: Text('Hedef Oluştur', style: GoogleFonts.montserrat(fontSize: 15.sp, fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  Widget _label(String t, Color c) => Text(t, style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 13.sp, color: c));

  Widget _field({required TextEditingController ctrl, required IconData icon, required String hint, required bool isDark, bool isNum = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNum ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      style: GoogleFonts.montserrat(fontSize: 14.sp),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 18.r, color: Colors.grey),
        hintText: hint,
        hintStyle: GoogleFonts.montserrat(color: Colors.grey),
        filled: true,
        fillColor: isDark ? Colors.black12 : Colors.grey.shade100,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5)),
      ),
    );
  }

  Widget _chip(String val, String sym, bool isDark) {
    final sel = _selectedCurrency == val;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedCurrency = val),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: sel ? Colors.blueAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: sel ? Colors.blueAccent : (isDark ? Colors.white12 : Colors.grey.shade300)),
          ),
          alignment: Alignment.center,
          child: Text(
            '$sym $val',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 12.sp, color: sel ? Colors.white : (isDark ? Colors.white54 : Colors.grey)),
          ),
        ),
      ),
    );
  }

  Widget _datePicker(bool isDark, Color textColor, Color mutedColor) {
    return InkWell(
      onTap: () async {
        final result = await showDialog<DateTime>(
          context: context,
          builder: (_) => _DatePickerDialog(initialDate: _selectedDate),
        );
        if (result != null) setState(() => _selectedDate = result);
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isDark ? Colors.black12 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300),
        ),
        child: Row(children: [
          Icon(LucideIcons.calendar, size: 18.r, color: Colors.blueAccent),
          SizedBox(width: 12.w),
          Text(
            _selectedDate != null ? DateFormat('dd MMMM yyyy', 'tr').format(_selectedDate!) : 'Tarih seçin',
            style: GoogleFonts.montserrat(
              color: _selectedDate != null ? textColor : mutedColor,
              fontWeight: FontWeight.w500, fontSize: 14.sp,
            ),
          ),
        ]),
      ),
    );
  }

  void _submit() {
    if (_nameCtrl.text.trim().isEmpty || _amountCtrl.text.trim().isEmpty || _selectedDate == null) {
      _snack('Lütfen tüm alanları doldurun');
      return;
    }
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) {
      _snack('Geçerli bir miktar girin');
      return;
    }

    final id = DateTime.now().millisecondsSinceEpoch;
    final inv = Investment(
      id: id,
      name: _nameCtrl.text.trim(),
      category: widget.category,
      currency: _selectedCurrency,
      deadline: _selectedDate!,
      amount: _amountCtrl.text.trim(),
    );
    final model = InvestmentModel(id: id, aim: 0, amount: amount);

    widget.onSave(inv, model);
    widget.onCategoryValueAdded(amount);
    Navigator.pop(context);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.montserrat()),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }
}

// ════════════════════════════════════════════════════════════
// DATE PICKER DIALOG (uses Syncfusion)
// ════════════════════════════════════════════════════════════

class _DatePickerDialog extends StatefulWidget {
  final DateTime? initialDate;
  const _DatePickerDialog({this.initialDate});

  @override
  State<_DatePickerDialog> createState() => _DatePickerDialogState();
}

class _DatePickerDialogState extends State<_DatePickerDialog> {
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate ?? DateTime.now().add(const Duration(days: 30));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              Icon(LucideIcons.calendar, color: Colors.blueAccent, size: 22.r),
              SizedBox(width: 8.w),
              Text('Hedef Tarihi', style: GoogleFonts.montserrat(fontSize: 18.sp, fontWeight: FontWeight.bold, color: textColor)),
            ]),
            SizedBox(height: 16.h),
            SizedBox(
              height: 300.h,
              child: SfDateRangePicker(
                onSelectionChanged: (args) {
                  if (args.value is DateTime) setState(() => _date = args.value);
                },
                selectionMode: DateRangePickerSelectionMode.single,
                selectionColor: Colors.blueAccent,
                todayHighlightColor: Colors.blueAccent,
                initialSelectedDate: _date,
                initialDisplayDate: _date,
                minDate: DateTime.now(),
                showNavigationArrow: true,
                headerHeight: 50,
                headerStyle: DateRangePickerHeaderStyle(
                  textStyle: GoogleFonts.montserrat(color: textColor, fontWeight: FontWeight.bold, fontSize: 15.sp),
                ),
                monthCellStyle: DateRangePickerMonthCellStyle(
                  textStyle: GoogleFonts.montserrat(fontSize: 14.sp, color: textColor),
                  todayTextStyle: GoogleFonts.montserrat(color: Colors.blueAccent, fontSize: 14.sp, fontWeight: FontWeight.bold),
                  disabledDatesTextStyle: GoogleFonts.montserrat(color: isDark ? Colors.white12 : Colors.grey.shade300),
                ),
                monthViewSettings: DateRangePickerMonthViewSettings(
                  viewHeaderStyle: DateRangePickerViewHeaderStyle(
                    textStyle: GoogleFonts.montserrat(fontSize: 12.sp, fontWeight: FontWeight.w600, color: isDark ? Colors.white54 : Colors.grey.shade600),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Row(children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('İptal', style: GoogleFonts.montserrat(color: Colors.grey)),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  onPressed: () => Navigator.pop(context, _date),
                  child: Text('Tamam', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}