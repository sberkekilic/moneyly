import 'dart:convert';

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
import '../../models/transaction.dart';

class IncomePage extends StatefulWidget {
  @override
  State<IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  List<Map<String, dynamic>> bankAccounts = [];
  Map<String, dynamic>? selectedAccount;
  bool isLoading = true; // Flag to indicate loading state

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

  @override
  void initState() {
    super.initState();
    _load();
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
      // Handle account data list
      if (accountDataListJson != null) {
        try {
          List<Map<String, dynamic>> decodedData = List<Map<String, dynamic>>.from(jsonDecode(accountDataListJson));
          print('Tüm Hesaplar: $decodedData');
          bankAccounts = decodedData.toSet().toList();

          if (accountData != null) {
            final Map<String, dynamic> accountFromPrefs = Map<String, dynamic>.from(jsonDecode(accountData));
            print('Saved account data: $accountFromPrefs');

            // Only proceed if we have both bankId and accountId
            if (accountFromPrefs['bankId'] != null && accountFromPrefs['accountId'] != null) {
              // Find the bank first
              final bank = bankAccounts.firstWhere(
                    (bank) => bank['bankId'] == accountFromPrefs['bankId'],
                orElse: () => {},
              );

              if (bank.isNotEmpty) {
                // Then find the specific account within that bank
                final accounts = bank['accounts'] as List?;
                if (accounts != null) {
                  final account = accounts.firstWhere(
                        (acc) => acc['accountId'] == accountFromPrefs['accountId'],
                    orElse: () => {},
                  );

                  if (account.isNotEmpty) {
                    // Combine bank info with account info
                    selectedAccount = {
                      ...account,
                      'bankId': bank['bankId'],
                      'bankName': bank['bankName'],
                      // Include any other bank fields you need
                    };
                  }
                }
              }
            }
          }

          setState(() => isLoading = false);
        } catch (e) {
          print('Error decoding account data: $e');
          setState(() => isLoading = false);
        }
      } else {
        setState(() => isLoading = false);
      }

      print('Seçili hesap: $accountData');
      print('Selected account1: $selectedAccount');

      if (accountData != null && selectedAccount == null) {
        final savedData = jsonDecode(accountData);

        // Check if accountId exists and is not null
        if (savedData['accountId'] != null) {
          final account = _findAccountById(savedData['accountId']);
          if (account != null) {
            setState(() {
              selectedAccount = account;
            });
          }
        } else {
          print('Warning: savedData contains null accountId: $savedData');
        }
      }
    });
  }

  // Define TextEditingControllers for the editable fields
  TextEditingController keyController = TextEditingController();
  TextEditingController valueController = TextEditingController();

  Future<void> _saveAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accountDataList', jsonEncode(bankAccounts));
  }

  Future<void> _addTransactionToAccount(String accountId, Transaction transaction) async {
    try {
      setState(() {
        for (var bank in bankAccounts) {
          final account = (bank['accounts'] as List).firstWhere(
                (acc) => acc['accountId'].toString() == accountId,
            orElse: () => null,
          );

          if (account != null) {
            account['transactions'] ??= [];
            (account['transactions'] as List).add(transaction.toJson());

            double currentBalance = (account['balance'] ?? 0.0) as double;
            double amount = transaction.amount;

            if (transaction.isSurplus) {
              // Gelir ise artır
              account['balance'] = currentBalance + amount;
            } else {
              // Gider ise azalt
              account['balance'] = currentBalance - amount;
            }
            break;
          }
        }
      });
      await _saveAccounts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add transaction: $e")),
      );
    }
  }

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
  Widget build(BuildContext context) {

    sumOfSavingValue = sumInvestValue.isNaN ? 0.0 : sumInvestValue;
    formattedIncomeValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(incomeValue);
    nameController.text = formattedIncomeValue;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Gelirler Detayı",
                style: TextStyle(
                  fontFamily: 'Keep Calm',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.h),
              Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[850] // Dark mode color
                        : Colors.white, // Light mode color
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black.withOpacity(0.5) // Dark mode shadow color
                            : Colors.grey.withOpacity(0.5), // Light mode shadow color
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            bankAccounts.isEmpty
                                ? const Text("Banka hesabı bulunamadı.")
                                : Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: DropdownButtonFormField<int>(
                                value: selectedAccount?['accountId'],
                                decoration: InputDecoration(
                                  labelText: "Choose an account",
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                items: bankAccounts.expand<DropdownMenuItem<int>>((bank) {
                                  return (bank['accounts'] as List?)?.map((account) {
                                    return DropdownMenuItem<int>(
                                      value: account['accountId'],
                                      child: Text("${bank['bankName']} - ${account['name']}"),
                                    );
                                  }) ?? [];
                                }).toList(),
                                onChanged: (selectedAccountId) {
                                  if (selectedAccountId != null) {
                                    final account = _findAccountById(selectedAccountId);
                                    if (account != null) {
                                      setState(() {
                                        selectedAccount = account;
                                      });
                                      _saveSelectedAccount(account);
                                    }
                                  }
                                },
                              ),
                            ),
                            SizedBox(height: 10),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                              ),
                              child:  Column(
                                children: [
                                  if (!isIncomeAdding)
                                    Container(
                                      decoration: BoxDecoration(
                                        color:
                                        Color.fromARGB(120, 152, 255, 170),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: EdgeInsets.only(left: 20,right: 20),
                                      child: SizedBox(
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("Gelir Ekle",
                                                style: GoogleFonts.montserrat(
                                                    fontSize: 16,
                                                    fontWeight:
                                                    FontWeight.w600)),
                                            IconButton(
                                                onPressed: () async {
                                                  setState(() {
                                                    isIncomeAdding = true;
                                                  });
                                                },
                                                icon: Icon(Icons.add_circle))
                                          ],
                                        ),
                                      ),
                                    ),
                                  if (isIncomeAdding)
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Color.fromARGB(120, 152, 255, 170),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("Gelir Türü",
                                                  style: GoogleFonts.montserrat(
                                                      fontSize: 18, fontWeight: FontWeight.bold)),
                                              GestureDetector(
                                                child: Icon(Icons.cancel, size: 26),
                                                onTap: () {
                                                  setState(() {
                                                    isIncomeAdding = !isIncomeAdding;
                                                  });
                                                },
                                              )
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: CustomSlidingSegmentedControl<int>(
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(20), color: Colors.red),
                                                  thumbDecoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(20),
                                                      color: Colors.amber),
                                                  children: {
                                                    0: buildSegment('İş'),
                                                    1: buildSegment('Burs'),
                                                    2: buildSegment('Emekli'),
                                                  },
                                                  isStretch: true,
                                                  onValueChanged: (segmentControlGroupValue) {
                                                    setState(() {
                                                      this.segmentControlGroupValue = segmentControlGroupValue;
                                                      switch (segmentControlGroupValue) {
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
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                          Text("Gelir Miktarı",
                                              style: GoogleFonts.montserrat(
                                                  fontSize: 18, fontWeight: FontWeight.bold)),
                                          SizedBox(height: 10),
                                          GestureDetector(
                                            onTap: () {
                                              incomeController.selection = TextSelection.fromPosition(
                                                TextPosition(offset: incomeController.text.length),
                                              );
                                              focusNode.requestFocus();
                                              SystemChannels.textInput.invokeMethod('TextInput.show');
                                            },
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: TextFormField(
                                                    maxLines: 1,
                                                    controller: incomeController,
                                                    decoration: InputDecoration(
                                                      filled: true,
                                                      isDense: true,
                                                      fillColor: Colors.white,
                                                      contentPadding: EdgeInsets.fromLTRB(10, 20, 20, 0),
                                                      enabledBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(20),
                                                        borderSide: BorderSide(color: Colors.amber, width: 3),
                                                      ),
                                                      focusedBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(20),
                                                        borderSide: BorderSide(color: Colors.black, width: 3),
                                                      ),
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(20),
                                                      ),
                                                      hintText: 'GAG',
                                                      hintStyle: TextStyle(color: Colors.black),
                                                    ),
                                                    keyboardType: TextInputType.number,
                                                  ),
                                                ),
                                                SizedBox(width: 20),
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    final amount = double.tryParse(incomeController.text);

                                                    if (amount != null && amount > 0 && selectedAccount != null && selectedAccount!['accountId'] != null) {
                                                      // 1. Create a transaction record (income with isSurplus true)
                                                      final transaction = Transaction(
                                                        transactionId: DateTime.now().millisecondsSinceEpoch,
                                                        date: DateTime.now(), // or use a selected date if available
                                                        amount: amount,
                                                        installment: null,
                                                        currency: selectedAccount!['currency'] ?? 'USD', // or get from account
                                                        subcategory: newSelectedOption,
                                                        category: 'Income', // Explicitly set as income
                                                        title: 'Income', // or get from a title field if available
                                                        description: '',
                                                        isSurplus: true, // Denote this is an income
                                                        isFromInvoice: false,
                                                        initialInstallmentDate: null,
                                                        isProvisioned: false
                                                      );

                                                      // 2. Add transaction to the account (this will handle balance update)
                                                      await _addTransactionToAccount(selectedAccount!['accountId'].toString(), transaction);
                                                      // 3. Save to SharedPreferences
                                                      await _saveToPrefs();
                                                      await _saveSelectedAccount(selectedAccount!);

                                                    } else {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(content: Text('Please enter a valid positive amount and ensure the account is selected')),
                                                      );
                                                    }
                                                  },
                                                  child: Icon(Icons.check_circle, size: 26, color: Colors.black),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              )
                            ),
                            IncomeByAccountWidget(bankAccounts: bankAccounts)
                          ],
                        )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveSelectedAccount(Map<String, dynamic> account) async {
    // First get the actual account ID - might be nested in an 'accounts' array
    final dynamic accountId = account['accountId'] ??
        (account['accounts'] as List?)?.firstOrNull?['accountId'];

    // Get bank ID - might be at top level
    final dynamic bankId = account['bankId'];

    if (accountId == null || bankId == null) {
      print('Cannot save account - missing IDs. Full account data: $account');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedAccount', jsonEncode({
      'accountId': accountId,
      'bankId': bankId,
    }));
    print('Successfully saved account: $accountId from bank: $bankId');
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final jsonString = jsonEncode(bankAccounts);
      await prefs.setString('accountDataList', jsonString);
      print('[DEBUG] Saved accountDataList: $jsonString');
    } catch (e) {
      print('[ERROR] Failed to save accountDataList: $e');
    }
  }

  Map<String, dynamic>? _findAccountById(int? accountId) {
    if (accountId == null) {
      print('Warning: _findAccountById called with null accountId');
      return null;
    }

    for (var bank in bankAccounts) {
      for (var account in bank['accounts'] ?? []) {
        if (account['accountId'] == accountId) {
          // Return a flattened structure with account + bank info
          return {
            ...account, // Spread all account fields
            'bankId': bank['bankId'],
            'bankName': bank['bankName'],
          };
        }
      }
    }
    return null;
  }

  Widget buildSegment(String text) => Padding(
        padding: EdgeInsets.all(5),
        child: Text(text,
            style: GoogleFonts.montserrat(
                fontSize: 14, fontWeight: FontWeight.bold)),
      );
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