import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

import 'account.dart';
import 'transaction.dart';

// ============================================================================
// MODELS
// ============================================================================

class UpcomingPaymentModel {
  final String id;
  final String title;
  final String category;
  final DateTime dueDate;
  final double amount;
  final String currency;
  final PaymentType type;
  final PaymentStatus status;
  final Transaction? transaction;
  final Account? account;
  final int? installmentNumber;
  final int? totalInstallments;
  final bool isRecurring;
  final double? paidAmount;
  final bool hasReminder;

  UpcomingPaymentModel({
    required this.id,
    required this.title,
    required this.category,
    required this.dueDate,
    required this.amount,
    required this.currency,
    required this.type,
    this.status = PaymentStatus.pending,
    this.transaction,
    this.account,
    this.installmentNumber,
    this.totalInstallments,
    this.isRecurring = false,
    this.paidAmount,
    this.hasReminder = false,
  });

  int get daysUntilDue {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.difference(today).inDays;
  }

  bool get isOverdue => daysUntilDue < 0 && status != PaymentStatus.paid;
  bool get isDueToday => daysUntilDue == 0;
  bool get isDueTomorrow => daysUntilDue == 1;
  bool get isDueThisWeek => daysUntilDue >= 0 && daysUntilDue <= 7;
  bool get isPaid => status == PaymentStatus.paid;
  bool get isPartiallyPaid => status == PaymentStatus.partiallyPaid;

  double get remainingAmount {
    if (paidAmount != null && paidAmount! > 0) {
      return amount - paidAmount!;
    }
    return amount;
  }

  UpcomingPaymentModel copyWith({
    String? id,
    String? title,
    String? category,
    DateTime? dueDate,
    double? amount,
    String? currency,
    PaymentType? type,
    PaymentStatus? status,
    Transaction? transaction,
    Account? account,
    int? installmentNumber,
    int? totalInstallments,
    bool? isRecurring,
    double? paidAmount,
    bool? hasReminder,
  }) {
    return UpcomingPaymentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      type: type ?? this.type,
      status: status ?? this.status,
      transaction: transaction ?? this.transaction,
      account: account ?? this.account,
      installmentNumber: installmentNumber ?? this.installmentNumber,
      totalInstallments: totalInstallments ?? this.totalInstallments,
      isRecurring: isRecurring ?? this.isRecurring,
      paidAmount: paidAmount ?? this.paidAmount,
      hasReminder: hasReminder ?? this.hasReminder,
    );
  }
}

// Analytics model for monthly trends
class MonthlyPaymentAnalytics {
  final DateTime month;
  final double totalAmount;
  final double paidAmount;
  final int totalCount;
  final int paidCount;
  final int overdueCount;

  MonthlyPaymentAnalytics({
    required this.month,
    required this.totalAmount,
    required this.paidAmount,
    required this.totalCount,
    required this.paidCount,
    required this.overdueCount,
  });

  double get paidPercentage =>
      totalAmount > 0 ? (paidAmount / totalAmount) * 100 : 0;
  double get unpaidAmount => totalAmount - paidAmount;
}

enum PaymentType {
  installment,
  normal,
  creditCardMinimum,
  creditCardFull,
  recurringBill,
  invoice,
}

enum PaymentStatus {
  pending,
  paid,
  partiallyPaid,
  overdue,
}

enum TimeRangeFilter {
  week,
  twoWeeks,
  month,
  threeMonths,
  sixMonths,
  all,
}

extension TimeRangeFilterExtension on TimeRangeFilter {
  String get label {
    switch (this) {
      case TimeRangeFilter.week:
        return '1 Hafta';
      case TimeRangeFilter.twoWeeks:
        return '2 Hafta';
      case TimeRangeFilter.month:
        return '1 Ay';
      case TimeRangeFilter.threeMonths:
        return '3 Ay';
      case TimeRangeFilter.sixMonths:
        return '6 Ay';
      case TimeRangeFilter.all:
        return 'Tümü';
    }
  }

  int? get days {
    switch (this) {
      case TimeRangeFilter.week:
        return 7;
      case TimeRangeFilter.twoWeeks:
        return 14;
      case TimeRangeFilter.month:
        return 30;
      case TimeRangeFilter.threeMonths:
        return 90;
      case TimeRangeFilter.sixMonths:
        return 180;
      case TimeRangeFilter.all:
        return null;
    }
  }
}

// ============================================================================
// THEME COLORS
// ============================================================================

class UpcomingPaymentsColors {
  final bool isDark;

  UpcomingPaymentsColors({required this.isDark});

  Color get background =>
      isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5);
  Color get cardBackground =>
      isDark ? const Color(0xFF1E1E1E) : Colors.white;
  Color get headerBackground =>
      isDark ? const Color(0xFF1E1E1E) : Colors.white;

  Color get primaryText =>
      isDark ? Colors.white : const Color(0xFF1A1A1A);
  Color get secondaryText =>
      isDark ? const Color(0xFFB0B0B0) : const Color(0xFF757575);
  Color get tertiaryText =>
      isDark ? const Color(0xFF808080) : const Color(0xFF9E9E9E);

  Color get border =>
      isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE0E0E0);
  Color get divider =>
      isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE0E0E0);

  Color get accentBar => isDark ? Colors.white : const Color(0xFF1A1A1A);

  Color get chipBackground =>
      isDark ? const Color(0xFF2C2C2C) : Colors.white;
  Color get chipSelectedBackground =>
      isDark ? Colors.white : const Color(0xFF1A1A1A);
  Color get chipText => isDark ? Colors.white : const Color(0xFF1A1A1A);
  Color get chipSelectedText =>
      isDark ? const Color(0xFF1A1A1A) : Colors.white;
  Color get chipBorder =>
      isDark ? const Color(0xFF3C3C3C) : const Color(0xFFE0E0E0);

  Color get overdue => const Color(0xFFD32F2F);
  Color get warning => const Color(0xFFFF6F00);
  Color get success => const Color(0xFF388E3C);
  Color get info => const Color(0xFF1976D2);

  Color get installment => const Color(0xFF00897B);
  Color get normal => const Color(0xFF1976D2);
  Color get creditCardMin => const Color(0xFFFF6F00);
  Color get creditCardFull => const Color(0xFF6A1B9A);
  Color get recurringBill => const Color(0xFF5E35B1);
  Color get invoice => const Color(0xFF00ACC1);

  Color get emptyIcon =>
      isDark ? const Color(0xFF404040) : const Color(0xFFBDBDBD);
  Color get emptyText =>
      isDark ? const Color(0xFF808080) : const Color(0xFF757575);
  Color get emptySubtext =>
      isDark ? const Color(0xFF606060) : const Color(0xFF9E9E9E);

  // Quick action colors
  Color get payAction => const Color(0xFF388E3C);
  Color get reminderAction => const Color(0xFF1976D2);
  Color get deleteAction => const Color(0xFFD32F2F);

  // Analytics colors
  Color get chartPaid => const Color(0xFF4CAF50);
  Color get chartUnpaid => isDark ? const Color(0xFF424242) : const Color(0xFFE0E0E0);
  Color get chartOverdue => const Color(0xFFD32F2F);
}

// ============================================================================
// NOTIFICATION SERVICE
// ============================================================================

class PaymentReminderService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - navigate to payment detail
    // You can parse the payload and navigate accordingly
  }

  static Future<bool> requestPermissions() async {
    final android = _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final iOS = _notifications
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }

    if (iOS != null) {
      final granted = await iOS.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return false;
  }

  static Future<void> schedulePaymentReminder({
    required String paymentId,
    required String title,
    required double amount,
    required String currency,
    required DateTime dueDate,
    int daysBefore = 1,
  }) async {
    await initialize();

    final scheduledDate = dueDate.subtract(Duration(days: daysBefore));

    // Don't schedule if the date is in the past
    if (scheduledDate.isBefore(DateTime.now())) {
      // Schedule for now + 1 minute as a test
      return;
    }

    final id = paymentId.hashCode;

    const androidDetails = AndroidNotificationDetails(
      'payment_reminders',
      'Ödeme Hatırlatıcıları',
      channelDescription: 'Yaklaşan ödemeler için hatırlatıcılar',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final formattedAmount = NumberFormat('#,##0.00', 'tr_TR').format(amount);
    final formattedDate = DateFormat('d MMMM', 'tr_TR').format(dueDate);

    await _notifications.zonedSchedule(
      id: id,
      title: '💰 Ödeme Hatırlatıcısı',
      body: '$title için $formattedAmount $currency ödemeniz $formattedDate tarihinde.',
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: paymentId,
    );
  }

  static Future<void> cancelReminder(String paymentId) async {
    await _notifications.cancel(id: paymentId.hashCode);
  }

  static Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
  }

  // Schedule reminders for multiple days before
  static Future<void> scheduleMultipleReminders({
    required String paymentId,
    required String title,
    required double amount,
    required String currency,
    required DateTime dueDate,
    List<int> daysBefore = const [1, 3, 7],
  }) async {
    for (final days in daysBefore) {
      await schedulePaymentReminder(
        paymentId: '${paymentId}_$days',
        title: title,
        amount: amount,
        currency: currency,
        dueDate: dueDate,
        daysBefore: days,
      );
    }
  }
}

// ============================================================================
// MAIN WIDGET
// ============================================================================

class UpcomingPaymentsSection extends StatefulWidget {
  final Account? account;
  final List<Account>? allAccounts;
  final Function(Transaction)? onTransactionUpdated;
  final bool showAnalytics;

  const UpcomingPaymentsSection({
    super.key,
    this.account,
    this.allAccounts,
    this.onTransactionUpdated,
    this.showAnalytics = true,
  });

  @override
  State<UpcomingPaymentsSection> createState() =>
      _UpcomingPaymentsSectionState();
}

class _UpcomingPaymentsSectionState extends State<UpcomingPaymentsSection>
    with SingleTickerProviderStateMixin {
  TimeRangeFilter _selectedTimeRange = TimeRangeFilter.month;
  bool _showPaidPayments = false;
  Set<PaymentType> _activeFilters = PaymentType.values.toSet();
  bool _showAnalyticsExpanded = false;

  late AnimationController _analyticsAnimationController;
  late Animation<double> _analyticsAnimation;

  @override
  void initState() {
    super.initState();
    _analyticsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _analyticsAnimation = CurvedAnimation(
      parent: _analyticsAnimationController,
      curve: Curves.easeInOut,
    );

    // Initialize notifications
    PaymentReminderService.initialize();
  }

  @override
  void dispose() {
    _analyticsAnimationController.dispose();
    super.dispose();
  }

  List<UpcomingPaymentModel> _getUpcomingPayments() {
    DateTime onlyDate(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
    final now = onlyDate(DateTime.now());
    final int? daysLimit = _selectedTimeRange.days;
    final endDate = daysLimit != null
        ? now.add(Duration(days: daysLimit))
        : now.add(const Duration(days: 365 * 10));

    final List<UpcomingPaymentModel> upcoming = [];

    List<Account> accountsToProcess = [];
    if (widget.allAccounts != null && widget.allAccounts!.isNotEmpty) {
      accountsToProcess = widget.allAccounts!;
    } else if (widget.account != null) {
      accountsToProcess = [widget.account!];
    }

    for (final account in accountsToProcess) {
      // 1. INSTALLMENT PAYMENTS
      for (final txn in account.transactions.whereType<Transaction>()) {
        if (txn.isInstallment && txn.initialInstallmentDate != null) {
          final totalInstallments = txn.installment!;
          final installmentAmount = txn.installmentAmount;

          for (int i = 0; i < totalInstallments; i++) {
            final dueDate = onlyDate(DateTime(
              txn.initialInstallmentDate!.year,
              txn.initialInstallmentDate!.month + i,
              txn.initialInstallmentDate!.day,
            ));

            if (dueDate.isBefore(now) && !_showPaidPayments) continue;
            if (dueDate.isAfter(endDate)) continue;

            PaymentStatus status = PaymentStatus.pending;
            double? paidAmount;

            final isPaidInstallment = (txn.currentInstallment != null &&
                i < (txn.currentInstallment! - 1)) ||
                (txn.isInstallmentPaid == true &&
                    i == (txn.currentInstallment ?? 1) - 1);

            if (isPaidInstallment) {
              status = PaymentStatus.paid;
              paidAmount = installmentAmount;
            } else if (dueDate.isBefore(now)) {
              status = PaymentStatus.overdue;
            }

            if (status == PaymentStatus.paid && !_showPaidPayments) continue;

            upcoming.add(UpcomingPaymentModel(
              id: '${txn.transactionId}_inst_$i',
              title: txn.title,
              category: txn.category,
              dueDate: dueDate,
              amount: installmentAmount,
              currency: txn.currency,
              type: PaymentType.installment,
              status: status,
              transaction: txn,
              account: account,
              installmentNumber: i + 1,
              totalInstallments: totalInstallments,
              paidAmount: paidAmount,
            ));
          }
        }
        // 2. NORMAL PAYMENTS
        else if (!txn.isSurplus && !txn.isInstallment) {
          final txnDate = onlyDate(txn.date);

          if (txnDate.isBefore(now.subtract(const Duration(days: 30))) &&
              !_showPaidPayments) continue;
          if (txnDate.isAfter(endDate)) continue;

          PaymentStatus status = PaymentStatus.pending;
          if (txn.paidAmount != null && txn.paidAmount! >= txn.amount) {
            status = PaymentStatus.paid;
          } else if (txn.paidAmount != null && txn.paidAmount! > 0) {
            status = PaymentStatus.partiallyPaid;
          } else if (txnDate.isBefore(now)) {
            status = PaymentStatus.overdue;
          }

          if (status == PaymentStatus.paid && !_showPaidPayments) continue;

          upcoming.add(UpcomingPaymentModel(
            id: '${txn.transactionId}_normal',
            title: txn.title,
            category: txn.category,
            dueDate: txn.date,
            amount: txn.amount,
            currency: txn.currency,
            type: PaymentType.normal,
            status: status,
            transaction: txn,
            account: account,
            paidAmount: txn.paidAmount,
          ));
        }
      }

      // 3. CREDIT CARD PAYMENTS
      if (!account.isDebit && account.nextDueDate != null) {
        final dueDate = onlyDate(account.nextDueDate!);

        if (dueDate.isAfter(now.subtract(const Duration(days: 7))) &&
            dueDate.isBefore(endDate)) {
          PaymentStatus status = PaymentStatus.pending;
          if (dueDate.isBefore(now)) {
            status = PaymentStatus.overdue;
          }

          final minPaymentAmount =
              account.remainingMinPayment ?? account.minPayment ?? 0.0;

          if (minPaymentAmount > 0) {
            upcoming.add(UpcomingPaymentModel(
              id: '${account.accountId}_cc_min',
              title: account.name,
              category: "Asgari Ödeme",
              dueDate: dueDate,
              amount: minPaymentAmount,
              currency: account.currency,
              type: PaymentType.creditCardMinimum,
              status: status,
              account: account,
              isRecurring: true,
            ));
          }

          final totalDebt = account.totalDebt ?? account.remainingDebt ?? 0.0;
          if (totalDebt > minPaymentAmount && totalDebt > 0) {
            upcoming.add(UpcomingPaymentModel(
              id: '${account.accountId}_cc_full',
              title: account.name,
              category: "Tam Ödeme",
              dueDate: dueDate,
              amount: totalDebt,
              currency: account.currency,
              type: PaymentType.creditCardFull,
              status: status,
              account: account,
              isRecurring: true,
            ));
          }
        }
      }
    }

    final filtered =
    upcoming.where((p) => _activeFilters.contains(p.type)).toList();

    filtered.sort((a, b) {
      if (a.isOverdue && !b.isOverdue) return -1;
      if (!a.isOverdue && b.isOverdue) return 1;
      final dateComparison = a.dueDate.compareTo(b.dueDate);
      if (dateComparison != 0) return dateComparison;
      return b.amount.compareTo(a.amount);
    });

    return filtered;
  }

  List<MonthlyPaymentAnalytics> _getMonthlyAnalytics(
      List<UpcomingPaymentModel> payments) {
    final Map<String, MonthlyPaymentAnalytics> monthlyData = {};

    for (final payment in payments) {
      final monthKey =
      DateFormat('yyyy-MM').format(payment.dueDate);
      final monthDate =
      DateTime(payment.dueDate.year, payment.dueDate.month, 1);

      if (!monthlyData.containsKey(monthKey)) {
        monthlyData[monthKey] = MonthlyPaymentAnalytics(
          month: monthDate,
          totalAmount: 0,
          paidAmount: 0,
          totalCount: 0,
          paidCount: 0,
          overdueCount: 0,
        );
      }

      final existing = monthlyData[monthKey]!;
      monthlyData[monthKey] = MonthlyPaymentAnalytics(
        month: existing.month,
        totalAmount: existing.totalAmount + payment.amount,
        paidAmount: existing.paidAmount +
            (payment.isPaid ? payment.amount : (payment.paidAmount ?? 0)),
        totalCount: existing.totalCount + 1,
        paidCount: existing.paidCount + (payment.isPaid ? 1 : 0),
        overdueCount: existing.overdueCount + (payment.isOverdue ? 1 : 0),
      );
    }

    final result = monthlyData.values.toList()
      ..sort((a, b) => a.month.compareTo(b.month));

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = UpcomingPaymentsColors(isDark: isDark);
    final upcomingList = _getUpcomingPayments();

    final totalAmount = upcomingList
        .where((p) => p.status != PaymentStatus.paid)
        .fold<double>(0, (sum, payment) => sum + payment.remainingAmount);

    final overdueCount = upcomingList.where((p) => p.isOverdue).length;
    final dueThisWeekCount =
        upcomingList.where((p) => p.isDueThisWeek && !p.isOverdue).length;

    return Container(
      width: double.infinity,
      color: colors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(colors, upcomingList.length, totalAmount),
          _buildTimeRangeFilter(colors),
          if (upcomingList.isNotEmpty &&
              (overdueCount > 0 || dueThisWeekCount > 0))
            _buildSummaryCards(colors, overdueCount, dueThisWeekCount),

          // Analytics Section
          if (widget.showAnalytics && upcomingList.isNotEmpty)
            _buildAnalyticsSection(colors, upcomingList),

          SizedBox(height: 16.h),

          if (upcomingList.isEmpty)
            _buildEmptyState(colors)
          else
            _buildPaymentList(colors, upcomingList),

          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HEADER
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildHeader(UpcomingPaymentsColors colors, int count, double total) {
    final currencySymbol = widget.account?.currency ?? 'TRY';

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 16.h),
      color: colors.headerBackground,
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 32.h,
            decoration: BoxDecoration(
              color: colors.accentBar,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Yaklaşan Ödemeler",
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: colors.primaryText,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  count > 0
                      ? "$count ödeme • ${NumberFormat('#,##0.00', 'tr_TR').format(total)} $currencySymbol"
                      : "Seçili dönemde ödeme yok",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: colors.secondaryText,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showSettingsBottomSheet(colors),
            icon: Icon(Icons.tune_rounded, color: colors.secondaryText),
            style: IconButton.styleFrom(
              backgroundColor: colors.chipBackground,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TIME RANGE FILTER
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildTimeRangeFilter(UpcomingPaymentsColors colors) {
    return Container(
      color: colors.headerBackground,
      padding: EdgeInsets.fromLTRB(20.w, 0, 0, 16.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: TimeRangeFilter.values.map((range) {
            final isSelected = _selectedTimeRange == range;
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTimeRange = range;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.chipSelectedBackground
                        : colors.chipBackground,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected
                          ? colors.chipSelectedBackground
                          : colors.chipBorder,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    range.label,
                    style: TextStyle(
                      color: isSelected
                          ? colors.chipSelectedText
                          : colors.chipText,
                      fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SUMMARY CARDS
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildSummaryCards(
      UpcomingPaymentsColors colors, int overdueCount, int dueThisWeekCount) {
    return Container(
      color: colors.headerBackground,
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
      child: Row(
        children: [
          if (overdueCount > 0)
            Expanded(
              child: _summaryCard(
                colors,
                "Gecikmiş",
                overdueCount.toString(),
                colors.overdue,
                Icons.warning_rounded,
              ),
            ),
          if (overdueCount > 0 && dueThisWeekCount > 0) SizedBox(width: 12.w),
          if (dueThisWeekCount > 0)
            Expanded(
              child: _summaryCard(
                colors,
                "Bu Hafta",
                dueThisWeekCount.toString(),
                colors.warning,
                Icons.event_rounded,
              ),
            ),
        ],
      ),
    );
  }

  Widget _summaryCard(UpcomingPaymentsColors colors, String label, String value,
      Color accentColor, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: accentColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: accentColor, size: 22.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: colors.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ANALYTICS SECTION
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildAnalyticsSection(
      UpcomingPaymentsColors colors, List<UpcomingPaymentModel> payments) {
    final analytics = _getMonthlyAnalytics(payments);
    if (analytics.isEmpty) return const SizedBox.shrink();

    return Container(
      color: colors.headerBackground,
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Analytics Header
          GestureDetector(
            onTap: () {
              setState(() {
                _showAnalyticsExpanded = !_showAnalyticsExpanded;
              });
              if (_showAnalyticsExpanded) {
                _analyticsAnimationController.forward();
              } else {
                _analyticsAnimationController.reverse();
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Row(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    color: colors.info,
                    size: 20.r,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      "Aylık Ödeme Analizi",
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: colors.primaryText,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _showAnalyticsExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: colors.secondaryText,
                      size: 24.r,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable Analytics Content
          SizeTransition(
            sizeFactor: _analyticsAnimation,
            child: Column(
              children: [
                SizedBox(height: 8.h),
                _buildAnalyticsChart(colors, analytics),
                SizedBox(height: 16.h),
                _buildAnalyticsSummary(colors, analytics),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsChart(
      UpcomingPaymentsColors colors, List<MonthlyPaymentAnalytics> analytics) {
    final maxAmount =
    analytics.map((a) => a.totalAmount).reduce((a, b) => a > b ? a : b);

    return Container(
      height: 160.h,
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: analytics.take(6).map((month) {
          final totalHeight = maxAmount > 0 ? (month.totalAmount / maxAmount) : 0.0;
          final paidHeight = month.totalAmount > 0
              ? (month.paidAmount / month.totalAmount)
              : 0.0;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Amount label
                  Text(
                    _formatCompactAmount(month.totalAmount),
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: colors.secondaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  // Bar
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final barHeight = constraints.maxHeight * totalHeight;
                        return Container(
                          width: double.infinity,
                          height: barHeight.clamp(4.0, constraints.maxHeight),
                          decoration: BoxDecoration(
                            color: colors.chartUnpaid,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: double.infinity,
                              height: barHeight * paidHeight,
                              decoration: BoxDecoration(
                                color: colors.chartPaid,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // Month label
                  Text(
                    DateFormat('MMM', 'tr_TR').format(month.month),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: colors.secondaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAnalyticsSummary(
      UpcomingPaymentsColors colors, List<MonthlyPaymentAnalytics> analytics) {
    final totalAmount = analytics.fold<double>(0, (sum, a) => sum + a.totalAmount);
    final paidAmount = analytics.fold<double>(0, (sum, a) => sum + a.paidAmount);
    final overdueCount = analytics.fold<int>(0, (sum, a) => sum + a.overdueCount);

    return Row(
      children: [
        _analyticsStatCard(
          colors,
          "Toplam",
          _formatCompactAmount(totalAmount),
          colors.info,
        ),
        SizedBox(width: 8.w),
        _analyticsStatCard(
          colors,
          "Ödenen",
          _formatCompactAmount(paidAmount),
          colors.success,
        ),
        SizedBox(width: 8.w),
        _analyticsStatCard(
          colors,
          "Geciken",
          overdueCount.toString(),
          colors.overdue,
        ),
      ],
    );
  }

  Widget _analyticsStatCard(
      UpcomingPaymentsColors colors, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: colors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCompactAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PAYMENT LIST
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildPaymentList(
      UpcomingPaymentsColors colors, List<UpcomingPaymentModel> payments) {
    final grouped = <String, List<UpcomingPaymentModel>>{};
    for (final payment in payments) {
      final key = DateFormat('yyyy-MM-dd').format(payment.dueDate);
      grouped.putIfAbsent(key, () => []).add(payment);
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final entry = grouped.entries.elementAt(index);
        final date = DateTime.parse(entry.key);
        final items = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateHeader(colors, date, items),
            SizedBox(height: 12.h),
            ...items.map((item) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: PaymentCard(
                item: item,
                colors: colors,
                showAccountName: widget.allAccounts != null &&
                    widget.allAccounts!.length > 1,
                onTap: () => _showPaymentActions(colors, item),
                onQuickPay: () => _onMarkAsPaid(item),
                onSetReminder: () => _onSetReminder(item),
              ),
            )),
          ],
        );
      },
    );
  }

  Widget _buildDateHeader(UpcomingPaymentsColors colors, DateTime date,
      List<UpcomingPaymentModel> payments) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    String label;
    Color labelColor = colors.primaryText;

    if (dateOnly.isBefore(today)) {
      final daysOverdue = today.difference(dateOnly).inDays;
      label = "$daysOverdue gün gecikmiş";
      labelColor = colors.overdue;
    } else if (dateOnly == today) {
      label = "Bugün";
      labelColor = colors.warning;
    } else if (dateOnly == tomorrow) {
      label = "Yarın";
    } else {
      label = DateFormat('d MMMM EEEE', 'tr_TR').format(date);
    }

    final totalAmount =
    payments.fold<double>(0, (sum, p) => sum + p.remainingAmount);
    final currency = payments.first.currency;

    return Padding(
      padding: EdgeInsets.only(top: 8.h, bottom: 4.h),
      child: Row(
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: labelColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: colors.border),
            ),
            child: Text(
              "${NumberFormat('#,##0.00', 'tr_TR').format(totalAmount)} $currency",
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: colors.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // EMPTY STATE
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildEmptyState(UpcomingPaymentsColors colors) {
    String title;
    String subtitle;
    IconData icon;

    switch (_selectedTimeRange) {
      case TimeRangeFilter.week:
        title = "Bu hafta ödeme yok";
        subtitle = "Önümüzdeki 7 gün içinde yaklaşan ödemeniz bulunmuyor";
        icon = Icons.event_available_rounded;
        break;
      case TimeRangeFilter.twoWeeks:
        title = "2 hafta içinde ödeme yok";
        subtitle = "Önümüzdeki 14 gün içinde yaklaşan ödemeniz bulunmuyor";
        icon = Icons.event_available_rounded;
        break;
      case TimeRangeFilter.month:
        title = "Bu ay ödeme yok";
        subtitle = "Önümüzdeki 30 gün içinde yaklaşan ödemeniz bulunmuyor";
        icon = Icons.calendar_today_rounded;
        break;
      case TimeRangeFilter.threeMonths:
        title = "3 ay içinde ödeme yok";
        subtitle = "Önümüzdeki 3 ay içinde yaklaşan ödemeniz bulunmuyor";
        icon = Icons.date_range_rounded;
        break;
      case TimeRangeFilter.sixMonths:
        title = "6 ay içinde ödeme yok";
        subtitle = "Önümüzdeki 6 ay içinde yaklaşan ödemeniz bulunmuyor";
        icon = Icons.date_range_rounded;
        break;
      case TimeRangeFilter.all:
        title = "Hiç ödeme yok";
        subtitle = "Henüz yaklaşan bir ödemeniz bulunmuyor";
        icon = Icons.check_circle_outline_rounded;
        break;
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.symmetric(vertical: 48.h, horizontal: 24.w),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.r,
            height: 80.r,
            decoration: BoxDecoration(
              color: colors.emptyIcon.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40.r, color: colors.emptyIcon),
          ),
          SizedBox(height: 20.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: colors.emptyText,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14.sp,
              color: colors.emptySubtext,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          if (_selectedTimeRange != TimeRangeFilter.all)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  final currentIndex =
                  TimeRangeFilter.values.indexOf(_selectedTimeRange);
                  if (currentIndex < TimeRangeFilter.values.length - 1) {
                    _selectedTimeRange =
                    TimeRangeFilter.values[currentIndex + 1];
                  }
                });
              },
              icon: Icon(Icons.expand_more_rounded, color: colors.info, size: 20.r),
              label: Text(
                "Daha geniş aralık göster",
                style: TextStyle(
                  color: colors.info,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PAYMENT ACTIONS BOTTOM SHEET
  // ══════════════════════════════════════════════════════════════════════════

  void _showPaymentActions(
      UpcomingPaymentsColors colors, UpcomingPaymentModel payment) {
    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Payment Info Header
            Row(
              children: [
                Container(
                  width: 48.r,
                  height: 48.r,
                  decoration: BoxDecoration(
                    color: _getPaymentColor(colors, payment).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    _getPaymentIcon(payment),
                    color: _getPaymentColor(colors, payment),
                    size: 24.r,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.title,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: colors.primaryText,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        "${NumberFormat('#,##0.00', 'tr_TR').format(payment.amount)} ${payment.currency}",
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: colors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.h),
            Divider(color: colors.divider),
            SizedBox(height: 16.h),

            // Quick Actions
            if (!payment.isPaid) ...[
              // Mark as Paid
              _actionButton(
                colors: colors,
                icon: Icons.check_circle_rounded,
                label: "Ödendi Olarak İşaretle",
                color: colors.success,
                onTap: () {
                  Navigator.pop(context);
                  _onMarkAsPaid(payment);
                },
              ),
              SizedBox(height: 12.h),

              // Partial Payment
              _actionButton(
                colors: colors,
                icon: Icons.pie_chart_rounded,
                label: "Kısmi Ödeme Yap",
                color: colors.warning,
                onTap: () {
                  Navigator.pop(context);
                  _showPartialPaymentDialog(colors, payment);
                },
              ),
              SizedBox(height: 12.h),

              // Set Reminder
              _actionButton(
                colors: colors,
                icon: Icons.notifications_rounded,
                label: payment.hasReminder
                    ? "Hatırlatıcıyı Kaldır"
                    : "Hatırlatıcı Ekle",
                color: colors.info,
                onTap: () {
                  Navigator.pop(context);
                  _onSetReminder(payment);
                },
              ),
              SizedBox(height: 12.h),
            ],

            // View Details
            _actionButton(
              colors: colors,
              icon: Icons.info_outline_rounded,
              label: "Detayları Görüntüle",
              color: colors.secondaryText,
              onTap: () {
                Navigator.pop(context);
                // Navigate to payment/transaction detail
              },
            ),

            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required UpcomingPaymentsColors colors,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Ink(
          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22.r),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: color.withOpacity(0.5),
                size: 16.r,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPartialPaymentDialog(
      UpcomingPaymentsColors colors, UpcomingPaymentModel payment) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          "Kısmi Ödeme",
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: colors.primaryText,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Toplam: ${NumberFormat('#,##0.00', 'tr_TR').format(payment.amount)} ${payment.currency}",
              style: TextStyle(
                fontSize: 14.sp,
                color: colors.secondaryText,
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: "Ödenen Tutar",
                suffixText: payment.currency,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "İptal",
              style: TextStyle(color: colors.secondaryText),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(
                  controller.text.replaceAll(',', '.'));
              if (amount != null && amount > 0) {
                Navigator.pop(context);
                _onPartialPayment(payment, amount);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.success,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: const Text("Kaydet"),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SETTINGS BOTTOM SHEET
  // ══════════════════════════════════════════════════════════════════════════

  void _showSettingsBottomSheet(UpcomingPaymentsColors colors) {
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.all(24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                "Filtreler",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: colors.primaryText,
                ),
              ),
              SizedBox(height: 20.h),
              SwitchListTile(
                title: Text(
                  "Ödenen ödemeleri göster",
                  style: TextStyle(fontSize: 15.sp, color: colors.primaryText),
                ),
                value: _showPaidPayments,
                onChanged: (value) {
                  setModalState(() => _showPaidPayments = value);
                  setState(() {});
                },
                activeColor: colors.success,
                contentPadding: EdgeInsets.zero,
              ),
              Divider(color: colors.divider, height: 32.h),
              Text(
                "Ödeme Türleri",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: colors.primaryText,
                ),
              ),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: PaymentType.values.map((type) {
                  final isActive = _activeFilters.contains(type);
                  return FilterChip(
                    label: Text(_getPaymentTypeLabel(type)),
                    selected: isActive,
                    onSelected: (selected) {
                      setModalState(() {
                        if (selected) {
                          _activeFilters.add(type);
                        } else {
                          _activeFilters.remove(type);
                        }
                      });
                      setState(() {});
                    },
                    backgroundColor: colors.chipBackground,
                    selectedColor: colors.chipSelectedBackground,
                    checkmarkColor: colors.chipSelectedText,
                    labelStyle: TextStyle(
                      color: isActive
                          ? colors.chipSelectedText
                          : colors.chipText,
                      fontSize: 13.sp,
                    ),
                    side: BorderSide(
                      color: isActive
                          ? colors.chipSelectedBackground
                          : colors.chipBorder,
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  String _getPaymentTypeLabel(PaymentType type) {
    switch (type) {
      case PaymentType.installment:
        return 'Taksitler';
      case PaymentType.normal:
        return 'Normal';
      case PaymentType.creditCardMinimum:
        return 'KK Asgari';
      case PaymentType.creditCardFull:
        return 'KK Tam';
      case PaymentType.recurringBill:
        return 'Düzenli';
      case PaymentType.invoice:
        return 'Faturalar';
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ACTIONS
  // ══════════════════════════════════════════════════════════════════════════

  void _onMarkAsPaid(UpcomingPaymentModel payment) {
    HapticFeedback.mediumImpact();

    if (payment.transaction != null) {
      final updatedTxn = payment.transaction!.copyWith(
        isInstallmentPaid: true,
        paidAmount: payment.amount,
      );
      widget.onTransactionUpdated?.call(updatedTxn);
    }

    // Cancel reminder if exists
    PaymentReminderService.cancelReminder(payment.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                "${payment.title} ödendi olarak işaretlendi",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF388E3C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        action: SnackBarAction(
          label: "Geri Al",
          textColor: Colors.white,
          onPressed: () {
            // Undo action
            if (payment.transaction != null) {
              final revertedTxn = payment.transaction!.copyWith(
                isInstallmentPaid: false,
                paidAmount: 0,
              );
              widget.onTransactionUpdated?.call(revertedTxn);
            }
          },
        ),
      ),
    );

    setState(() {});
  }

  void _onPartialPayment(UpcomingPaymentModel payment, double amount) {
    HapticFeedback.mediumImpact();

    if (payment.transaction != null) {
      final updatedTxn = payment.transaction!.copyWith(
        paidAmount: amount,
      );
      widget.onTransactionUpdated?.call(updatedTxn);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "${NumberFormat('#,##0.00', 'tr_TR').format(amount)} ${payment.currency} kısmi ödeme kaydedildi",
        ),
        backgroundColor: const Color(0xFFFF6F00),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );

    setState(() {});
  }

  Future<void> _onSetReminder(UpcomingPaymentModel payment) async {
    HapticFeedback.mediumImpact();

    if (payment.hasReminder) {
      await PaymentReminderService.cancelReminder(payment.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Hatırlatıcı kaldırıldı"),
          backgroundColor: const Color(0xFF757575),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
      );
    } else {
      final hasPermission = await PaymentReminderService.requestPermissions();
      if (!hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Bildirim izni verilmedi"),
            backgroundColor: const Color(0xFFD32F2F),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          ),
        );
        return;
      }

      await PaymentReminderService.scheduleMultipleReminders(
        paymentId: payment.id,
        title: payment.title,
        amount: payment.amount,
        currency: payment.currency,
        dueDate: payment.dueDate,
        daysBefore: [1, 3],
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.notifications_active, color: Colors.white),
              SizedBox(width: 12.w),
              const Expanded(
                child: Text("Hatırlatıcı ayarlandı (1 ve 3 gün önce)"),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1976D2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
      );
    }

    setState(() {});
  }

  Color _getPaymentColor(UpcomingPaymentsColors colors, UpcomingPaymentModel payment) {
    if (payment.isPaid) return colors.success;
    if (payment.isOverdue) return colors.overdue;

    switch (payment.type) {
      case PaymentType.installment:
        return colors.installment;
      case PaymentType.normal:
        return colors.normal;
      case PaymentType.creditCardMinimum:
        return colors.creditCardMin;
      case PaymentType.creditCardFull:
        return colors.creditCardFull;
      case PaymentType.recurringBill:
        return colors.recurringBill;
      case PaymentType.invoice:
        return colors.invoice;
    }
  }

  IconData _getPaymentIcon(UpcomingPaymentModel payment) {
    switch (payment.type) {
      case PaymentType.installment:
        return Icons.autorenew_rounded;
      case PaymentType.normal:
        return Icons.payments_outlined;
      case PaymentType.creditCardMinimum:
        return Icons.credit_card_rounded;
      case PaymentType.creditCardFull:
        return Icons.account_balance_wallet_rounded;
      case PaymentType.recurringBill:
        return Icons.repeat_rounded;
      case PaymentType.invoice:
        return Icons.receipt_long_rounded;
    }
  }
}

// ============================================================================
// PAYMENT CARD (FIXED OVERFLOW)
// ============================================================================

class PaymentCard extends StatelessWidget {
  final UpcomingPaymentModel item;
  final UpcomingPaymentsColors colors;
  final bool showAccountName;
  final VoidCallback? onTap;
  final VoidCallback? onQuickPay;
  final VoidCallback? onSetReminder;

  const PaymentCard({
    super.key,
    required this.item,
    required this.colors,
    this.showAccountName = false,
    this.onTap,
    this.onQuickPay,
    this.onSetReminder,
  });

  IconData getIcon() {
    if (item.isPaid) return Icons.check_rounded;
    switch (item.type) {
      case PaymentType.installment:
        return Icons.autorenew_rounded;
      case PaymentType.normal:
        return Icons.payments_outlined;
      case PaymentType.creditCardMinimum:
        return Icons.credit_card_rounded;
      case PaymentType.creditCardFull:
        return Icons.account_balance_wallet_rounded;
      case PaymentType.recurringBill:
        return Icons.repeat_rounded;
      case PaymentType.invoice:
        return Icons.receipt_long_rounded;
    }
  }

  Color getAccentColor() {
    if (item.isPaid) return colors.success;
    if (item.isOverdue) return colors.overdue;

    switch (item.type) {
      case PaymentType.installment:
        return colors.installment;
      case PaymentType.normal:
        return colors.normal;
      case PaymentType.creditCardMinimum:
        return colors.creditCardMin;
      case PaymentType.creditCardFull:
        return colors.creditCardFull;
      case PaymentType.recurringBill:
        return colors.recurringBill;
      case PaymentType.invoice:
        return colors.invoice;
    }
  }

  String getDaysLabel() {
    if (item.isPaid) return "Ödendi";
    if (item.isPartiallyPaid) return "Kısmi";
    if (item.isOverdue) return "${item.daysUntilDue.abs()}g gecikmiş";
    if (item.isDueToday) return "Bugün";
    if (item.isDueTomorrow) return "Yarın";
    return "${item.daysUntilDue}g";
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = getAccentColor();
    final daysLabel = getDaysLabel();

    return Dismissible(
      key: Key(item.id),
      direction: item.isPaid
          ? DismissDirection.none
          : DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Quick pay
          onQuickPay?.call();
          return false;
        } else if (direction == DismissDirection.endToStart) {
          // Set reminder
          onSetReminder?.call();
          return false;
        }
        return false;
      },
      background: Container(
        decoration: BoxDecoration(
          color: colors.success,
          borderRadius: BorderRadius.circular(16.r),
        ),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 20.w),
        child: Row(
          children: [
            Icon(Icons.check_rounded, color: Colors.white, size: 24.r),
            SizedBox(width: 8.w),
            Text(
              "Ödendi",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        decoration: BoxDecoration(
          color: colors.info,
          borderRadius: BorderRadius.circular(16.r),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "Hatırlat",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.notifications_rounded, color: Colors.white, size: 24.r),
          ],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Ink(
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: item.isOverdue
                    ? accentColor.withOpacity(0.5)
                    : item.isPaid
                    ? colors.success.withOpacity(0.3)
                    : colors.border,
                width: item.isOverdue || item.isPaid ? 2 : 1,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.h),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 44.r,
                    height: 44.r,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(getIcon(), size: 22.r, color: accentColor),
                  ),

                  SizedBox(width: 12.w),

                  // Content - FIXED OVERFLOW
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                            color: item.isPaid
                                ? colors.secondaryText
                                : colors.primaryText,
                            decoration: item.isPaid
                                ? TextDecoration.lineThrough
                                : null,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        // FIXED: Use Wrap instead of Row for potential overflow
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                item.category,
                                style: TextStyle(
                                  color: colors.secondaryText,
                                  fontSize: 12.sp,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (item.installmentNumber != null) ...[
                              _buildDot(),
                              Text(
                                "${item.installmentNumber}/${item.totalInstallments}",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: accentColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                        // Account name on separate line if needed
                        if (showAccountName && item.account != null)
                          Padding(
                            padding: EdgeInsets.only(top: 2.h),
                            child: Text(
                              item.account!.name,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: colors.tertiaryText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),

                  SizedBox(width: 8.w),

                  // Amount and badge - FIXED: Use constrained width
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 100.w),
                        child: Text(
                          "${NumberFormat('#,##0.00', 'tr_TR').format(item.isPaid ? item.amount : item.remainingAmount)} ${item.currency}",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
                            color: item.isPaid
                                ? colors.secondaryText
                                : colors.primaryText,
                            decoration: item.isPaid
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          daysLabel,
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      width: 3.r,
      height: 3.r,
      decoration: BoxDecoration(
        color: colors.tertiaryText,
        shape: BoxShape.circle,
      ),
    );
  }
}