// lib/services/account_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/account.dart';
import '../models/transaction.dart';

class AccountService {
  static const _accountDataListKey = 'accountDataList';
  static const _selectedAccountKey = 'selectedAccount';

  // Load all accounts from all sources
  static Future<List<Account>> loadAllAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Account> allAccounts = [];

    // Load from accountDataList
    final accountDataListJson = prefs.getString(_accountDataListKey);
    if (accountDataListJson != null && accountDataListJson.isNotEmpty) {
      try {
        final accountDataList = jsonDecode(accountDataListJson) as List<dynamic>;

        for (final bankData in accountDataList) {
          final accounts = (bankData['accounts'] as List<dynamic>? ?? []);

          for (final accountJson in accounts) {
            final account = Account.fromJson(accountJson);
            allAccounts.add(account);
          }
        }
      } catch (e) {
        print('❌ Error loading accounts from accountDataList: $e');
      }
    } else {
      print('ℹ️ No accountDataList found in SharedPreferences');
    }

    // Load from selectedAccount (avoid duplicates)
    final selectedAccountJson = prefs.getString(_selectedAccountKey);
    if (selectedAccountJson != null && selectedAccountJson.isNotEmpty) {
      try {
        final selectedAccount = Account.fromJson(jsonDecode(selectedAccountJson));
        final exists = allAccounts.any((a) => a.accountId == selectedAccount.accountId);
        if (!exists) {
          allAccounts.add(selectedAccount);
        }
      } catch (e) {
        print('❌ Error loading selectedAccount: $e');
      }
    } else {
      print('ℹ️ No selectedAccount found in SharedPreferences');
    }

    print('✅ Loaded ${allAccounts.length} accounts total');
    return allAccounts;
  }

  // Extract all transactions from all accounts
  static Future<List<Transaction>> extractAllTransactions() async {
    final accounts = await loadAllAccounts();
    final List<Transaction> allTransactions = [];

    print('📊 Total accounts found: ${accounts.length}');

    for (final account in accounts) {
      print('📋 Account: ${account.name}, Transactions: ${account.transactions.length}');

      for (final transaction in account.transactions) {
        if (transaction is Transaction) {
          allTransactions.add(transaction);
          print('   ✅ Added: ${transaction.title} (ID: ${transaction.transactionId})');
        } else {
          print('   ❌ Skipped: Not a Transaction object');
        }
      }
    }

    print('✅ Extracted ${allTransactions.length} transactions from ${accounts.length} accounts');
    return allTransactions;
  }

  // Get account by ID
  static Future<Account?> getAccountById(int accountId) async {
    final accounts = await loadAllAccounts();

    try {
      return accounts.firstWhere((account) => account.accountId == accountId);
    } catch (e) {
      return null; // Account not found
    }
  }

  // Save accountDataList
  static Future<void> saveAccountDataList(List<dynamic> accountDataList) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accountDataListKey, jsonEncode(accountDataList));
  }

  // Save selectedAccount
  static Future<void> saveSelectedAccount(Account account) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedAccountKey, jsonEncode(account.toJson()));
  }

  // Update a transaction in all accounts
  static Future<void> updateTransactionInAccounts(Transaction updatedTransaction) async {
    final prefs = await SharedPreferences.getInstance();
    bool updated = false;

    // Update in accountDataList
    final accountDataListJson = prefs.getString(_accountDataListKey);
    if (accountDataListJson != null) {
      try {
        final accountDataList = jsonDecode(accountDataListJson) as List<dynamic>;

        for (int bankIndex = 0; bankIndex < accountDataList.length; bankIndex++) {
          final bankData = accountDataList[bankIndex] as Map<String, dynamic>;
          final accounts = (bankData['accounts'] as List<dynamic>? ?? []);

          for (int accountIndex = 0; accountIndex < accounts.length; accountIndex++) {
            final accountJson = accounts[accountIndex] as Map<String, dynamic>;
            final transactions = (accountJson['transactions'] as List<dynamic>? ?? []);

            for (int txIndex = 0; txIndex < transactions.length; txIndex++) {
              final txJson = transactions[txIndex] as Map<String, dynamic>;
              if (txJson['transactionId'] == updatedTransaction.transactionId) {
                // Update this transaction
                transactions[txIndex] = updatedTransaction.toJson();
                accountJson['transactions'] = transactions;
                accounts[accountIndex] = accountJson;
                bankData['accounts'] = accounts;
                accountDataList[bankIndex] = bankData;
                updated = true;
                break;
              }
            }
            if (updated) break;
          }
          if (updated) break;
        }

        if (updated) {
          await prefs.setString(_accountDataListKey, jsonEncode(accountDataList));
          print('✅ Updated transaction in accountDataList');
        }
      } catch (e) {
        print('❌ Error updating transaction in accountDataList: $e');
      }
    }

    // Update in selectedAccount
    final selectedAccountJson = prefs.getString(_selectedAccountKey);
    if (selectedAccountJson != null) {
      try {
        final selectedAccount = jsonDecode(selectedAccountJson) as Map<String, dynamic>;
        final transactions = (selectedAccount['transactions'] as List<dynamic>? ?? []);

        for (int i = 0; i < transactions.length; i++) {
          final txJson = transactions[i] as Map<String, dynamic>;
          if (txJson['transactionId'] == updatedTransaction.transactionId) {
            transactions[i] = updatedTransaction.toJson();
            selectedAccount['transactions'] = transactions;
            await prefs.setString(_selectedAccountKey, jsonEncode(selectedAccount));
            print('✅ Updated transaction in selectedAccount');
            break;
          }
        }
      } catch (e) {
        print('❌ Error updating transaction in selectedAccount: $e');
      }
    }
  }

  // Delete a transaction from all accounts
  static Future<void> deleteTransactionFromAccounts(int transactionId) async {
    final prefs = await SharedPreferences.getInstance();
    bool deleted = false;

    // Delete from accountDataList
    final accountDataListJson = prefs.getString(_accountDataListKey);
    if (accountDataListJson != null) {
      try {
        final accountDataList = jsonDecode(accountDataListJson) as List<dynamic>;

        for (int bankIndex = 0; bankIndex < accountDataList.length; bankIndex++) {
          final bankData = accountDataList[bankIndex] as Map<String, dynamic>;
          final accounts = (bankData['accounts'] as List<dynamic>? ?? []);

          for (int accountIndex = 0; accountIndex < accounts.length; accountIndex++) {
            final accountJson = accounts[accountIndex] as Map<String, dynamic>;
            final transactions = (accountJson['transactions'] as List<dynamic>? ?? []);

            final updatedTransactions = transactions.where((tx) {
              final txJson = tx as Map<String, dynamic>;
              return txJson['transactionId'] != transactionId;
            }).toList();

            if (updatedTransactions.length != transactions.length) {
              accountJson['transactions'] = updatedTransactions;
              accounts[accountIndex] = accountJson;
              bankData['accounts'] = accounts;
              accountDataList[bankIndex] = bankData;
              deleted = true;
              break;
            }
          }
          if (deleted) break;
        }

        if (deleted) {
          await prefs.setString(_accountDataListKey, jsonEncode(accountDataList));
          print('✅ Deleted transaction from accountDataList');
        }
      } catch (e) {
        print('❌ Error deleting transaction from accountDataList: $e');
      }
    }

    // Delete from selectedAccount
    final selectedAccountJson = prefs.getString(_selectedAccountKey);
    if (selectedAccountJson != null) {
      try {
        final selectedAccount = jsonDecode(selectedAccountJson) as Map<String, dynamic>;
        final transactions = (selectedAccount['transactions'] as List<dynamic>? ?? []);

        final updatedTransactions = transactions.where((tx) {
          final txJson = tx as Map<String, dynamic>;
          return txJson['transactionId'] != transactionId;
        }).toList();

        if (updatedTransactions.length != transactions.length) {
          selectedAccount['transactions'] = updatedTransactions;
          await prefs.setString(_selectedAccountKey, jsonEncode(selectedAccount));
          print('✅ Deleted transaction from selectedAccount');
        }
      } catch (e) {
        print('❌ Error deleting transaction from selectedAccount: $e');
      }
    }
  }
}