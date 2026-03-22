part of 'transaction_bloc.dart';

@immutable
abstract class TransactionEvent {}

class LoadTransactions extends TransactionEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  LoadTransactions({this.startDate, this.endDate});
}

class AddTransaction extends TransactionEvent {
  final Transaction transaction;

  AddTransaction(this.transaction);
}

class UpdateTransaction extends TransactionEvent {
  final Transaction transaction;

  UpdateTransaction(this.transaction);
}

class DeleteTransaction extends TransactionEvent {
  final int transactionId;
  final bool deleteAllInstallments;

  DeleteTransaction(this.transactionId, {this.deleteAllInstallments = false});
}

class FilterTransactions extends TransactionEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  FilterTransactions({this.startDate, this.endDate});
}