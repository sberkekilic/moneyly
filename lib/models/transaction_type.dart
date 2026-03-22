import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum TransactionType {
  normal,
  installment,
  provisioned,
}

// Enum için yardımcı metodlar
extension TransactionTypeExtension on TransactionType {
  String get title {
    switch (this) {
      case TransactionType.normal:
        return 'Normal İşlem';
      case TransactionType.installment:
        return 'Taksitli İşlem';
      case TransactionType.provisioned:
        return 'Provizyonlu İşlem';
    }
  }

  String get subtitle {
    switch (this) {
      case TransactionType.normal:
        return 'Tek seferlik ödeme';
      case TransactionType.installment:
        return 'Birden fazla ödeme planı';
      case TransactionType.provisioned:
        return 'Otomatik normal işleme dönüşür';
    }
  }

  IconData get icon {
    switch (this) {
      case TransactionType.normal:
        return Icons.payment;
      case TransactionType.installment:
        return Icons.receipt_long;
      case TransactionType.provisioned:
        return Icons.pending_actions;
    }
  }

  Color get color {
    switch (this) {
      case TransactionType.normal:
        return Colors.blue;
      case TransactionType.installment:
        return Colors.purple;
      case TransactionType.provisioned:
        return Colors.orange;
    }
  }

  // İşlem tipine göre açıklama
  String get description {
    switch (this) {
      case TransactionType.normal:
        return '• Tek seferde ödenen işlem\n• Hemen hesaba yansır\n• Tarih seçimi zorunlu';
      case TransactionType.installment:
        return '• Birden fazla taksit\n• İlk taksit tarihi zorunlu\n• Taksit sayısı zorunlu\n• Her ay otomatik eklenir';
      case TransactionType.provisioned:
        return '• Henüz ödenmemiş işlem\n• Otomatik normal işleme dönüşür\n• Borç limitini etkiler ama kullanılabilir limiti etkilemez';
    }
  }
}