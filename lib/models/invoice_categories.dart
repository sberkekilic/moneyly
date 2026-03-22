enum InvoiceCategory {
  subscription,
  bill,
  other
}

extension InvoiceCategoryExtension on InvoiceCategory {
  String get displayName {
    switch (this) {
      case InvoiceCategory.subscription:
        return 'Abonelik';
      case InvoiceCategory.bill:
        return 'Fatura';
      case InvoiceCategory.other:
        return 'Diğer';
    }
  }
}