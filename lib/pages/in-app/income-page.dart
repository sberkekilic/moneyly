import 'dart:convert';
import 'dart:ui';

import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../blocs/income-selections.dart';
import '../../blocs/settings/selected-index-cubit.dart';
import '../../models/income-group-widget.dart';
import '../../models/income_model.dart';
import '../../models/transaction.dart';
import '../../storage/income_storage_service.dart';

class IncomePage extends StatefulWidget {
  @override
  State<IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  List<Income> incomes = [];
  List<Map<String, dynamic>> bankAccounts = [];
  Map<String, dynamic>? selectedAccount;
  bool isLoading = true;

  String selectedTitle = 'Toplam';
  String selectedKey = "";
  int? selectedDay;
  String newSelectedOption = "İş";
  double incomeValue = 0.0;
  String formattedIncomeValue = "";
  String formattedWorkValue = "";
  String formattedScholarshipValue = "";
  String formattedPensionValue = "";
  String formattedSavingsValue = "";
  String formattedWishesValue = "";
  String formattedNeedsValue = "";
  int? segmentControlGroupValue = 0;
  int totalValues = 0;

  bool isEditing = false;
  bool isIncomeAdding = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dayController = TextEditingController();
  final TextEditingController incomeController = TextEditingController();
  FocusNode focusNode = FocusNode();

  double sumOfSavingValue = 0.0;
  double savingsValue = 0.0;
  double totalInvestValue = 0.0;
  double sumInvestValue = 0.0;
  double result = 0.0;
  String formattedsavingsValue = "";
  String formattedSumOfSavingValue = "";
  String formattedSumOfIncomeValue = "";

  @override
  void initState() {
    super.initState();
    _load();
    _loadIncomes();
  }

  // Load incomes from storage
  Future<void> _loadIncomes() async {
    final loadedIncomes = await IncomeStorageService.loadIncomes();
    setState(() {
      incomes = loadedIncomes;
    });
  }

  // Updated method to add income using the new storage system
  Future<void> _addIncomeToStorage() async {
    final amount = double.tryParse(incomeController.text);

    if (amount != null && amount > 0 && selectedAccount != null) {
      final newIncome = Income(
        incomeId: DateTime.now().millisecondsSinceEpoch,
        accountId: selectedAccount!['accountId'],
        accountName: selectedAccount!['name'] ?? 'Unknown Account',
        source: newSelectedOption,
        amount: amount,
        date: DateTime.now(),
        currency: selectedAccount!['currency'] ?? 'TRY',
        description: 'Income from $newSelectedOption',
      );

      // Save to income storage
      await IncomeStorageService.addIncome(newIncome);

      // Reload incomes to update UI
      await _loadIncomes();

      setState(() {
        isIncomeAdding = false;
        incomeController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gelir başarıyla eklendi'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lütfen geçerli bir miktar girin ve hesap seçin'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String labelForOption(SelectedOption option) {
    switch (option) {
      case SelectedOption.Is:
        return 'İş';
      case SelectedOption.Burs:
        return 'Burs';
      case SelectedOption.Emekli:
        return 'Emekli';
      default:
        return '';
    }
  }

  void _load() async {
    final prefs = await SharedPreferences.getInstance();
    final ab1 = prefs.getInt('selected_option') ?? SelectedOption.None.index;
    final ab3 = prefs.getDouble('sumInvestValue') ?? 0.0;
    String? accountDataListJson = prefs.getString('accountDataList');
    String? accountData = prefs.getString('selectedAccount');

    setState(() {
      sumInvestValue = ab3;

      if (accountDataListJson != null) {
        try {
          List<Map<String, dynamic>> decodedData = List<Map<String, dynamic>>.from(jsonDecode(accountDataListJson));
          print('Tüm Hesaplar: $decodedData');
          bankAccounts = decodedData.toSet().toList();

          if (accountData != null) {
            final Map<String, dynamic> accountFromPrefs = Map<String, dynamic>.from(jsonDecode(accountData));
            print('Saved account data: $accountFromPrefs');

            if (accountFromPrefs['bankId'] != null && accountFromPrefs['accountId'] != null) {
              final bank = bankAccounts.firstWhere(
                    (bank) => bank['bankId'] == accountFromPrefs['bankId'],
                orElse: () => {},
              );

              if (bank.isNotEmpty) {
                final accounts = bank['accounts'] as List?;
                if (accounts != null) {
                  final account = accounts.firstWhere(
                        (acc) => acc['accountId'] == accountFromPrefs['accountId'],
                    orElse: () => {},
                  );

                  if (account.isNotEmpty) {
                    selectedAccount = {
                      ...account,
                      'bankId': bank['bankId'],
                      'bankName': bank['bankName'],
                    };
                  }
                }
              }
            }
          }
        } catch (e) {
          print('Error decoding account data: $e');
        }
      }

      if (accountData != null && selectedAccount == null) {
        final savedData = jsonDecode(accountData);
        if (savedData['accountId'] != null) {
          final account = _findAccountById(savedData['accountId']);
          if (account != null) {
            selectedAccount = account;
          }
        }
      }

      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    sumOfSavingValue = sumInvestValue.isNaN ? 0.0 : sumInvestValue;
    formattedIncomeValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(incomeValue);
    nameController.text = formattedIncomeValue;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? Colors.grey[900]!.withOpacity(0.3) : Colors.white.withOpacity(0.3);
    final borderColor = isDarkMode ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Gelirler Detayı",
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Selection Section - ADD THIS
            if (bankAccounts.isNotEmpty) ...[
              _buildAccountSelector(),
              SizedBox(height: 16.h),
            ],

            // Income Addition Section
            GlassmorphismContainer(
              blur: 10,
              borderRadius: 16,
              borderColor: borderColor,
              color: bgColor,
              padding: EdgeInsets.all(16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isIncomeAdding)
                    GlassmorphismContainer(
                      blur: 5,
                      borderRadius: 12,
                      borderColor: borderColor,
                      color: isDarkMode ? Colors.green[900]!.withOpacity(0.3) : Colors.green[50]!.withOpacity(0.6),
                      padding: EdgeInsets.all(16.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Gelir Ekle",
                            style: GoogleFonts.montserrat(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              if (selectedAccount == null && bankAccounts.isNotEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Lütfen önce bir hesap seçin'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }
                              setState(() {
                                isIncomeAdding = true;
                              });
                            },
                            icon: Icon(
                              Icons.add_circle,
                              color: Color(0xFF2E7D32),
                              size: 28.r,
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (isIncomeAdding)
                    GlassmorphismContainer(
                      blur: 5,
                      borderRadius: 12,
                      borderColor: borderColor,
                      color: isDarkMode ? Colors.green[900]!.withOpacity(0.3) : Colors.green[50]!.withOpacity(0.6),
                      padding: EdgeInsets.all(16.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Gelir Türü",
                                style: GoogleFonts.montserrat(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: Color(0xFF2E7D32),
                                  size: 24.r,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isIncomeAdding = false;
                                    incomeController.clear();
                                  });
                                },
                              ),
                            ],
                          ),

                          SizedBox(height: 16.h),

                          // Selected Account Display
                          if (selectedAccount != null)
                            GlassmorphismContainer(
                              blur: 3,
                              borderRadius: 8,
                              borderColor: borderColor,
                              color: Colors.blue[50]!.withOpacity(0.3),
                              padding: EdgeInsets.all(12.h),
                              child: Row(
                                children: [
                                  Icon(Icons.account_balance, size: 16.r, color: Colors.blue),
                                  SizedBox(width: 8.w),
                                  Text(
                                    "Hesap: ${selectedAccount!['bankName']} - ${selectedAccount!['name']}",
                                    style: GoogleFonts.montserrat(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          SizedBox(height: 16.h),

                          // Income Type Selector
                          GlassmorphismContainer(
                            blur: 5,
                            borderRadius: 12,
                            borderColor: borderColor,
                            color: Colors.white.withOpacity(0.6),
                            padding: EdgeInsets.all(8.h),
                            child: CustomSlidingSegmentedControl<int>(
                              initialValue: segmentControlGroupValue ?? 0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                color: Colors.grey[200],
                              ),
                              thumbDecoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                color: Color(0xFF4CAF50),
                              ),
                              children: {
                                0: buildSegment('İş'),
                                1: buildSegment('Burs'),
                                2: buildSegment('Emekli'),
                              },
                              isStretch: true,
                              onValueChanged: (value) {
                                setState(() {
                                  segmentControlGroupValue = value;
                                  switch (value) {
                                    case 0:
                                      newSelectedOption = "İş";
                                      break;
                                    case 1:
                                      newSelectedOption = "Burs";
                                      break;
                                    case 2:
                                      newSelectedOption = "Emekli";
                                      break;
                                  }
                                });
                              },
                            ),
                          ),

                          SizedBox(height: 16.h),

                          Text(
                            "Gelir Miktarı",
                            style: GoogleFonts.montserrat(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2E7D32),
                            ),
                          ),

                          SizedBox(height: 12.h),

                          Row(
                            children: [
                              Expanded(
                                child: GlassmorphismContainer(
                                  blur: 5,
                                  borderRadius: 12,
                                  borderColor: borderColor,
                                  color: Colors.white.withOpacity(0.6),
                                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                                  child: TextFormField(
                                    controller: incomeController,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.transparent,
                                      border: InputBorder.none,
                                      hintText: 'Miktar giriniz',
                                      hintStyle: TextStyle(color: Colors.grey[600]),
                                      suffixText: '₺',
                                      suffixStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(width: 12.w),

                              GlassmorphismContainer(
                                blur: 5,
                                borderRadius: 28,
                                borderColor: borderColor,
                                color: Color(0xFF4CAF50).withOpacity(0.8),
                                child: IconButton(
                                  onPressed: _addIncomeToStorage,
                                  icon: Icon(Icons.check, color: Colors.white, size: 24.r),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Income Summary
            _buildIncomeSummary(),

            // Recent Incomes List - ADD THIS NEW SECTION
            SizedBox(height: 24.h),
            _buildRecentIncomes(),
          ],
        ),
      ),
    );
  }

  // Add Account Selector Widget
  Widget _buildAccountSelector() {
    // Create a unique list of accounts to avoid duplicates
    final uniqueAccounts = <Map<String, dynamic>>[];
    final seenAccountIds = <int>{};

    for (var bank in bankAccounts) {
      final accounts = (bank['accounts'] as List?) ?? [];
      for (var account in accounts) {
        final accountId = account['accountId'];
        if (!seenAccountIds.contains(accountId)) {
          seenAccountIds.add(accountId);
          uniqueAccounts.add({
            ...account,
            'bankId': bank['bankId'],
            'bankName': bank['bankName'],
          });
        }
      }
    }

    // Find the current selected account in the unique list
    Map<String, dynamic>? currentSelectedAccount;
    if (selectedAccount != null) {
      currentSelectedAccount = uniqueAccounts.firstWhere(
            (account) => account['accountId'] == selectedAccount!['accountId'],
        orElse: () => selectedAccount!,
      );
    }

    return GlassmorphismContainer(
      blur: 10,
      borderRadius: 16,
      borderColor: Colors.grey.withOpacity(0.3),
      color: Colors.white.withOpacity(0.2),
      padding: EdgeInsets.all(16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Gelir Alınacak Hesap",
            style: GoogleFonts.montserrat(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          DropdownButton<Map<String, dynamic>>(
            value: currentSelectedAccount,
            isExpanded: true,
            hint: Text('Hesap seçin'),
            items: uniqueAccounts.map((account) {
              return DropdownMenuItem<Map<String, dynamic>>(
                value: account,
                child: Text('${account['bankName']} - ${account['name']}'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedAccount = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeSummary() {
    return FutureBuilder<Map<String, dynamic>>(
      future: IncomeStorageService.getIncomeSummary(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final summary = snapshot.data ?? {
          'work': 0.0,
          'scholarship': 0.0,
          'pension': 0.0,
          'total': 0.0,
        };

        final format = NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 2);

        return GlassmorphismContainer(
          blur: 10,
          borderRadius: 16,
          borderColor: Colors.grey.withOpacity(0.3),
          color: Colors.white.withOpacity(0.2),
          padding: EdgeInsets.all(16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Gelir Özeti",
                style: GoogleFonts.montserrat(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              SizedBox(height: 16.h),
              _buildIncomeSummaryItem("İş Geliri", summary['work'] ?? 0.0, format),
              _buildIncomeSummaryItem("Burs Geliri", summary['scholarship'] ?? 0.0, format),
              _buildIncomeSummaryItem("Emekli Geliri", summary['pension'] ?? 0.0, format),
              Divider(height: 20.h),
              _buildIncomeSummaryItem("Toplam Gelir", summary['total'] ?? 0.0, format, isTotal: true),
            ],
          ),
        );
      },
    );
  }

  // Add Recent Incomes List
  Widget _buildRecentIncomes() {
    if (incomes.isEmpty) {
      return GlassmorphismContainer(
        blur: 10,
        borderRadius: 16,
        borderColor: Colors.grey.withOpacity(0.3),
        color: Colors.white.withOpacity(0.2),
        padding: EdgeInsets.all(16.h),
        child: Column(
          children: [
            Text(
              "Son Eklenen Gelirler",
              style: GoogleFonts.montserrat(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              "Henüz gelir eklenmemiş",
              style: GoogleFonts.montserrat(
                fontSize: 14.sp,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    final recentIncomes = incomes.take(5).toList(); // Show last 5 incomes

    return GlassmorphismContainer(
      blur: 10,
      borderRadius: 16,
      borderColor: Colors.grey.withOpacity(0.3),
      color: Colors.white.withOpacity(0.2),
      padding: EdgeInsets.all(16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Son Eklenen Gelirler",
            style: GoogleFonts.montserrat(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          ...recentIncomes.map((income) => _buildIncomeItem(income)).toList(),
        ],
      ),
    );
  }

  Widget _buildIncomeItem(Income income) {
    final format = NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 2);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: _getSourceColor(income.source),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  income.source,
                  style: GoogleFonts.montserrat(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  income.accountName,
                  style: GoogleFonts.montserrat(
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  dateFormat.format(income.date),
                  style: GoogleFonts.montserrat(
                    fontSize: 11.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            format.format(income.amount),
            style: GoogleFonts.montserrat(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Color _getSourceColor(String source) {
    switch (source) {
      case 'İş':
        return Colors.blue;
      case 'Burs':
        return Colors.purple;
      case 'Emekli':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildIncomeSummaryItem(String title, double amount, NumberFormat format, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 14.sp,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Color(0xFF2E7D32) : Colors.black87,
            ),
          ),
          Text(
            format.format(amount),
            style: GoogleFonts.montserrat(
              fontSize: 14.sp,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Color(0xFF2E7D32) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSegment(String text) => Padding(
    padding: EdgeInsets.all(8.h),
    child: Text(
      text,
      style: GoogleFonts.montserrat(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
  );

  Map<String, dynamic>? _findAccountById(int? accountId) {
    if (accountId == null) return null;

    for (var bank in bankAccounts) {
      for (var account in bank['accounts'] ?? []) {
        if (account['accountId'] == accountId) {
          return {
            ...account,
            'bankId': bank['bankId'],
            'bankName': bank['bankName'],
          };
        }
      }
    }
    return null;
  }
}

class GlassmorphismContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final Color borderColor;
  final EdgeInsetsGeometry? padding;
  final Color? color; // opsiyonel arkaplan rengi

  const GlassmorphismContainer({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.blur = 10,
    required this.borderColor,
    this.padding,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color ?? Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor),
          ),
          child: child,
        ),
      ),
    );
  }
}

double parseAmount(dynamic amount) {
  try {
    if (amount == null) return 0.0;

    String amountStr = amount.toString();

    // İlk olarak Türkçe formatta parse etmeye çalış
    return NumberFormat.decimalPattern('tr_TR').parse(amountStr).toDouble();
  } catch (e1) {
    try {
      // Olmazsa manuel düzeltme yap ve parse et
      final cleaned = amount.toString().replaceAll('.', '').replaceAll(',', '.');
      return double.parse(cleaned);
    } catch (e2) {
      print("Parse error: $e2 → value: $amount");
      return 0.0;
    }
  }
}

double parseTurkishDouble(String numberString) {
  // Create a NumberFormat instance for the Turkish locale
  final NumberFormat format = NumberFormat.decimalPattern('tr_TR');

  // Replace the comma with a dot for the decimal part
  String normalizedString = numberString.replaceAll('.', '').replaceAll(',', '.');

  // Parse the normalized string to a double
  return format.parse(normalizedString).toDouble();
}