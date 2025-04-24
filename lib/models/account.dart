import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class Account {
  int accountId;
  String name;
  String type;
  double balance;
  List<dynamic> transactions;

  Account({
    required this.accountId,
    required this.name,
    required this.type,
    required this.balance,
    this.transactions = const [],
  });

  Map<String, dynamic> toJson() => {
    'accountId': accountId,
    'name' : name,
    'type' : type,
    'balance' : balance,
    'transactions': transactions,
  };

  factory Account.fromJson(Map<String, dynamic> json) => Account(
      accountId: json['accountId'],
      name: json['name'],
      type: json['type'],
      balance: json['balance'],
      transactions: json['transactions'] ?? [],
  );
}

class AccountCard extends StatelessWidget {
  final Account account;

  AccountCard({
    Key? key,
    required this.account
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.name,
                        style: GoogleFonts.montserrat(fontSize: 12.sp, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        account.type,
                        style: GoogleFonts.montserrat(fontSize: 8.sp, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Amount (top)
                    Text(
                      NumberFormat("#,##0.00", "tr_TR").format(account.balance),
                      style: GoogleFonts.montserrat(fontSize: 10.sp),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}