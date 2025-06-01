import 'dart:convert';
import 'package:flutter/material.dart';
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

  TransactionWidget({
    required this.transactions,
    required this.invoices,
    this.startDate,
    this.endDate,
  });
  @override
  _TransactionWidgetState createState() => _TransactionWidgetState();
}
class _TransactionWidgetState extends State<TransactionWidget> {
  int currentPage = 0;
  final int itemsPerPage = 5;
  Map<String, List<Map<String, dynamic>>> incomeMap = {};
  double incomeValue = 0.0;
  List<Transaction> transactions = [];
  final _formKey = GlobalKey<FormState>();
  int? editingTransactionId;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _installmentController = TextEditingController();
  DateTime? selectedDate;
  String currency = 'USD';
  bool isSurplus = true;
  bool isFromInvoice = false;
  DateTime? startDate;
  DateTime? endDate;
  @override
  void initState() {
    super.initState();
  }

  Future<void> _deleteTransaction(int id) async {
    await TransactionService.deleteTransaction(id);
    //await _loadTransactions();
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

    final Map<String, List<String>> categoryMap = {
      "Abonelikler": ["TV", "Oyun", "Müzik"],
      "Faturalar": ["Ev Faturaları", "İnternet", "Telefon"],
      "Diğer Giderler": ["Kira", "Mutfak", "Yeme İçme", "Eğlence", "Diğer"],
      "Gelir": ["İş", "Burs", "Emekli", "Maaş"],
    };

    void _pickDate(BuildContext context, Function(DateTime) onDateSelected) async {
      DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2050),
      );
      if (picked != null) {
        onDateSelected(picked);
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('Edit Transaction', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(_titleController, 'Title'),
                      _buildTextField(_amountController, 'Amount', keyboardType: TextInputType.number),
                      _buildTextField(_descriptionController, 'Description'),
                      _buildTextField(_installmentController, 'Installment (optional)', keyboardType: TextInputType.number),

                      SizedBox(height: 10),
                      _buildDropdown(
                        'Currency',
                        currency,
                        ['USD', 'EUR', 'TRY'],
                            (value) => setState(() => currency = value!),
                      ),

                      SizedBox(height: 10),
                      _buildDropdown(
                        'Category',
                        selectedCategory,
                        categoryMap.keys.toList(),
                            (value) => setState(() {
                          selectedCategory = value!;
                          selectedSubcategory = categoryMap[selectedCategory]!.first;
                        }),
                      ),

                      SizedBox(height: 10),
                      _buildDropdown(
                        'Subcategory',
                        selectedSubcategory,
                        categoryMap[selectedCategory]!,
                            (value) => setState(() => selectedSubcategory = value!),
                      ),

                      SizedBox(height: 10),
                      _buildSwitchTile('Surplus', isSurplus, (value) => setState(() => isSurplus = value)),
                      _buildSwitchTile('From Invoice', isFromInvoice, (value) => setState(() => isFromInvoice = value)),

                      SizedBox(height: 10),
                      _buildDateTile('Date', selectedDate, () => _pickDate(context, (date) => setState(() => selectedDate = date))),
                      _buildDateTile('Installment Date', initialInstallmentDate, () => _pickDate(context, (date) => setState(() => initialInstallmentDate = date))),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.redAccent)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                if (!_formKey.currentState!.validate()) {
                  print("Form validation failed!");
                  return;
                }

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

                  // Ensure installment is properly set
                  transaction.installment = _installmentController.text.isNotEmpty
                      ? int.tryParse(_installmentController.text)
                      : null;

                  if (_installmentController.text.trim().isEmpty) {
                    transaction.installment = null;
                  }
                });

                TransactionService.updateTransaction(transaction);
                Navigator.of(context).pop();
              },

              child: Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
  Widget _buildTextField(TextEditingController controller, String label, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          validator: (value) {
            if (label == "Installment (optional)") {
              // Allow empty value for installment
              if (value == null || value.isEmpty) {
                return null; // No error if empty
              }
              // Check if the value is a valid number
              final int? parsedValue = int.tryParse(value);
              if (parsedValue == null) {
                return 'Please enter a valid number for $label';
              }
            } else {
              // For other fields, enforce required validation
              if (value == null || value.isEmpty) {
                return 'Please enter $label';
              }
            }
            return null;
          }
      ),
    );
  }
  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
  Widget _buildSwitchTile(String label, bool value, Function(bool) onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16)),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
  Widget _buildDateTile(String label, DateTime? date, Function() onTap) {
    return ListTile(
      title: Text(date != null ? '$label: ${DateFormat.yMMMd().format(date)}' : 'Pick $label'),
      leading: Icon(Icons.calendar_today, color: Colors.blueAccent),
      tileColor: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filtreleme
    final transactions = widget.transactions;

    bool isSameOrAfterDay(DateTime date, DateTime min) {
      final d = DateTime(date.year, date.month, date.day);
      final m = DateTime(min.year, min.month, min.day);
      return !d.isBefore(m);
    }

    bool isSameOrBeforeDay(DateTime date, DateTime max) {
      final d = DateTime(date.year, date.month, date.day);
      final m = DateTime(max.year, max.month, max.day);
      return !d.isAfter(m);
    }

    print('[DEBUG] Tüm işlemler (${transactions.length}):');
    transactions.forEach((t) => print(' - ${t.title} | ${t.date}'));

    List<Transaction> filteredTransactions = transactions.where((t) {
      final isAfterStart = widget.startDate == null || isSameOrAfterDay(t.date, widget.startDate!);
      final isBeforeEnd = widget.endDate == null || isSameOrBeforeDay(t.date, widget.endDate!);
      return isAfterStart && isBeforeEnd;
    }).toList();

    print('[DEBUG] Filtrelenmiş işlem sayısı: ${filteredTransactions.length}');

    final totalPages = (filteredTransactions.length / itemsPerPage).ceil();

    List<List<Transaction>> pagedData = List.generate(
      totalPages,
          (i) => filteredTransactions.skip(i * itemsPerPage).take(itemsPerPage).toList(),
    );

    return Column(
      children: [
        if (filteredTransactions.isEmpty)
          const Text("Hiç işlem bulunamadı")
        else ...[
          SizedBox(
            height: 500, // Kart yüksekliği kadar sabit tut
            child: PageView.builder(
              itemCount: totalPages,
              onPageChanged: (index) {
                setState(() => currentPage = index);
              },
              itemBuilder: (context, pageIndex) {
                final pageTransactions = pagedData[pageIndex];
                return ListView.builder(
                  itemCount: pageTransactions.length,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                  itemBuilder: (context, index) {
                    final t = pageTransactions[index];
                    final dateStr = DateFormat('yyyy-MM-dd').format(t.date);

                    final bool isProvisioned = t.isProvisioned;
                    final bool isIncome = t.isSurplus;

                    final cardColor = isProvisioned
                        ? Colors.orange[50]
                        : isIncome
                        ? Colors.green[50]
                        : Colors.red[50];

                    final textColor = isProvisioned
                        ? Colors.orange
                        : isIncome
                        ? Colors.green
                        : Colors.red;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      color: cardColor,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.title,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${t.category} > ${t.subcategory}',
                                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                                  ),
                                  Text(
                                    t.description,
                                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                                  ),
                                  Text(
                                    'Tarih: $dateStr',
                                    style: const TextStyle(fontSize: 12, color: Colors.black45),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${t.amount.toStringAsFixed(2)} ${t.currency}',
                              style: TextStyle(
                                fontSize: 14,
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 4),
            child: Column(
              children: [
                Text(
                  "${(currentPage * itemsPerPage + 1).clamp(1, filteredTransactions.length)}"
                      " - ${(currentPage * itemsPerPage + pagedData[currentPage].length)}"
                      " / ${filteredTransactions.length}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "Sayfa ${currentPage + 1} / $totalPages",
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}