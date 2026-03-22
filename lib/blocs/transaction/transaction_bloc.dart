import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/account.dart';
import '../../models/transaction.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc() : super(TransactionState.initial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransaction>(_onAddTransaction);
    on<UpdateTransaction>(_onUpdateTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
    on<FilterTransactions>(_onFilterTransactions);

    add(LoadTransactions());
  }

  Future<void> _onLoadTransactions(
      LoadTransactions event,
      Emitter<TransactionState> emit,
      ) async {
    print('Loading transactions...');
    emit(state.copyWith(isLoading: true));

    try {
      final transactions = await TransactionService.loadTransactions();
      print('Loaded ${transactions.length} transactions');

      // Apply filtering if dates are provided
      List<Transaction> filteredTransactions = transactions;
      if (event.startDate != null || event.endDate != null) {
        filteredTransactions = _filterTransactionsByDate(
          transactions,
          event.startDate,
          event.endDate,
        );
      }

      emit(state.copyWith(
        transactions: transactions,
        filteredTransactions: filteredTransactions,
        isLoading: false,
        filterStartDate: event.startDate,
        filterEndDate: event.endDate,
      ));
    } catch (e) {
      print('Error loading transactions: $e');
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> _onAddTransaction(
      AddTransaction event,
      Emitter<TransactionState> emit,
      ) async {
    emit(state.copyWith(isLoading: true));

    try {
      // 1. Transaction'ı ekle
      await TransactionService.addTransaction(event.transaction);

      // 2. Hesap borçlarını güncelle
      await _updateAccountDebts(event.transaction, isDeleting: false);

      // 3. Transaction'ları yeniden yükle
      add(LoadTransactions(
        startDate: state.filterStartDate,
        endDate: state.filterEndDate,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> _onUpdateTransaction(
      UpdateTransaction event,
      Emitter<TransactionState> emit,
      ) async {
    print('🔄 BLoC: _onUpdateTransaction started');
    emit(state.copyWith(isLoading: true));

    try {
      // 1. Eski transaction'ı bul (borçları güncellemek için)
      final oldTransaction = state.transactions
          .firstWhere((t) => t.transactionId == event.transaction.transactionId);

      // 2. Önce eski transaction'ın borçlarını geri al (sil gibi)
      await _updateAccountDebts(oldTransaction, isDeleting: true);

      // 3. Yeni transaction'ı kaydet
      print('💾 BLoC: Saving to storage...');
      await TransactionService.updateTransaction(event.transaction);

      // 4. Yeni transaction'ın borçlarını ekle
      await _updateAccountDebts(event.transaction, isDeleting: false);

      // 5. Local state'i güncelle
      final updatedTransactions = List<Transaction>.from(state.transactions);
      final index = updatedTransactions.indexWhere(
              (t) => t.transactionId == event.transaction.transactionId
      );

      if (index != -1) {
        updatedTransactions[index] = event.transaction;

        // Apply filtering
        List<Transaction> filteredTransactions = updatedTransactions;
        if (state.filterStartDate != null || state.filterEndDate != null) {
          filteredTransactions = _filterTransactionsByDate(
            updatedTransactions,
            state.filterStartDate,
            state.filterEndDate,
          );
        }

        // Emit new state
        emit(state.copyWith(
          transactions: updatedTransactions,
          filteredTransactions: filteredTransactions,
          isLoading: false,
        ));
        print('✅ BLoC: Transaction updated with debt adjustments');
      } else {
        // Transaction not found in current state, reload
        add(LoadTransactions(
          startDate: state.filterStartDate,
          endDate: state.filterEndDate,
        ));
      }

    } catch (e) {
      print('❌ BLoC: Error: $e');
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> _onDeleteTransaction(
      DeleteTransaction event,
      Emitter<TransactionState> emit,
      ) async {
    emit(state.copyWith(isLoading: true));

    try {
      // Eğer tüm taksitler silinecekse
      if (event.deleteAllInstallments) {
        // Silinecek transaction'ı bul
        final transaction = state.transactions
            .firstWhere((t) => t.transactionId == event.transactionId);

        // Tüm taksitleri bul
        List<Transaction> relatedInstallments = [];

        // parentTransactionId ile bul
        if (transaction.parentTransactionId != null) {
          relatedInstallments = state.transactions
              .where((t) => t.parentTransactionId == transaction.parentTransactionId)
              .toList();
        }
        // veya initialInstallmentDate ile bul
        else if (transaction.initialInstallmentDate != null) {
          // Başlığın ana kısmını al (taksit numarasını çıkar)
          String baseTitle = transaction.title;
          if (baseTitle.contains(' (')) {
            baseTitle = baseTitle.split(' (')[0];
          }

          relatedInstallments = state.transactions
              .where((t) =>
          t.initialInstallmentDate == transaction.initialInstallmentDate &&
              t.title.contains(baseTitle) &&
              t.category == transaction.category)
              .toList();
        }

        print('🔍 Deleting all ${relatedInstallments.length} installments');

        // Tüm taksitleri sil
        for (var t in relatedInstallments) {
          print('   Deleting installment: ${t.title}');
          await TransactionService.deleteTransaction(t.transactionId);

          // Ayrıca Outcome Page'deki borçları da güncelle
          await _updateAccountDebts(t, isDeleting: true);
        }
      } else {
        // Sadece bir taksiti sil
        final transaction = state.transactions
            .firstWhere((t) => t.transactionId == event.transactionId);

        await TransactionService.deleteTransaction(event.transactionId);

        // Outcome Page'deki borçları güncelle
        await _updateAccountDebts(transaction, isDeleting: true);
      }

      // Transaction'ları yeniden yükle
      add(LoadTransactions(
        startDate: state.filterStartDate,
        endDate: state.filterEndDate,
      ));

    } catch (e) {
      print('❌ Error deleting transaction: $e');
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

// Yardımcı metod: Hesap borçlarını güncelle
  Future<void> _updateAccountDebts(Transaction transaction, {required bool isDeleting}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accountDataListJson = prefs.getString('accountDataList');

      if (accountDataListJson == null) return;

      final accountDataList = List<Map<String, dynamic>>.from(jsonDecode(accountDataListJson));
      bool updated = false;

      for (var bank in accountDataList) {
        final accounts = (bank['accounts'] as List?) ?? [];

        for (int i = 0; i < accounts.length; i++) {
          final account = accounts[i];

          // Transaction'ı bu hesapta bul
          final transactions = (account['transactions'] as List?) ?? [];
          final transactionExists = transactions.any((t) =>
          t is Map && t['transactionId'] == transaction.transactionId);

          if (transactionExists) {
            print('📝 Updating account debts for transaction deletion');

            // Borçları güncelle
            if (account['isDebit'] == false) { // Kredi kartı ise
              final double amount = transaction.amount;

              if (isDeleting) {
                // Siliniyorsa borçları azalt
                account['currentDebt'] = (account['currentDebt'] ?? 0.0) - amount;
                account['totalDebt'] = (account['totalDebt'] ?? 0.0) - amount;
                account['availableCredit'] = (account['availableCredit'] ?? 0.0) + amount;

                // Dönem borçlarını güncelle
                final nextCutoff = _parseDate(account['nextCutoffDate'] ?? '');
                if (transaction.date.isBefore(nextCutoff)) {
                  if (!transaction.isProvisioned) {
                    account['remainingDebt'] = (account['remainingDebt'] ?? 0.0) - amount;
                  }
                } else {
                  account['previousDebt'] = (account['previousDebt'] ?? 0.0) - amount;
                }
              } else {
                // Ekleniyorsa borçları artır
                account['currentDebt'] = (account['currentDebt'] ?? 0.0) + amount;
                account['totalDebt'] = (account['totalDebt'] ?? 0.0) + amount;
                account['availableCredit'] = (account['availableCredit'] ?? 0.0) - amount;

                // Dönem borçlarını güncelle
                final nextCutoff = _parseDate(account['nextCutoffDate'] ?? '');
                if (transaction.date.isBefore(nextCutoff)) {
                  if (!transaction.isProvisioned) {
                    account['remainingDebt'] = (account['remainingDebt'] ?? 0.0) + amount;
                  }
                } else {
                  account['previousDebt'] = (account['previousDebt'] ?? 0.0) + amount;
                }
              }

              // Asgari ödemeyi yeniden hesapla
              final Account accountInstance = Account.fromJson(account);
              account['minPayment'] = accountInstance.calculateMinPayment();
              account['remainingMinPayment'] = account['minPayment'];
            }

            // Transaction'ı listeden kaldır
            if (isDeleting) {
              account['transactions'] = transactions.where((t) =>
              t is Map && t['transactionId'] != transaction.transactionId).toList();
            }

            accounts[i] = account;
            bank['accounts'] = accounts;
            accountDataList[accountDataList.indexOf(bank)] = bank;
            updated = true;

            break;
          }
        }

        if (updated) break;
      }

      if (updated) {
        await prefs.setString('accountDataList', jsonEncode(accountDataList));
        print('✅ Account debts updated successfully');
      }

    } catch (e) {
      print('❌ Error updating account debts: $e');
    }
  }

  DateTime _parseDate(String dateStr) {
    try {
      final dateFormat = DateFormat('dd/MM/yyyy');
      return dateFormat.parse(dateStr);
    } catch (_) {
      return DateTime.now();
    }
  }

  Future<void> _onFilterTransactions(
      FilterTransactions event,
      Emitter<TransactionState> emit,
      ) async {
    final filteredTransactions = _filterTransactionsByDate(
      state.transactions,
      event.startDate,
      event.endDate,
    );

    emit(state.copyWith(
      filteredTransactions: filteredTransactions,
      filterStartDate: event.startDate,
      filterEndDate: event.endDate,
    ));
  }

  List<Transaction> _filterTransactionsByDate(
      List<Transaction> transactions,
      DateTime? startDate,
      DateTime? endDate,
      ) {
    return transactions.where((t) {
      final isAfterStart = startDate == null ||
          !t.date.isBefore(DateTime(startDate.year, startDate.month, startDate.day));
      final isBeforeEnd = endDate == null ||
          !t.date.isAfter(DateTime(endDate.year, endDate.month, endDate.day));
      return isAfterStart && isBeforeEnd;
    }).toList();
  }
}