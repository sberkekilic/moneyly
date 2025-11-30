import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'account.dart';
import 'transaction.dart';

class UpcomingPaymentModel {
  final String title;             // Gösterilecek başlık
  final String category;          // Kategori bilgisi
  final DateTime dueDate;         // Ödeme tarihi
  final double amount;            // Ödenecek tutar
  final String currency;          // Para birimi
  final PaymentType type;         // Taksit / Normal / Kredi Kartı
  final Transaction? transaction; // Kaynak işlem varsa
  final int? installmentNumber;   // Taksitse kaçıncı taksit

  UpcomingPaymentModel({
    required this.title,
    required this.category,
    required this.dueDate,
    required this.amount,
    required this.currency,
    required this.type,
    this.transaction,
    this.installmentNumber,
  });
}

enum PaymentType {
  installment,
  normal,
  creditCard,
}


class UpcomingPaymentsSection extends StatelessWidget {
  final Account account;

  const UpcomingPaymentsSection({super.key, required this.account});

  List<UpcomingPaymentModel> getUpcomingPaymentsCombined(Account account, {int withinDays = 7}) {
    print("getUpcomingPaymentsCombined çağrıldı");
    print("Account transactions sayısı: ${account.transactions.length}");
    for (var t in account.transactions) {
      print("Transaction: ${t.title}, Tarih: ${t.date}");
    }
    DateTime onlyDate(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
    final now = onlyDate(DateTime.now());
    final limit = now.add(Duration(days: withinDays));

    print("Now: $now, Limit: $limit");

    final List<UpcomingPaymentModel> upcoming = [];

    // Taksitli işlemler
    for (final txn in account.transactions.whereType<Transaction>()) {
      print("Transaction: ${txn.title}, Date: ${txn.date}, Installment: ${txn.installment}, InitialDate: ${txn.initialInstallmentDate}");
      if (txn.installment != null && txn.initialInstallmentDate != null) {
        for (int i = 0; i < txn.installment!; i++) {
          final dueDate = onlyDate(DateTime(
            txn.initialInstallmentDate!.year,
            txn.initialInstallmentDate!.month + i,
            txn.initialInstallmentDate!.day,
          ));
          print("  Installment $i dueDate: $dueDate");
          if (dueDate.isAfter(now) && dueDate.isBefore(limit)) {
            print("    Adding installment payment");
            upcoming.add(UpcomingPaymentModel(
              title: txn.title,
              category: txn.category,
              dueDate: dueDate,
              amount: txn.amount / txn.installment!,
              currency: txn.currency,
              type: PaymentType.installment,
              transaction: txn,
              installmentNumber: i + 1,
            ));
          }
        }
      } else if (!txn.isSurplus && txn.date.isAfter(now) && txn.date.isBefore(limit)) {
        print("  Adding normal payment");
        // Normal ödeme
        upcoming.add(UpcomingPaymentModel(
          title: txn.title,
          category: txn.category,
          dueDate: txn.date,
          amount: txn.amount,
          currency: txn.currency,
          type: PaymentType.normal,
          transaction: txn,
        ));
      }
    }

    // Kredi kartı ödemesi
    if (!account.isDebit &&
        account.nextDueDate != null &&
        account.nextDueDate!.isAfter(now) &&
        account.nextDueDate!.isBefore(limit)) {
      print("Adding credit card payment");
      upcoming.add(UpcomingPaymentModel(
        title: "Kredi Kartı Asgari Ödeme",
        category: "Kredi Kartı",
        dueDate: account.nextDueDate!,
        amount: account.remainingMinPayment ?? account.minPayment ?? 0,
        currency: account.currency,
        type: PaymentType.creditCard,
        transaction: null,
      ));
    }
    print("Upcoming list length: ${upcoming.length}");

    // Tarihe göre sırala
    upcoming.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return upcoming;
  }


  @override
  Widget build(BuildContext context) {
    print("UpcomingPaymentsSection build edildi");
    print("Account transactions sayısı: ${account.transactions.length}");
    for (var t in account.transactions) {
      print("Transaction: ${t.title}, Tarih: ${t.date}");
    }

    final List<UpcomingPaymentModel> upcomingList = getUpcomingPaymentsCombined(account);

    if (upcomingList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Text(
            "Yaklaşan Ödemeler",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: upcomingList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = upcomingList[index];
            return PaymentCard(item: item);
          },
        ),
      ],
    );
  }
}

class PaymentCard extends StatelessWidget {
  final UpcomingPaymentModel item;

  const PaymentCard({super.key, required this.item});

  IconData getIcon() {
    switch (item.type) {
      case PaymentType.installment:
        return Icons.payments_outlined;
      case PaymentType.normal:
        return Icons.event_note_outlined;
      case PaymentType.creditCard:
        return Icons.credit_card;
    }
  }

  Color getColor(BuildContext context) {
    switch (item.type) {
      case PaymentType.installment:
        return Colors.teal.shade100;
      case PaymentType.normal:
        return Colors.orange.shade100;
      case PaymentType.creditCard:
        return Colors.purple.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd MMM yyyy', 'tr_TR');

    return Container(
      decoration: BoxDecoration(
        color: getColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(getIcon(), size: 32, color: Colors.black54),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                Text(item.category,
                    style: const TextStyle(color: Colors.black54, fontSize: 13)),
                if (item.installmentNumber != null)
                  Text("Taksit: ${item.installmentNumber}",
                      style: const TextStyle(fontSize: 12, color: Colors.black45)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${item.amount.toStringAsFixed(2)} ${item.currency}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                formatter.format(item.dueDate),
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          )
        ],
      ),
    );
  }
}