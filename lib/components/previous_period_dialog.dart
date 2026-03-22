import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class PreviousPeriodDialog extends StatelessWidget {
  final String bankName;
  final String accountName;
  final String cutoffDate;
  final String dueDate;
  final double debt;
  final List<dynamic>? transactions;
  final String periodKey;

  const PreviousPeriodDialog({
    Key? key,
    required this.bankName,
    required this.accountName,
    required this.cutoffDate,
    required this.dueDate,
    required this.debt,
    this.transactions,
    required this.periodKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final moneyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    return AlertDialog(
      title: Text(
        'Önceki Dönem Bilgisi',
        style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$bankName - $accountName',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _infoRow('Kesim Tarihi:', cutoffDate),
            _infoRow('Son Ödeme:', dueDate),
            _infoRow('Borç:', moneyFormat.format(debt)),
            if (transactions != null && transactions!.isNotEmpty) ...[
              const Divider(height: 24),
              Text(
                'Dönem Hareketleri',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...transactions!.take(5).map((tx) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        tx['description'] ?? 'İşlem',
                        style: GoogleFonts.montserrat(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      moneyFormat.format(tx['amount'] ?? 0),
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600,
                        color: (tx['amount'] ?? 0) > 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              )),
              if (transactions!.length > 5)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '+ ${transactions!.length - 5} işlem daha...',
                    style: GoogleFonts.montserrat(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Tamam',
            style: GoogleFonts.montserrat(color: Theme.of(context).primaryColor),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.montserrat(fontWeight: FontWeight.w500)),
          Text(value, style: GoogleFonts.montserrat()),
        ],
      ),
    );
  }
}