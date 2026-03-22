import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/transaction.dart';
import '../../models/category.dart';
import '../models/transaction_type.dart';

class AddTransactionModal extends StatefulWidget {
  final List<Map<String, dynamic>> accounts;
  final Map<String, dynamic>? selectedAccount;
  final Function(Transaction) onTransactionAdded;
  final List<CategoryData> userCategories;

  const AddTransactionModal({
    Key? key,
    required this.accounts,
    this.selectedAccount,
    required this.onTransactionAdded,
    required this.userCategories,
  }) : super(key: key);

  @override
  State<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  int _currentStep = 0;
  TransactionType _selectedType = TransactionType.normal;
  String? _selectedCategory;
  String? _selectedSubcategory;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _installmentCountController = TextEditingController(text: '1');
  DateTime? _transactionDate;
  DateTime? _firstInstallmentDate;
  bool _isProvisioned = false;
  Map<String, dynamic>? _selectedAccount;
  List<String> _installmentDates = [];

  @override
  void initState() {
    super.initState();
    _selectedAccount = widget.selectedAccount;
    _transactionDate = DateTime.now();
    _firstInstallmentDate = DateTime.now();
  }

  // Adım başlıkları
  final List<String> _stepTitles = ['İşlem Tipi', 'Detaylar', 'Özet'];

  // Taksit tarihlerini hesapla
  void _calculateInstallmentDates() {
  if (_firstInstallmentDate == null) return;

  final count = int.tryParse(_installmentCountController.text) ?? 1;
  _installmentDates.clear();

  for (int i = 0; i < count; i++) {
  final date = DateTime(
  _firstInstallmentDate!.year,
  _firstInstallmentDate!.month + i,
  _firstInstallmentDate!.day,
  );
  _installmentDates.add(DateFormat('dd/MM/yyyy').format(date));
  }
  setState(() {});
  }

  // İlk adım: İşlem tipi seçimi
  Widget _buildTypeSelectionStep() {
  return SingleChildScrollView(
  padding: EdgeInsets.all(16.h),
  child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
  Text(
  'İşlem Tipi Seçin',
  style: GoogleFonts.montserrat(
  fontSize: 18.sp,
  fontWeight: FontWeight.w700,
  ),
  ),
  SizedBox(height: 16.h),

  // Normal İşlem
  _buildTypeCard(
  title: 'Normal İşlem',
  subtitle: 'Tek seferlik ödeme',
  icon: Icons.payment,
  type: TransactionType.normal,
  color: Colors.blue,
  ),

  SizedBox(height: 12.h),

  // Taksitli İşlem
  _buildTypeCard(
  title: 'Taksitli İşlem',
  subtitle: 'Birden fazla ödeme planı',
  icon: Icons.receipt_long,
  type: TransactionType.installment,
  color: Colors.purple,
  ),

  SizedBox(height: 12.h),

  // Provizyonlu İşlem
  _buildTypeCard(
  title: 'Provizyonlu İşlem',
  subtitle: 'Otomatik normal işleme dönüşür',
  icon: Icons.pending_actions,
  type: TransactionType.provisioned,
  color: Colors.orange,
  ),

  SizedBox(height: 24.h),

  // Seçilen tip açıklaması
  _buildTypeDescription(),
  ],
  ),
  );
  }

  Widget _buildTypeCard({
  required String title,
  required String subtitle,
  required IconData icon,
  required TransactionType type,
  required Color color,
  }) {
  final isSelected = _selectedType == type;

  return Card(
  shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(12.r),
  side: BorderSide(
  color: isSelected ? color : Colors.transparent,
  width: isSelected ? 2 : 1,
  ),
  ),
  color: isSelected ? color.withOpacity(0.1) : Theme.of(context).cardColor,
  child: InkWell(
  borderRadius: BorderRadius.circular(12.r),
  onTap: () {
  setState(() {
  _selectedType = type;
  if (type == TransactionType.installment) {
  _calculateInstallmentDates();
  }
  });
  },
  child: Padding(
  padding: EdgeInsets.all(16.h),
  child: Row(
  children: [
  Container(
  width: 48.r,
  height: 48.r,
  decoration: BoxDecoration(
  color: color.withOpacity(0.2),
  shape: BoxShape.circle,
  ),
  child: Icon(icon, color: color),
  ),
  SizedBox(width: 16.w),
  Expanded(
  child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
  Text(
  title,
  style: GoogleFonts.montserrat(
  fontSize: 16.sp,
  fontWeight: FontWeight.w600,
  ),
  ),
  SizedBox(height: 4.h),
  Text(
  subtitle,
  style: GoogleFonts.montserrat(
  fontSize: 12.sp,
  color: Theme.of(context).hintColor,
  ),
  ),
  ],
  ),
  ),
  if (isSelected)
  Icon(Icons.check_circle, color: color),
  ],
  ),
  ),
  ),
  );
  }

  Widget _buildTypeDescription() {
  String description = '';
  IconData icon = Icons.info;
  Color color = Colors.blue;

  switch (_selectedType) {
  case TransactionType.normal:
  description = '• Tek seferde ödenen işlem\n• Hemen hesaba yansır\n• Tarih seçimi zorunlu';
  icon = Icons.payment;
  color = Colors.blue;
  break;
  case TransactionType.installment:
  description = '• Birden fazla taksit\n• İlk taksit tarihi zorunlu\n• Taksit sayısı zorunlu\n• Her ay otomatik eklenir';
  icon = Icons.receipt_long;
  color = Colors.purple;
  break;
  case TransactionType.provisioned:
  description = '• Henüz ödenmemiş işlem\n• Otomatik normal işleme dönüşür\n• Borç limitini etkiler ama kullanılabilir limiti etkilemez';
  icon = Icons.pending_actions;
  color = Colors.orange;
  break;
  }

  return Container(
  padding: EdgeInsets.all(16.h),
  decoration: BoxDecoration(
  color: color.withOpacity(0.1),
  borderRadius: BorderRadius.circular(12.r),
  border: Border.all(color: color.withOpacity(0.3)),
  ),
  child: Row(
  children: [
  Icon(icon, color: color, size: 24.r),
  SizedBox(width: 12.w),
  Expanded(
  child: Text(
  description,
  style: GoogleFonts.montserrat(
  fontSize: 13.sp,
  color: Theme.of(context).textTheme.bodyLarge?.color,
  ),
  ),
  ),
  ],
  ),
  );
  }

  // İkinci adım: Detaylar
  Widget _buildDetailsStep() {
  return SingleChildScrollView(
  padding: EdgeInsets.all(16.h),
  child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
  Text(
  'İşlem Detayları',
  style: GoogleFonts.montserrat(
  fontSize: 18.sp,
  fontWeight: FontWeight.w700,
  ),
  ),
  SizedBox(height: 24.h),

  // Hesap seçimi
  _buildAccountSelectionField(),

  SizedBox(height: 16.h),

  // Başlık
  _buildFormField(
  label: 'Başlık',
  icon: Icons.title,
  child: TextField(
  controller: _titleController,
  decoration: InputDecoration(
  hintText: 'İşlem başlığı',
  border: InputBorder.none,
  ),
  ),
  ),

  SizedBox(height: 16.h),

  // Miktar
  _buildFormField(
  label: 'Tutar',
  icon: Icons.attach_money,
  child: TextField(
  controller: _amountController,
  keyboardType: TextInputType.numberWithOptions(decimal: true),
  decoration: InputDecoration(
  hintText: '0.00',
  border: InputBorder.none,
  suffixText: _selectedAccount?['currency'] ?? 'TRY',
  ),
  ),
  ),

  SizedBox(height: 16.h),

  // Kategori ve Alt Kategori
  Row(
  children: [
  Expanded(
  child: _buildFormField(
  label: 'Kategori',
  icon: Icons.category,
  child: DropdownButton<String>(
  value: _selectedCategory,
  isExpanded: true,
  hint: Text('Kategori seçin'),
  items: widget.userCategories
      .map((c) => c.category)
      .toSet()
      .map((category) {
  return DropdownMenuItem<String>(
  value: category,
  child: Text(category),
  );
  }).toList(),
  onChanged: (value) {
  setState(() {
  _selectedCategory = value;
  _selectedSubcategory = null;
  });
  },
  underline: SizedBox(),
  ),
  ),
  ),
  SizedBox(width: 8.w),
  Expanded(
  child: _buildFormField(
  label: 'Alt Kategori',
  icon: Icons.subdirectory_arrow_right,
  child: DropdownButton<String>(
  value: _selectedSubcategory,
  isExpanded: true,
  hint: Text('Alt kategori'),
  items: _selectedCategory != null
  ? widget.userCategories
      .where((c) => c.category == _selectedCategory)
      .map((c) => c.subcategory)
      .toSet()
      .map((subcategory) {
  return DropdownMenuItem<String>(
  value: subcategory,
  child: Text(subcategory),
  );
  }).toList()
      : [],
  onChanged: (value) {
  setState(() {
  _selectedSubcategory = value;
  });
  },
  underline: SizedBox(),
  ),
  ),
  ),
  ],
  ),

  SizedBox(height: 16.h),

  // Tarih seçimi (türüne göre)
  if (_selectedType == TransactionType.normal)
  _buildDateField(
  label: 'İşlem Tarihi',
  date: _transactionDate,
  onDateSelected: (date) {
  setState(() {
  _transactionDate = date;
  });
  },
  ),

  if (_selectedType == TransactionType.installment)
  Column(
  children: [
  _buildDateField(
  label: 'İlk Taksit Tarihi',
  date: _firstInstallmentDate,
  onDateSelected: (date) {
  setState(() {
  _firstInstallmentDate = date;
  _calculateInstallmentDates();
  });
  },
  ),
  SizedBox(height: 16.h),
  _buildInstallmentCountField(),
  SizedBox(height: 16.h),
  if (_installmentDates.isNotEmpty)
  _buildInstallmentDatesPreview(),
  ],
  ),

  if (_selectedType == TransactionType.provisioned)
  _buildDateField(
  label: 'Provizyon Tarihi',
  date: _transactionDate,
  onDateSelected: (date) {
  setState(() {
  _transactionDate = date;
  });
  },
  ),

  SizedBox(height: 16.h),

  // Açıklama
  _buildFormField(
  label: 'Açıklama (opsiyonel)',
  icon: Icons.description,
  child: TextField(
  controller: _descriptionController,
  decoration: InputDecoration(
  hintText: 'Açıklama',
  border: InputBorder.none,
  ),
  maxLines: 3,
  ),
  ),

  SizedBox(height: 16.h),

  // Provizyon switch (sadece normal işlemde)
  if (_selectedType == TransactionType.normal)
  SwitchListTile.adaptive(
  title: Text(
  'Provizyon mu?',
  style: GoogleFonts.montserrat(
  fontSize: 14.sp,
  fontWeight: FontWeight.w600,
  ),
  ),
  subtitle: Text(
  'Henüz ödenmemiş işlem',
  style: GoogleFonts.montserrat(
  fontSize: 12.sp,
  color: Theme.of(context).hintColor,
  ),
  ),
  value: _isProvisioned,
  onChanged: (value) {
  setState(() {
  _isProvisioned = value;
  });
  },
  secondary: Icon(
  Icons.pending_actions,
  color: _isProvisioned ? Colors.orange : null,
  ),
  ),
  ],
  ),
  );
  }

  Widget _buildFormField({
    required String label,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).hintColor,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20.r, color: Theme.of(context).hintColor),
              SizedBox(width: 12.w),
              Expanded(child: child),
            ],
          ),
        ),
      ],
    );
  }

// Hesap seçimi için özel bir widget oluşturun
  Widget _buildAccountSelectionField() {
    // Tüm hesapları birleştir
    final List<Map<String, dynamic>> allAccounts = [];
    final Set<int> usedAccountIds = {};

    for (var bank in widget.accounts) {
      final accounts = (bank['accounts'] as List?) ?? [];
      for (var account in accounts) {
        final accountId = account['accountId'] as int?;

        // Duplicate kontrolü
        if (accountId != null && !usedAccountIds.contains(accountId)) {
          usedAccountIds.add(accountId);

          // Banka bilgisini hesaba ekle
          final accountWithBank = Map<String, dynamic>.from(account);
          accountWithBank['bankId'] = bank['bankId'];
          accountWithBank['bankName'] = bank['bankName'];
          allAccounts.add(accountWithBank);
        }
      }
    }

    // Seçili hesabı bul
    Map<String, dynamic>? selectedAccountValue;
    if (_selectedAccount != null && _selectedAccount!['accountId'] != null) {
      selectedAccountValue = allAccounts.firstWhere(
            (acc) => acc['accountId'] == _selectedAccount!['accountId'],
        orElse: () => allAccounts.isNotEmpty ? allAccounts.first : {},
      );
    }

    return _buildFormField(
      label: 'Hesap',
      icon: Icons.account_balance,
      child: DropdownButton<Map<String, dynamic>>(
        value: selectedAccountValue,
        isExpanded: true,
        hint: Text('Hesap seçin'),
        items: allAccounts.map((account) {
          final accountId = account['accountId'] as int?;
          final bankName = account['bankName'] as String? ?? 'Bilinmeyen Banka';
          final accountName = account['name'] as String? ?? 'İsimsiz Hesap';
          final isDebit = account['isDebit'] == true;

          return DropdownMenuItem<Map<String, dynamic>>(
            value: account,
            // Her hesap için benzersiz bir key oluştur
            key: ValueKey('account_${accountId}_${bankName}_$accountName'),
            child: Text(
              "$bankName - $accountName${isDebit ? '' : ' 💳'}",
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedAccount = value;
            });
          }
        },
        underline: SizedBox(),
      ),
    );
  }

  Widget _buildDateField({
  required String label,
  required DateTime? date,
  required Function(DateTime) onDateSelected,
  }) {
  return Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
  Text(
  label,
  style: GoogleFonts.montserrat(
  fontSize: 14.sp,
  fontWeight: FontWeight.w600,
  color: Theme.of(context).hintColor,
  ),
  ),
  SizedBox(height: 8.h),
  Container(
  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
  decoration: BoxDecoration(
  color: Theme.of(context).cardColor,
  borderRadius: BorderRadius.circular(8.r),
  border: Border.all(color: Theme.of(context).dividerColor),
  ),
  child: Row(
  children: [
  Icon(Icons.calendar_today, size: 20.r, color: Theme.of(context).hintColor),
  SizedBox(width: 12.w),
  Expanded(
  child: Text(
  date != null
  ? DateFormat('dd/MM/yyyy').format(date)
      : 'Tarih seçin',
  style: GoogleFonts.montserrat(
  fontSize: 14.sp,
  color: date != null
  ? Theme.of(context).textTheme.bodyLarge?.color
      : Theme.of(context).hintColor,
  ),
  ),
  ),
  IconButton(
  icon: Icon(Icons.calendar_month),
  onPressed: () async {
  final selected = await showDatePicker(
  context: context,
  initialDate: date ?? DateTime.now(),
  firstDate: DateTime(2000),
  lastDate: DateTime(2100),
  );
  if (selected != null) {
  onDateSelected(selected);
  }
  },
  ),
  ],
  ),
  ),
  ],
  );
  }

  Widget _buildInstallmentCountField() {
  final count = int.tryParse(_installmentCountController.text) ?? 1;
  final amount = double.tryParse(_amountController.text) ?? 0;
  final installmentAmount = count > 0 ? amount / count : 0;

  return Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
  Text(
  'Taksit Sayısı',
  style: GoogleFonts.montserrat(
  fontSize: 14.sp,
  fontWeight: FontWeight.w600,
  color: Theme.of(context).hintColor,
  ),
  ),
  SizedBox(height: 8.h),
  Container(
  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
  decoration: BoxDecoration(
  color: Theme.of(context).cardColor,
  borderRadius: BorderRadius.circular(8.r),
  border: Border.all(color: Theme.of(context).dividerColor),
  ),
  child: Column(
  children: [
  Row(
  children: [
  Icon(Icons.receipt_long, size: 20.r, color: Theme.of(context).hintColor),
  SizedBox(width: 12.w),
  Expanded(
  child: TextField(
  controller: _installmentCountController,
  keyboardType: TextInputType.number,
  onChanged: (value) {
  _calculateInstallmentDates();
  },
  decoration: InputDecoration(
  hintText: 'Taksit sayısı',
  border: InputBorder.none,
  suffixText: 'ay',
  ),
  ),
  ),
  ],
  ),
  if (count > 1 && amount > 0)
  Padding(
  padding: EdgeInsets.only(top: 12.h),
  child: Container(
  padding: EdgeInsets.all(12.h),
  decoration: BoxDecoration(
  color: Colors.purple.withOpacity(0.1),
  borderRadius: BorderRadius.circular(8.r),
  ),
  child: Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
  Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
  Text(
  'Taksit Başı',
  style: GoogleFonts.montserrat(
  fontSize: 12.sp,
  color: Theme.of(context).hintColor,
  ),
  ),
  Text(
  '${installmentAmount.toStringAsFixed(2)} ${_selectedAccount?['currency'] ?? 'TRY'}',
  style: GoogleFonts.montserrat(
  fontSize: 16.sp,
  fontWeight: FontWeight.w700,
  color: Colors.purple,
  ),
  ),
  ],
  ),
  Column(
  crossAxisAlignment: CrossAxisAlignment.end,
  children: [
  Text(
  'Toplam',
  style: GoogleFonts.montserrat(
  fontSize: 12.sp,
  color: Theme.of(context).hintColor,
  ),
  ),
  Text(
  '${amount.toStringAsFixed(2)} ${_selectedAccount?['currency'] ?? 'TRY'}',
  style: GoogleFonts.montserrat(
  fontSize: 16.sp,
  fontWeight: FontWeight.w700,
  color: Colors.purple,
  ),
  ),
  ],
  ),
  ],
  ),
  ),
  ),
  ],
  ),
  ),
  ],
  );
  }

  Widget _buildInstallmentDatesPreview() {
  return Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
  Text(
  'Taksit Planı',
  style: GoogleFonts.montserrat(
  fontSize: 14.sp,
  fontWeight: FontWeight.w600,
  color: Theme.of(context).hintColor,
  ),
  ),
  SizedBox(height: 8.h),
  Container(
  padding: EdgeInsets.all(12.h),
  decoration: BoxDecoration(
  color: Colors.purple.withOpacity(0.1),
  borderRadius: BorderRadius.circular(8.r),
  border: Border.all(color: Colors.purple.withOpacity(0.3)),
  ),
  child: Column(
  children: _installmentDates.asMap().entries.map((entry) {
  final index = entry.key;
  final date = entry.value;
  final amount = double.tryParse(_amountController.text) ?? 0;
  final count = int.tryParse(_installmentCountController.text) ?? 1;
  final installmentAmount = count > 0 ? amount / count : 0;

  return ListTile(
  leading: Container(
  width: 32.r,
  height: 32.r,
  decoration: BoxDecoration(
  shape: BoxShape.circle,
  color: Colors.purple.withOpacity(0.2),
  ),
  child: Center(
  child: Text(
  '${index + 1}',
  style: GoogleFonts.montserrat(
  fontSize: 12.sp,
  fontWeight: FontWeight.w700,
  color: Colors.purple,
  ),
  ),
  ),
  ),
  title: Text(
  'Taksit ${index + 1}',
  style: GoogleFonts.montserrat(
  fontSize: 14.sp,
  fontWeight: FontWeight.w600,
  ),
  ),
  subtitle: Text(date),
  trailing: Text(
  '${installmentAmount.toStringAsFixed(2)} ${_selectedAccount?['currency'] ?? 'TRY'}',
  style: GoogleFonts.montserrat(
  fontSize: 14.sp,
  fontWeight: FontWeight.w700,
  color: Colors.purple,
  ),
  ),
  contentPadding: EdgeInsets.zero,
  );
  }).toList(),
  ),
  ),
  ],
  );
  }

  // Üçüncü adım: Özet
  Widget _buildSummaryStep() {
  final amount = double.tryParse(_amountController.text) ?? 0;
  final count = _selectedType == TransactionType.installment
  ? int.tryParse(_installmentCountController.text) ?? 1
      : 1;
  final double installmentAmount = (count > 0 && amount > 0)
      ? amount / count
      : 0.0;

  return SingleChildScrollView(
  padding: EdgeInsets.all(16.h),
  child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
  Text(
  'İşlem Özeti',
  style: GoogleFonts.montserrat(
  fontSize: 18.sp,
  fontWeight: FontWeight.w700,
  ),
  ),
  SizedBox(height: 24.h),

  // İşlem tipi kartı
  Card(
  child: Padding(
  padding: EdgeInsets.all(16.h),
  child: Row(
  children: [
  Container(
  width: 48.r,
  height: 48.r,
  decoration: BoxDecoration(
  color: _getTypeColor().withOpacity(0.2),
  shape: BoxShape.circle,
  ),
  child: Icon(_getTypeIcon(), color: _getTypeColor()),
  ),
  SizedBox(width: 16.w),
  Expanded(
  child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
  Text(
  _getTypeTitle(),
  style: GoogleFonts.montserrat(
  fontSize: 16.sp,
  fontWeight: FontWeight.w700,
  ),
  ),
  SizedBox(height: 4.h),
  Text(
  _getTypeSubtitle(),
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
  ),

  SizedBox(height: 16.h),

  // Detaylar listesi
  Card(
  child: Padding(
  padding: EdgeInsets.all(16.h),
  child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
  _buildSummaryItem(
  label: 'Hesap',
  value: _selectedAccount != null
  ? "${_selectedAccount?['name']}"
      : 'Seçilmedi',
  ),
  _buildSummaryItem(
  label: 'Başlık',
  value: _titleController.text.isNotEmpty
  ? _titleController.text
      : 'Belirtilmedi',
  ),
  _buildSummaryItem(
  label: 'Kategori',
  value: _selectedCategory != null
  ? '$_selectedCategory${_selectedSubcategory != null ? ' - $_selectedSubcategory' : ''}'
      : 'Seçilmedi',
  ),
  if (_selectedType == TransactionType.normal)
  _buildSummaryItem(
  label: 'Tarih',
  value: _transactionDate != null
  ? DateFormat('dd/MM/yyyy').format(_transactionDate!)
      : 'Belirtilmedi',
  ),
  if (_selectedType == TransactionType.installment)
  Column(
  children: [
  _buildSummaryItem(
  label: 'İlk Taksit Tarihi',
  value: _firstInstallmentDate != null
  ? DateFormat('dd/MM/yyyy').format(_firstInstallmentDate!)
      : 'Belirtilmedi',
  ),
  _buildSummaryItem(
  label: 'Taksit Sayısı',
  value: '$count ay',
  ),
  ],
  ),
  if (_selectedType == TransactionType.provisioned)
  _buildSummaryItem(
  label: 'Provizyon Tarihi',
  value: _transactionDate != null
  ? DateFormat('dd/MM/yyyy').format(_transactionDate!)
      : 'Belirtilmedi',
  ),
  if (_descriptionController.text.isNotEmpty)
  _buildSummaryItem(
  label: 'Açıklama',
  value: _descriptionController.text,
  ),
  if (_selectedType == TransactionType.normal && _isProvisioned)
  _buildSummaryItem(
  label: 'Durum',
  value: 'Provizyonlu',
  valueColor: Colors.orange,
  ),
  ],
  ),
  ),
  ),

  SizedBox(height: 16.h),

  // Finansal özet
  Card(
  color: Colors.purple.withOpacity(0.05),
  child: Padding(
  padding: EdgeInsets.all(16.h),
  child: Column(
  children: [
  if (_selectedType == TransactionType.installment && count > 1)
  Column(
  children: [
  _buildFinancialItem(
  label: 'Taksit Başı',
  value: installmentAmount,
  isLarge: false,
  ),
  SizedBox(height: 8.h),
  ],
  ),
  _buildFinancialItem(
  label: _selectedType == TransactionType.installment && count > 1
  ? 'Toplam Tutar'
      : 'Tutar',
  value: amount,
  isLarge: true,
  ),
  ],
  ),
  ),
  ),

  SizedBox(height: 16.h),

  // Uyarı mesajları
  if (_selectedAccount?['isDebit'] == false)
  Container(
  padding: EdgeInsets.all(12.h),
  decoration: BoxDecoration(
  color: Colors.blue.withOpacity(0.1),
  borderRadius: BorderRadius.circular(8.r),
  border: Border.all(color: Colors.blue.withOpacity(0.3)),
  ),
  child: Row(
  children: [
  Icon(Icons.credit_card, color: Colors.blue, size: 20.r),
  SizedBox(width: 8.w),
  Expanded(
  child: Text(
  'Bu işlem kredi kartı limitinizi etkileyecektir.',
  style: GoogleFonts.montserrat(
  fontSize: 12.sp,
  color: Colors.blue,
  ),
  ),
  ),
  ],
  ),
  ),

  SizedBox(height: 24.h),
  ],
  ),
  );
  }

  Widget _buildSummaryItem({
  required String label,
  required String value,
  Color? valueColor,
  }) {
  return Padding(
  padding: EdgeInsets.symmetric(vertical: 8.h),
  child: Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
  Expanded(
  child: Text(
  label,
  style: GoogleFonts.montserrat(
  fontSize: 14.sp,
  fontWeight: FontWeight.w600,
  color: Theme.of(context).hintColor,
  ),
  ),
  ),
  Expanded(
  child: Text(
  value,
  style: GoogleFonts.montserrat(
  fontSize: 14.sp,
  color: valueColor ?? Theme.of(context).textTheme.bodyLarge?.color,
  fontWeight: FontWeight.w500,
  ),
  textAlign: TextAlign.right,
  ),
  ),
  ],
  ),
  );
  }

  Widget _buildFinancialItem({
  required String label,
  required double value,
  required bool isLarge,
  }) {
  return Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
  Text(
  label,
  style: GoogleFonts.montserrat(
  fontSize: isLarge ? 16.sp : 14.sp,
  fontWeight: isLarge ? FontWeight.w700 : FontWeight.w600,
  color: Theme.of(context).textTheme.bodyLarge?.color,
  ),
  ),
  Text(
  '${value.toStringAsFixed(2)} ${_selectedAccount?['currency'] ?? 'TRY'}',
  style: GoogleFonts.montserrat(
  fontSize: isLarge ? 18.sp : 16.sp,
  fontWeight: FontWeight.w700,
  color: Colors.purple,
  ),
  ),
  ],
  );
  }

  Color _getTypeColor() {
  switch (_selectedType) {
  case TransactionType.normal:
  return Colors.blue;
  case TransactionType.installment:
  return Colors.purple;
  case TransactionType.provisioned:
  return Colors.orange;
  }
  }

  IconData _getTypeIcon() {
  switch (_selectedType) {
  case TransactionType.normal:
  return Icons.payment;
  case TransactionType.installment:
  return Icons.receipt_long;
  case TransactionType.provisioned:
  return Icons.pending_actions;
  }
  }

  String _getTypeTitle() {
  switch (_selectedType) {
  case TransactionType.normal:
  return 'Normal İşlem';
  case TransactionType.installment:
  return 'Taksitli İşlem';
  case TransactionType.provisioned:
  return 'Provizyonlu İşlem';
  }
  }

  String _getTypeSubtitle() {
  switch (_selectedType) {
  case TransactionType.normal:
  return _isProvisioned ? 'Provizyonlu ödeme' : 'Tek seferlik ödeme';
  case TransactionType.installment:
  return '${_installmentCountController.text} taksit';
  case TransactionType.provisioned:
  return 'Otomatik normal işleme dönüşür';
  }
  }

  // Validasyon
  bool _validateCurrentStep() {
  switch (_currentStep) {
  case 0:
  return true; // Her zaman geçerli
  case 1:
  if (_selectedAccount == null) return false;
  if (_titleController.text.isEmpty) return false;
  if (_amountController.text.isEmpty) return false;
  if (_selectedCategory == null) return false;

  if (_selectedType == TransactionType.normal && _transactionDate == null) return false;
  if (_selectedType == TransactionType.installment && _firstInstallmentDate == null) return false;
  if (_selectedType == TransactionType.installment) {
  final count = int.tryParse(_installmentCountController.text) ?? 0;
  if (count < 1) return false;
  }
  if (_selectedType == TransactionType.provisioned && _transactionDate == null) return false;

  return true;
  case 2:
  return true; // Özet sayfası her zaman geçerli
  default:
  return false;
  }
  }

  // İşlem oluştur
  Transaction _createTransaction() {
    final amount = double.parse(_amountController.text);
    final now = DateTime.now();

    // Taksit sayısı
    final count = _selectedType == TransactionType.installment
        ? int.parse(_installmentCountController.text)
        : 1;

    // Taksit başı tutar
    final double perInstallmentAmount = count > 1 ? amount / count : amount;

    // Toplam tutar (taksitli ise)
    final double? totalAmount = count > 1 ? amount : null;

    // İlk taksit ödendi mi? (genelde ilk taksit ödenmiş sayılır)
    final bool isFirstInstallmentPaid = _selectedType == TransactionType.installment;

    String title = _titleController.text;
    if (_selectedType == TransactionType.installment && count > 1) {
      title = "$title (1/$count)";
    }

    DateTime transactionDate;
    if (_selectedType == TransactionType.installment) {
      transactionDate = _firstInstallmentDate ?? now;
    } else {
      transactionDate = _transactionDate ?? now;
    }

    bool isProvisioned = false;
    if (_selectedType == TransactionType.normal) {
      isProvisioned = _isProvisioned;
    } else if (_selectedType == TransactionType.provisioned) {
      isProvisioned = true;
    }

    return Transaction(
      transactionId: DateTime.now().millisecondsSinceEpoch,
      date: transactionDate,
      amount: perInstallmentAmount, // Taksit başı tutar
      installment: _selectedType == TransactionType.installment ? count : null,
      totalAmount: totalAmount, // Toplam tutar
      isInstallmentPaid: isFirstInstallmentPaid, // İlk taksit ödendi mi?
      paidAmount: isFirstInstallmentPaid ? perInstallmentAmount : 0.0,
      isFromInvoice: false,
      currency: _selectedAccount?['currency'] ?? 'TRY',
      subcategory: _selectedSubcategory ?? 'Genel',
      category: _selectedCategory!,
      description: _descriptionController.text,
      title: title,
      isSurplus: false,
      initialInstallmentDate: _selectedType == TransactionType.installment
          ? _firstInstallmentDate
          : null,
      isProvisioned: isProvisioned,
    );
  }

  @override
  Widget build(BuildContext context) {
  return Container(
  height: MediaQuery.of(context).size.height * 0.85,
  decoration: BoxDecoration(
  color: Theme.of(context).scaffoldBackgroundColor,
  borderRadius: BorderRadius.only(
  topLeft: Radius.circular(24.r),
  topRight: Radius.circular(24.r),
  ),
  ),
  child: Column(
  children: [
  // Başlık ve ilerleme çubuğu
  Container(
  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
  decoration: BoxDecoration(
  color: Theme.of(context).cardColor,
  borderRadius: BorderRadius.only(
  topLeft: Radius.circular(24.r),
  topRight: Radius.circular(24.r),
  ),
  boxShadow: [
  BoxShadow(
  color: Colors.black.withOpacity(0.1),
  blurRadius: 8,
  offset: Offset(0, 2),
  ),
  ],
  ),
  child: Column(
  children: [
  Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
  TextButton(
  onPressed: () => Navigator.pop(context),
  child: Text(
  'İptal',
  style: GoogleFonts.montserrat(
  color: Theme.of(context).colorScheme.error,
  fontWeight: FontWeight.w600,
  ),
  ),
  ),
  Text(
  'Yeni İşlem Ekle',
  style: GoogleFonts.montserrat(
  fontSize: 18.sp,
  fontWeight: FontWeight.w700,
  ),
  ),
  Opacity(
  opacity: _currentStep == 2 ? 1.0 : 0.0,
  child: TextButton(
  onPressed: _currentStep == 2
  ? () {
  final transaction = _createTransaction();
  widget.onTransactionAdded(transaction);
  Navigator.pop(context);
  }
      : null,
  child: Text(
  'Ekle',
  style: GoogleFonts.montserrat(
  color: Theme.of(context).colorScheme.primary,
  fontWeight: FontWeight.w700,
  ),
  ),
  ),
  ),
  ],
  ),
  SizedBox(height: 16.h),

  // İlerleme çubuğu
  Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: List.generate(_stepTitles.length, (index) {
  final isActive = index == _currentStep;
  final isCompleted = index < _currentStep;

  return Expanded(
  child: Column(
  children: [
  Row(
  children: [
  Expanded(
  child: Container(
  height: 4.h,
  decoration: BoxDecoration(
  color: isCompleted || isActive
  ? Theme.of(context).colorScheme.primary
      : Theme.of(context).dividerColor,
  borderRadius: BorderRadius.circular(2.r),
  ),
  ),
  ),
  if (index < _stepTitles.length - 1)
  SizedBox(width: 8.w),
  ],
  ),
  SizedBox(height: 8.h),
  Text(
  _stepTitles[index],
  style: GoogleFonts.montserrat(
  fontSize: 12.sp,
  fontWeight: FontWeight.w600,
  color: isActive || isCompleted
  ? Theme.of(context).colorScheme.primary
      : Theme.of(context).hintColor,
  ),
  ),
  ],
  ),
  );
  }),
  ),
  ],
  ),
  ),

  // İçerik
  Expanded(
  child: _buildStepContent(),
  ),

  // Alt navigasyon
  Container(
  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
  decoration: BoxDecoration(
  color: Theme.of(context).cardColor,
  border: Border(
  top: BorderSide(color: Theme.of(context).dividerColor),
  ),
  ),
  child: Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
  if (_currentStep > 0)
  ElevatedButton.icon(
  onPressed: () {
  setState(() {
  _currentStep--;
  });
  },
  icon: Icon(Icons.arrow_back),
  label: Text('Geri'),
  style: ElevatedButton.styleFrom(
  backgroundColor: Theme.of(context).dividerColor,
  foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
  ),
  )
  else
  SizedBox(width: 0),

  if (_currentStep < 2)
  ElevatedButton.icon(
  onPressed: _validateCurrentStep()
  ? () {
  setState(() {
  _currentStep++;
  });
  }
      : null,
  icon: Text('İleri'),
  label: Icon(Icons.arrow_forward),
  style: ElevatedButton.styleFrom(
  backgroundColor: Theme.of(context).colorScheme.primary,
  foregroundColor: Colors.white,
  ),
  ),
  ],
  ),
  ),
  ],
  ),
  );
  }

  Widget _buildStepContent() {
  switch (_currentStep) {
  case 0:
  return _buildTypeSelectionStep();
  case 1:
  return _buildDetailsStep();
  case 2:
  return _buildSummaryStep();
  default:
  return Container();
  }
  }
}