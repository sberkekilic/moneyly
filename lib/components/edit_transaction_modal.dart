import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../models/transaction.dart';
import '../../models/category.dart';

class EditTransactionModal extends StatefulWidget {
  final Transaction transaction;
  final List<CategoryData> userCategories;
  final Function(Transaction) onTransactionUpdated;
  final Function(int, bool) onTransactionDeleted;

  const EditTransactionModal({
    super.key,
    required this.transaction,
    required this.userCategories,
    required this.onTransactionUpdated,
    required this.onTransactionDeleted,
  });

  @override
  State<EditTransactionModal> createState() => _EditTransactionModalState();
}

class _EditTransactionModalState extends State<EditTransactionModal> {
  late Transaction _editedTransaction;

  final title = TextEditingController();
  final amount = TextEditingController();
  final description = TextEditingController();

  String? category;
  String? subcategory;
  DateTime? date;
  bool isProvisioned = false;

  @override
  void initState() {
    super.initState();

    _editedTransaction = widget.transaction;

    title.text = widget.transaction.title;
    amount.text = widget.transaction.amount.toStringAsFixed(2);
    description.text = widget.transaction.description;

    category = widget.transaction.category;
    subcategory = widget.transaction.subcategory;

    date = widget.transaction.date;
    isProvisioned = widget.transaction.isProvisioned;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * .9,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Column(
        children: [

          /// DRAG HANDLE
          Container(
            margin: EdgeInsets.only(top: 10.h, bottom: 10.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: Colors.grey.withOpacity(.4),
            ),
          ),

          /// HEADER
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [

                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(LucideIcons.x, size: 22.sp),
                ),

                Expanded(
                  child: Text(
                    "İşlem Düzenle",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                IconButton(
                  onPressed: _saveTransaction,
                  icon: Icon(
                    LucideIcons.check,
                    size: 22.sp,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 10.h),

          /// CONTENT
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  if (_editedTransaction.isInstallment)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(14.w),
                      margin: EdgeInsets.only(bottom: 18.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14.r),
                        color: Colors.deepPurple.withOpacity(.08),
                        border: Border.all(
                          color: Colors.deepPurple.withOpacity(.25),
                        ),
                      ),
                      child: Row(
                        children: [

                          Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.deepPurple.withOpacity(.15),
                            ),
                            child: const Icon(
                              LucideIcons.creditCard,
                              size: 18,
                              color: Colors.deepPurple,
                            ),
                          ),

                          SizedBox(width: 12.w),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Text(
                                  "Taksitli İşlem",
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.deepPurple,
                                  ),
                                ),

                                SizedBox(height: 2),

                                Text(
                                  "${_editedTransaction.installment ?? 1}/${_editedTransaction.installment} taksit",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12.sp,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  _Input(
                    icon: LucideIcons.textAlignCenter,
                    label: "Başlık",
                    child: TextField(
                      controller: title,
                      decoration: const InputDecoration(
                        hintText: "İşlem başlığı",
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  _Input(
                    icon: LucideIcons.wallet,
                    label: "Tutar",
                    child: TextField(
                      controller: amount,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "0.00",
                        suffixText: widget.transaction.currency,
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  _Input(
                    icon: LucideIcons.tag,
                    label: "Kategori",
                    child: DropdownButton<String>(
                      value: category,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: widget.userCategories
                          .map((c) => c.category)
                          .toSet()
                          .map(
                            (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ),
                      )
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          category = v;
                          subcategory = null;
                        });
                      },
                    ),
                  ),

                  SizedBox(height: 16.h),

                  if (category != null)
                    _Input(
                      icon: LucideIcons.tag,
                      label: "Alt kategori",
                      child: DropdownButton<String>(
                        value: subcategory,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: widget.userCategories
                            .where((c) => c.category == category)
                            .map((c) => c.subcategory)
                            .toSet()
                            .map(
                              (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ),
                        )
                            .toList(),
                        onChanged: (v) {
                          setState(() {
                            subcategory = v;
                          });
                        },
                      ),
                    ),

                  SizedBox(height: 16.h),

                  _Input(
                    icon: LucideIcons.calendar,
                    label: "Tarih",
                    child: InkWell(
                      onTap: _pickDate,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Text(
                          DateFormat("dd MMM yyyy", "tr_TR").format(date!),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  _Input(
                    icon: LucideIcons.alignCenterVertical,
                    label: "Açıklama",
                    child: TextField(
                      controller: description,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: "Açıklama",
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  SwitchListTile.adaptive(
                    value: isProvisioned,
                    title: Text(
                      "Provizyon",
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text("Henüz ödenmemiş işlem"),
                    secondary: const Icon(LucideIcons.clock),
                    onChanged: (v) => setState(() => isProvisioned = v),
                  ),

                  SizedBox(height: 30.h),

                  /// DELETE BUTTON
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);

                      widget.onTransactionDeleted(
                        widget.transaction.transactionId,
                        widget.transaction.isInstallment,
                      );
                    },
                    icon: const Icon(LucideIcons.trash2),
                    label: const Text("İşlemi Sil"),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50.h),
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red.withOpacity(.4)),
                    ),
                  ),

                  SizedBox(height: 30.h),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: date ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (d != null) {
      setState(() => date = d);
    }
  }

  void _saveTransaction() {
    final updated = widget.transaction.copyWith(
      title: title.text,
      amount: double.parse(amount.text),
      date: date!,
      category: category!,
      subcategory: subcategory ?? "Genel",
      description: description.text,
      isProvisioned: isProvisioned,
    );

    widget.onTransactionUpdated(updated);

    Navigator.pop(context);
  }
}

class _Input extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;

  const _Input({
    required this.icon,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).hintColor,
          ),
        ),

        SizedBox(height: 6),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Theme.of(context).cardColor,
          ),
          child: Row(
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 10),
              Expanded(child: child),
            ],
          ),
        ),
      ],
    );
  }
}