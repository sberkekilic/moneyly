import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/add-expense/faturalar.dart';
import 'transaction.dart';

class TransactionWidget extends StatefulWidget {
  final List<Transaction> transactions;
  final List<Invoice> invoices;
  final DateTime? startDate;
  final DateTime? endDate;

  const TransactionWidget({
    Key? key,
    required this.transactions,
    required this.invoices,
    this.startDate,
    this.endDate,
  }) : super(key: key);

  @override
  _TransactionWidgetState createState() => _TransactionWidgetState();
}

class _TransactionWidgetState extends State<TransactionWidget> {
  int currentPage = 0;
  final int itemsPerPage = 6;
  Map<String, List<Map<String, dynamic>>> incomeMap = {};
  double incomeValue = 0.0;
  final _formKey = GlobalKey<FormState>();
  int? editingTransactionId;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _installmentController = TextEditingController();
  DateTime? selectedDate;
  String currency = 'USD';
  bool isSurplus = true;
  bool isFromInvoice = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _deleteTransaction(int id) async {
    await TransactionService.deleteTransaction(id);
    setState(() {});
  }

  void _showEditTransactionDialog(Transaction transaction) {
    final _formKey = GlobalKey<FormState>();

    TextEditingController _amountController = TextEditingController(text: transaction.amount.toString());
    TextEditingController _descriptionController = TextEditingController(text: transaction.description);
    TextEditingController _titleController = TextEditingController(text: transaction.title);
    TextEditingController _installmentController = TextEditingController(text: transaction.installment?.toString() ?? '');
    DateTime? selectedDate = transaction.date;
    DateTime? initialInstallmentDate = transaction.initialInstallmentDate;
    bool isSurplus = transaction.isSurplus;
    bool isFromInvoice = transaction.isFromInvoice;
    String currency = transaction.currency;
    String selectedCategory = transaction.category;
    String selectedSubcategory = transaction.subcategory;

    // FIX: Ensure unique values by using a proper data structure
    final Map<String, List<String>> categoryMap = {
      "Abonelikler": ["TV", "Oyun", "Müzik"],
      "Faturalar": ["Ev Faturaları", "İnternet", "Telefon"],
      "Diğer Giderler": ["Kira", "Mutfak", "Yeme İçme", "Eğlence", "Diğer"],
      "Gelir": ["İş", "Burs", "Emekli", "Maaş"],
    };

    // FIX: Create a list of unique category keys
    final List<String> categoryKeys = categoryMap.keys.toList();

    void _pickDate(BuildContext context, Function(DateTime) onDateSelected) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2050),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              dialogBackgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[900]
                  : Colors.white,
            ),
            child: child!,
          );
        },
      );
      if (picked != null) {
        onDateSelected(picked);
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[900]
              : Colors.white,
          child: Padding(
            padding: EdgeInsets.all(20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'İşlem Düzenle',
                  style: GoogleFonts.montserrat(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 16.h),
                Expanded(
                  child: SingleChildScrollView(
                    child: StatefulBuilder(
                      builder: (context, setState) {
                        // FIX: Get current subcategories based on selected category
                        final currentSubcategories = categoryMap[selectedCategory] ?? [];

                        return Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTextField(_titleController, 'Başlık'),
                              SizedBox(height: 12.h),
                              _buildTextField(_amountController, 'Miktar', keyboardType: TextInputType.number),
                              SizedBox(height: 12.h),
                              _buildTextField(_descriptionController, 'Açıklama'),
                              SizedBox(height: 12.h),
                              _buildTextField(_installmentController, 'Taksit (opsiyonel)', keyboardType: TextInputType.number),
                              SizedBox(height: 16.h),

                              _buildDropdown(
                                'Para Birimi',
                                currency,
                                ['USD', 'EUR', 'TRY'],
                                    (value) => setState(() => currency = value!),
                              ),
                              SizedBox(height: 16.h),

                              // FIX: Category dropdown with unique values
                              _buildDropdown(
                                'Kategori',
                                selectedCategory,
                                categoryKeys,
                                    (value) => setState(() {
                                  selectedCategory = value!;
                                  // Reset subcategory to first item of new category
                                  selectedSubcategory = categoryMap[selectedCategory]?.first ?? '';
                                }),
                              ),
                              SizedBox(height: 16.h),

                              // FIX: Subcategory dropdown with current subcategories
                              _buildDropdown(
                                'Alt Kategori',
                                selectedSubcategory,
                                currentSubcategories,
                                    (value) => setState(() => selectedSubcategory = value!),
                              ),
                              SizedBox(height: 16.h),

                              _buildSwitchTile('Gelir', isSurplus, (value) => setState(() => isSurplus = value)),
                              SizedBox(height: 8.h),
                              _buildSwitchTile('Faturadan', isFromInvoice, (value) => setState(() => isFromInvoice = value)),
                              SizedBox(height: 16.h),

                              _buildDateTile('Tarih', selectedDate, () => _pickDate(context, (date) => setState(() => selectedDate = date))),
                              SizedBox(height: 8.h),
                              _buildDateTile('Taksit Başlangıç', initialInstallmentDate, () => _pickDate(context, (date) => setState(() => initialInstallmentDate = date))),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'İptal',
                        style: GoogleFonts.montserrat(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) return;

                        setState(() {
                          transaction.amount = double.parse(_amountController.text);
                          transaction.description = _descriptionController.text;
                          transaction.title = _titleController.text;
                          transaction.currency = currency;
                          transaction.isSurplus = isSurplus;
                          transaction.isFromInvoice = isFromInvoice;
                          transaction.category = selectedCategory;
                          transaction.subcategory = selectedSubcategory;
                          transaction.date = selectedDate!;
                          transaction.initialInstallmentDate = initialInstallmentDate;
                          transaction.installment = _installmentController.text.isNotEmpty
                              ? int.tryParse(_installmentController.text)
                              : null;
                        });

                        TransactionService.updateTransaction(transaction);
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Kaydet',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.montserrat(fontSize: 12.sp),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]!.withOpacity(0.3)
            : Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
      validator: (value) {
        if (label.contains("opsiyonel")) return null;
        if (value == null || value.isEmpty) return 'Lütfen $label giriniz';
        return null;
      },
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    // FIX: Ensure the current value exists in the items list
    final String currentValue = items.contains(value) ? value : (items.isNotEmpty ? items.first : '');

    return DropdownButtonFormField<String>(
      value: currentValue,
      items: items.map((item) => DropdownMenuItem(
        value: item,
        child: Text(
          item,
          style: GoogleFonts.montserrat(fontSize: 12.sp),
        ),
      )).toList(),
      onChanged: onChanged,
      style: GoogleFonts.montserrat(fontSize: 12.sp),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]!.withOpacity(0.3)
            : Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Lütfen $label seçiniz';
        }
        return null;
      },
    );
  }

  Widget _buildSwitchTile(String label, bool value, Function(bool) onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]!.withOpacity(0.3)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(fontSize: 12.sp),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDateTile(String label, DateTime? date, Function() onTap) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
      title: Text(
        date != null ? DateFormat('d MMMM yyyy', 'tr_TR').format(date) : '$label seçin',
        style: GoogleFonts.montserrat(fontSize: 12.sp),
      ),
      leading: Icon(
        Icons.calendar_today_rounded,
        size: 18.h,
        color: Theme.of(context).colorScheme.primary,
      ),
      tileColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[800]!.withOpacity(0.3)
          : Colors.grey[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      onTap: onTap,
    );
  }

  Widget _buildTransactionCard(Transaction t, BuildContext context) {
    final dateFormat = DateFormat('d MMM yyyy', 'tr_TR');
    final moneyFormat = NumberFormat.currency(
      locale: "tr_TR",
      symbol: t.currency,
      decimalDigits: 2,
    );

    final isProvisioned = t.isProvisioned;
    final isIncome = t.isSurplus;
    final statusColor = isProvisioned
        ? Colors.orange
        : isIncome
        ? Colors.green
        : Colors.red;

    final cardColor = Theme.of(context).brightness == Brightness.dark
        ? statusColor.withOpacity(0.1)
        : statusColor.withOpacity(0.05);

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () => _showEditTransactionDialog(t),
          onLongPress: () => _showDeleteConfirmation(t.transactionId),
          child: Padding(
            padding: EdgeInsets.all(16.h),
            child: Row(
              children: [
                Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isProvisioned
                        ? Icons.pending_rounded
                        : isIncome
                        ? Icons.arrow_circle_down_rounded
                        : Icons.arrow_circle_up_rounded,
                    size: 20.h,
                    color: statusColor,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              t.title,
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w600,
                                fontSize: 12.sp,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            moneyFormat.format(t.amount),
                            style: GoogleFonts.montserrat(
                              fontSize: 12.sp,
                              color: statusColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          if (t.category.isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: Theme.of(context).dividerColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                t.category,
                                style: GoogleFonts.montserrat(
                                  fontSize: 9.sp,
                                  color: Theme.of(context).textTheme.bodySmall?.color,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          if (t.category.isNotEmpty) SizedBox(width: 8.w),
                          Text(
                            dateFormat.format(t.date),
                            style: GoogleFonts.montserrat(
                              fontSize: 10.sp,
                              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      if (t.description.isNotEmpty) ...[
                        SizedBox(height: 6.h),
                        Text(
                          t.description,
                          style: GoogleFonts.montserrat(
                            fontSize: 10.sp,
                            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.8),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(int transactionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Silme Onayı',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Bu işlemi silmek istediğinize emin misiniz?',
          style: GoogleFonts.montserrat(fontSize: 12.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              _deleteTransaction(transactionId);
              Navigator.pop(context);
            },
            child: Text(
              'Sil',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = widget.transactions.where((t) {
      final isAfterStart = widget.startDate == null ||
          !t.date.isBefore(DateTime(widget.startDate!.year, widget.startDate!.month, widget.startDate!.day));
      final isBeforeEnd = widget.endDate == null ||
          !t.date.isAfter(DateTime(widget.endDate!.year, widget.endDate!.month, widget.endDate!.day));
      return isAfterStart && isBeforeEnd;
    }).toList();

    final totalPages = (filteredTransactions.length / itemsPerPage).ceil();
    final pagedData = List.generate(
      totalPages,
          (i) => filteredTransactions.skip(i * itemsPerPage).take(itemsPerPage).toList(),
    );

    if (filteredTransactions.isEmpty) {
      return Container(
        height: 200.h, // Fixed height for empty state
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_rounded,
                size: 48.h,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
              SizedBox(height: 16.h),
              Text(
                "Hiç işlem bulunamadı",
                style: GoogleFonts.montserrat(
                  fontSize: 14.sp,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min, // Important: Use min size
      children: [
        // Transactions list with constrained height
        ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: 100.h,
            maxHeight: 400.h, // Set a reasonable max height
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: pagedData[currentPage].length,
            itemBuilder: (context, index) {
              return _buildTransactionCard(pagedData[currentPage][index], context);
            },
          ),
        ),
        SizedBox(height: 16.h),
        // Pagination controls
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]!.withOpacity(0.3)
                : Colors.grey[50],
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios_rounded, size: 18.h),
                onPressed: currentPage > 0
                    ? () => setState(() => currentPage--)
                    : null,
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[700]
                      : Colors.grey[200],
                ),
              ),
              SizedBox(width: 16.w),
              Text(
                "Sayfa ${currentPage + 1} / $totalPages",
                style: GoogleFonts.montserrat(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 16.w),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios_rounded, size: 18.h),
                onPressed: currentPage < totalPages - 1
                    ? () => setState(() => currentPage++)
                    : null,
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[700]
                      : Colors.grey[200],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          "${(currentPage * itemsPerPage + 1).clamp(1, filteredTransactions.length)}"
              " - ${(currentPage * itemsPerPage + pagedData[currentPage].length).clamp(1, filteredTransactions.length)}"
              " / ${filteredTransactions.length}",
          style: GoogleFonts.montserrat(
            fontSize: 11.sp,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  void _debugDropdownValues(String label, List<String> items, String currentValue) {
    print('=== $label Debug ===');
    print('Current value: $currentValue');
    print('Available items: $items');
    print('Duplicate check:');
    final duplicates = items.where((item) => items.where((i) => i == item).length > 1).toSet();
    if (duplicates.isNotEmpty) {
      print('DUPLICATES FOUND: $duplicates');
    }
    print('====================');
  }
}