import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../blocs/income-selections.dart';
import '../../../models/account.dart';
import '../../../models/transaction-widget.dart';
import '../../../models/transaction.dart';
import '../../../models/upcoming-payments-section.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../components/previous_period_dialog.dart';
import '../../services/account_service.dart';
import '../../services/invoice_service.dart';
import '../../storage/income_storage_service.dart';
import '../../widgets/account_details_card.dart';
import '../../widgets/date_range_picker_button.dart';
import '../../widgets/debt_overview_section.dart';
import '../../widgets/financial_metric_cards.dart';
import '../../widgets/loading_states.dart';
import '../../widgets/quick_actions_row.dart';
import '../add-expense/faturalar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Services
  final _invoiceService = InvoiceService();
  // AccountService is used via static methods

  // Data
  List<Invoice> invoices = [];
  List<Transaction> transactions = [];
  List<Account> accounts = [];  // Changed from bankAccounts to List<Account>
  Account? selectedAccount;     // Using Account model

  // UI State
  bool isLoading = true;
  bool isDebtVisible = false;

  // Date Range
  DateTime? startDate;
  DateTime? endDate;

  // Income data (legacy - to be migrated)
  Map<String, List<Map<String, dynamic>>> incomeMap = {};
  String selectedKey = "";
  double incomeValue = 0.0;
  String selectedTitle = '';

  // Period warning tracking
  final Set<String> _warnedPeriods = {};

  late final TransactionBloc _transactionBloc;

  @override
  void initState() {
    super.initState();
    _updateLastOpenDate();
    _loadData();

    _transactionBloc = TransactionBloc();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _transactionBloc.add(LoadTransactions(
        startDate: startDate,
        endDate: endDate,
      ));
    });
  }

  @override
  void dispose() {
    _transactionBloc.close();
    super.dispose();
  }

  // MARK: - Data Loading
  Future<void> _updateLastOpenDate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastAppOpenDate', DateTime.now().toIso8601String());
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load date range
    final startDateStr = prefs.getString('startDate');
    final endDateStr = prefs.getString('endDate');
    if (startDateStr != null && endDateStr != null) {
      startDate = DateTime.parse(startDateStr);
      endDate = DateTime.parse(endDateStr);
    }

    // Load invoices
    invoices = await _invoiceService.loadInvoices();

    // Load all accounts using your existing AccountService
    accounts = await AccountService.loadAllAccounts();

    // Load selected account
    // Load selected account
    final selectedAccountJson = prefs.getString('selectedAccount');
    if (selectedAccountJson != null) {
      try {
        final selectedAccountData = jsonDecode(selectedAccountJson);
        // Find the full account object from accounts list
        selectedAccount = accounts.firstWhere(
              (a) => a.accountId == selectedAccountData['accountId'],
          orElse: () => Account(
            accountId: 0,
            name: 'Seçili Hesap',
            type: 'checking',
            balance: 0.0,
            currency: 'TRY',
            isDebit: true,
            cutoffDate: 1,
            transactions: [],
            debts: [],
          ),
        );
      } catch (e) {
        print('Error parsing selected account: $e');
        selectedAccount = accounts.isNotEmpty ? accounts.first : null;
      }
    } else {
      selectedAccount = accounts.isNotEmpty ? accounts.first : null;
    }

    // Load transactions from selected account
    if (selectedAccount != null) {
      transactions = List.from(selectedAccount!.transactions);

      if (startDate != null && endDate != null) {
        transactions = transactions.where((t) {
          final date = DateTime(t.date.year, t.date.month, t.date.day);
          return (date.isAfter(startDate!) || date.isAtSameMomentAs(startDate!)) &&
              (date.isBefore(endDate!) || date.isAtSameMomentAs(endDate!));
        }).toList();
      }
      transactions.sort((a, b) => a.date.compareTo(b.date));
    }

    // Load legacy income data (to be migrated)
    _loadLegacyIncomeData(prefs);

    setState(() => isLoading = false);

    // Check for period warnings after data is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForPreviousPeriodWarnings();
    });
  }

  void _loadLegacyIncomeData(SharedPreferences prefs) {
    final selectedOption = prefs.getInt('selected_option') ?? SelectedOption.None.index;
    selectedTitle = _labelForOption(SelectedOption.values[selectedOption]);

    final incomeMapStr = prefs.getString('incomeMap');
    if (incomeMapStr != null && incomeMapStr.isNotEmpty) {
      final decoded = json.decode(incomeMapStr);
      if (decoded is Map<String, dynamic>) {
        incomeMap = {};
        decoded.forEach((key, value) {
          if (value is List<dynamic>) {
            incomeMap[key] = List<Map<String, dynamic>>.from(
                value.map((e) => Map<String, dynamic>.from(e)));
          }
        });

        double sum = 0.0;
        for (var values in incomeMap.values) {
          for (var value in values) {
            String amount = value["amount"];
            if (amount.isNotEmpty) {
              double parsed = NumberFormat.decimalPattern('tr_TR').parse(amount).toDouble();
              sum += parsed;
            }
          }
        }
        incomeValue = sum;
      }
    }
  }

  String _labelForOption(SelectedOption option) {
    switch (option) {
      case SelectedOption.Is: return 'İş';
      case SelectedOption.Burs: return 'Burs';
      case SelectedOption.Emekli: return 'Emekli';
      default: return '';
    }
  }

  // MARK: - Period Warnings
  Future<void> _checkForPreviousPeriodWarnings() async {
    final prefs = await SharedPreferences.getInstance();
    final lastOpenStr = prefs.getString('lastAppOpenDate');
    if (lastOpenStr == null) return;

    final lastOpen = DateTime.parse(lastOpenStr);
    final inputFormat = DateFormat('dd/MM/yyyy');
    final dismissedPeriods = prefs.getStringList('dismissed_periods') ?? [];

    // We need to access the raw bank/account structure for credit card info
    final accountDataListJson = prefs.getString('accountDataList');
    if (accountDataListJson == null) return;

    try {
      final bankAccounts = jsonDecode(accountDataListJson) as List<dynamic>;

      for (final bank in bankAccounts) {
        final bankMap = bank as Map<String, dynamic>;
        final accounts = bankMap['accounts'] as List<dynamic>? ?? [];

        for (final account in accounts) {
          final accountMap = account as Map<String, dynamic>;
          if (accountMap['isDebit'] == false) { // credit card
            final previousCutoffStr = accountMap['previousCutoffDate'];
            if (previousCutoffStr != null) {
              try {
                final cutoffDate = inputFormat.parse(previousCutoffStr);
                if (lastOpen.isBefore(cutoffDate)) {
                  final periodKey = '${bankMap['bankId']}_${accountMap['accountId']}_$previousCutoffStr';
                  if (!dismissedPeriods.contains(periodKey) &&
                      !_warnedPeriods.contains(periodKey)) {
                    _showPreviousPeriodDialog(bankMap, accountMap, periodKey);
                    _warnedPeriods.add(periodKey);
                  }
                }
              } catch (e) {
                print('Error parsing cutoff date: $e');
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error parsing bank accounts for warnings: $e');
    }
  }

  void _showPreviousPeriodDialog(Map<String, dynamic> bank, Map<String, dynamic> account, String periodKey) {
    showDialog(
      context: context,
      builder: (_) => PreviousPeriodDialog(
        bankName: bank['bankName'] ?? 'Banka',
        accountName: account['name'] ?? 'Kredi Kartı',
        cutoffDate: account['previousCutoffDate'] ?? '',
        dueDate: account['previousDueDate'] ?? '',
        debt: (account['previousDebt'] ?? 0.0).toDouble(),
        transactions: account['transactions'],
        periodKey: periodKey,
      ),
    );
  }

  // MARK: - Calculations
  double _getTotalDebt() {
    if (selectedAccount == null) return 0.0;

    // Get debts from selected account
    double accountDebt = selectedAccount!.debts.fold<double>(
      0, (sum, debt) => sum + ((debt['amount'] as num?)?.toDouble() ?? 0),
    );

    // Get total credit debt from all accounts
    double creditDebt = 0.0;
    for (final account in accounts) {
      if (account.type == 'credit') {
        creditDebt += account.balance ?? 0.0;  // Added null check with ??
      }
    }

    return accountDebt + creditDebt;
  }

  double _getTotalOutcome() {
    if (selectedAccount == null) return 0.0;

    // We need to access the raw account data for currency filtering
    // For now, return total from selected account's transactions
    double total = 0.0;
    for (final transaction in transactions) {
      if (!transaction.isSurplus) {
        total += transaction.amount;
      }
    }
    return total;
  }

  // MARK: - UI Callbacks
  void _onDateRangeSelected(DateTime? newStart, DateTime? newEnd) async {
    final prefs = await SharedPreferences.getInstance();

    if (newStart != null) {
      await prefs.setString('startDate', newStart.toIso8601String());
    }
    if (newEnd != null) {
      await prefs.setString('endDate', newEnd.toIso8601String());
    }

    setState(() {
      startDate = newStart;
      endDate = newEnd;
      _reloadTransactions();
    });
  }

  void _resetDateRange() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('startDate');
    await prefs.remove('endDate');

    setState(() {
      startDate = null;
      endDate = null;
      _reloadTransactions();
      _loadData();
    });
  }

  void _reloadTransactions() {
    if (_transactionBloc.state.transactions.isNotEmpty) {
      _transactionBloc.add(LoadTransactions(
        startDate: startDate,
        endDate: endDate,
      ));
    }
  }

  void _showAccountInfo(BuildContext context) {
    if (selectedAccount == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Hesap Bilgileri"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _compactInfo("Hesap Adı", selectedAccount!.name),
                _compactInfo("Para Birimi", selectedAccount!.currency),
                _compactInfo("Hesap Türü",
                    selectedAccount!.isDebit ? 'Banka' : 'Kredi'),
                _compactInfo("Bakiye", "${selectedAccount!.balance} ${selectedAccount!.currency}"),
                const Divider(),
                if (!selectedAccount!.isDebit) ...[
                  _compactInfo("Kredi Limiti", "${selectedAccount!.creditLimit} ${selectedAccount!.currency}"),
                  _compactInfo("Kesim Tarihi", selectedAccount!.cutoffDate.toString()),
                  _compactInfo("Son Ödeme Tarihi",
                      selectedAccount!.nextDueDate != null
                          ? DateFormat('dd/MM/yyyy').format(selectedAccount!.nextDueDate!)
                          : 'Belirtilmemiş'),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Kapat"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  Widget _compactInfo(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 13, color: Colors.grey[800]),
          children: [
            TextSpan(text: "$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
            TextSpan(text: "$value"),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountDetails() {
    if (selectedAccount == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AccountDetailsCard(
            account: selectedAccount!,
            onInfoPressed: () => _showAccountInfo(context),
          ),
          SizedBox(height: 16.h),
          QuickActionsRow(
            onInfoPressed: () => _showAccountInfo(context),
            onSendPressed: () => _showNotImplemented('Para gönderme'),
            onDepositPressed: () => _showNotImplemented('Para yatırma'),
            onReceiptPressed: () => _showNotImplemented('Dekontlar'),
          ),
          SizedBox(height: 24.h),
          BlocProvider.value(
            value: _transactionBloc,
            child: TransactionWidget(
              invoices: invoices,
              startDate: startDate,
              endDate: endDate,
              accounts: accounts,
            ),
          ),
        ],
      ),
    );
  }

  void _showNotImplemented(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature henüz eklenmedi')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalDebt = _getTotalDebt();
    final totalOutcome = _getTotalOutcome();

    // Get debts from selected account
    final debts = selectedAccount?.debts ?? [];
    final remainingDebt = debts.fold<double>(
      0, (sum, debt) => sum + ((debt['amount'] as num?)?.toDouble() ?? 0),
    );

    // Get total credit debt
    final totalCreditDebt = accounts
        .where((a) => a.type == 'credit')
        .fold<double>(0, (sum, a) => sum + (a.balance ?? 0.0));

    // Determine which future to use based on date range availability
    Future<double> incomeFuture;
    if (startDate != null && endDate != null) {
      incomeFuture = IncomeStorageService.getTotalIncomeByDateRange(startDate!, endDate!);
    } else {
      // If no date range selected, get all-time income
      // You might need to add this method to IncomeStorageService
      incomeFuture = IncomeStorageService.getTotalIncome(); // We'll need to add this
    }

    return FutureBuilder<double>(
      future: incomeFuture,
      builder: (context, incomeSnapshot) {
        double totalIncome = incomeSnapshot.data ?? 0.0;
        double netProfit = totalIncome - totalOutcome;

        String formattedIncome = NumberFormat.currency(
            locale: 'tr_TR', symbol: '', decimalDigits: 2
        ).format(totalIncome);
        String formattedOutcome = NumberFormat.currency(
            locale: 'tr_TR', symbol: '', decimalDigits: 2
        ).format(totalOutcome);
        String formattedProfit = NumberFormat.currency(
            locale: 'tr_TR', symbol: '', decimalDigits: 2
        ).format(netProfit);

        if (incomeSnapshot.connectionState == ConnectionState.waiting) {
          return const LoadingState();
        }

        return Scaffold(
          body: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selectedAccount == null || selectedAccount!.isDebit)
                    DateRangePickerButton(
                      startDate: startDate,
                      endDate: endDate,
                      onDateRangeSelected: _onDateRangeSelected,
                      onReset: _resetDateRange,
                    ),
                  SizedBox(height: 20.h),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.r),
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[900]!
                          : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20.r,
                          offset: Offset(0, 4.h),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        FinancialMetricCards(
                          totalIncome: totalIncome,
                          totalExpense: totalOutcome,
                          netProfit: netProfit,
                          formattedIncome: formattedIncome,
                          formattedExpense: formattedOutcome,
                          formattedProfit: formattedProfit,
                          isDebtVisible: isDebtVisible,
                          onToggleVisibility: () => setState(() => isDebtVisible = !isDebtVisible),
                        ),
                        if (isDebtVisible && totalDebt > 0) ...[
                          SizedBox(height: 20.h),
                          DebtOverviewSection(
                            totalDebt: totalDebt,
                            remainingDebt: remainingDebt,
                            newDebt: totalCreditDebt,
                            debts: debts,
                            isDebtVisible: isDebtVisible,
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  if (isLoading)
                    const LoadingState()
                  else if (accounts.isEmpty)
                    const NoAccountsState()
                  else if (selectedAccount == null)
                      SelectAccountPrompt(accountCount: accounts.length)
                    else
                      _buildAccountDetails(),
                  SizedBox(height: 20.h),
                  selectedAccount != null
                      ? UpcomingPaymentsSection(
                    account: selectedAccount,
                    allAccounts: accounts, // Optional: for multi-account view
                    showAnalytics: true,
                    onTransactionUpdated: (updatedTransaction) async {
                      // Save the updated transaction
                      await TransactionService.updateTransaction(updatedTransaction);
                      setState(() {});
                    },
                  )
                      : const SizedBox.shrink(),
                  const SizedBox(height: 20)
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}