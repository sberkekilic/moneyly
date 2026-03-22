part of 'transaction_bloc.dart';

@immutable
class TransactionState {
  final List<Transaction> transactions;
  final List<Transaction> filteredTransactions;
  final bool isLoading;
  final String? error;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;

  const TransactionState({
    required this.transactions,
    required this.filteredTransactions,
    this.isLoading = false,
    this.error,
    this.filterStartDate,
    this.filterEndDate,
  });

  TransactionState copyWith({
    List<Transaction>? transactions,
    List<Transaction>? filteredTransactions,
    bool? isLoading,
    String? error,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
  }) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      filterStartDate: filterStartDate ?? this.filterStartDate,
      filterEndDate: filterEndDate ?? this.filterEndDate,
    );
  }

  factory TransactionState.initial() {
    return TransactionState(
      transactions: [],
      filteredTransactions: [],
    );
  }
}