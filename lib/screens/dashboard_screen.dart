import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedPeriod = 'Today';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please login first')));
    }

    return Scaffold(
      //backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _salesStream(user.uid),
          builder: (context, salesSnapshot) {
            if (salesSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (salesSnapshot.hasError) {
              return _buildErrorState(salesSnapshot.error.toString());
            }

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _expenseStream(user.uid),
              builder: (context, expenseSnapshot) {
                if (expenseSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (expenseSnapshot.hasError) {
                  return _buildErrorState(expenseSnapshot.error.toString());
                }

                return _buildDashboard(
                  salesSnapshot: salesSnapshot,
                  expenseSnapshot: expenseSnapshot,
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // SALES STREAM
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> _salesStream(String uid) {
    final range = _getDateRange();

    return _firestore
        .collection('Shops')
        .doc(uid)
        .collection('sales')
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(range.start),
        )
        .where('createdAt', isLessThan: Timestamp.fromDate(range.end))
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ============================================================
  // EXPENSE STREAM
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> _expenseStream(String uid) {
    final range = _getDateRange();

    return _firestore
        .collection('Shops')
        .doc(uid)
        .collection('Expenses')
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(range.start),
        )
        .where('createdAt', isLessThan: Timestamp.fromDate(range.end))
        .snapshots();
  }

  // ============================================================
  // DATE RANGE
  // ============================================================

  _DateRange _getDateRange() {
    final now = DateTime.now();

    if (_selectedPeriod == 'Today') {
      final start = DateTime(now.year, now.month, now.day);

      final end = start.add(const Duration(days: 1));

      return _DateRange(start: start, end: end);
    }

    if (_selectedPeriod == 'This Week') {
      final today = DateTime(now.year, now.month, now.day);

      final monday = today.subtract(Duration(days: today.weekday - 1));

      final end = monday.add(const Duration(days: 7));

      return _DateRange(start: monday, end: end);
    }

    // This Month

    final start = DateTime(now.year, now.month, 1);

    final end = DateTime(now.year, now.month + 1, 1);

    return _DateRange(start: start, end: end);
  }

  // ============================================================
  // DASHBOARD
  // ============================================================

  Widget _buildDashboard({
    required AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> salesSnapshot,
    required AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> expenseSnapshot,
  }) {
    final salesDocs = salesSnapshot.data?.docs ?? [];

    final expenseDocs = expenseSnapshot.data?.docs ?? [];

    // ----------------------------------------------------------
    // SALES CALCULATION
    // ----------------------------------------------------------

    double totalSales = 0;

    for (final doc in salesDocs) {
      final data = doc.data();

      totalSales += _toDouble(data['total']);
    }

    // ----------------------------------------------------------
    // ORDERS
    // ----------------------------------------------------------

    final totalOrders = salesDocs.length;

    // ----------------------------------------------------------
    // EXPENSES
    // ----------------------------------------------------------

    double totalExpenses = 0;

    for (final doc in expenseDocs) {
      final data = doc.data();

      totalExpenses += _toDouble(data['amount'] ?? data['total'] ?? 0);
    }

    // ----------------------------------------------------------
    // NET PROFIT
    // ----------------------------------------------------------

    final netProfit = totalSales - totalExpenses;

    // ----------------------------------------------------------
    // CATEGORY DATA
    // ----------------------------------------------------------

    final categorySales = _calculateCategorySales(salesDocs);

    // ----------------------------------------------------------
    // PRODUCT DATA
    // ----------------------------------------------------------

    final productSales = _calculateProductSales(salesDocs);

    // ----------------------------------------------------------
    // CHART DATA
    // ----------------------------------------------------------

    final chartData = _calculateChartData(salesDocs);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600;

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 28 : 16,
              vertical: 20,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // =================================================
                    // HEADER
                    // =================================================
                    _buildHeader(isTablet: isTablet),

                    const SizedBox(height: 20),

                    // =================================================
                    // FILTER
                    // =================================================
                    _buildPeriodSelector(isTablet: isTablet),

                    const SizedBox(height: 20),

                    // =================================================
                    // SUMMARY CARDS
                    // =================================================
                    _buildSummaryCards(
                      totalSales: totalSales,
                      totalOrders: totalOrders,
                      totalExpenses: totalExpenses,
                      netProfit: netProfit,
                      isTablet: isTablet,
                    ),

                    const SizedBox(height: 24),

                    // =================================================
                    // SALES CHART
                    // =================================================
                    _buildSectionTitle(
                      title: 'Sales Overview',
                      subtitle: _selectedPeriod,
                    ),

                    const SizedBox(height: 12),

                    _buildSalesChart(chartData: chartData, isTablet: isTablet),

                    const SizedBox(height: 24),

                    // =================================================
                    // CATEGORY + PRODUCTS
                    // =================================================
                    if (isTablet)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildTopCategories(categorySales)),

                          const SizedBox(width: 16),

                          Expanded(child: _buildTopProducts(productSales)),
                        ],
                      )
                    else ...[
                      _buildTopCategories(categorySales),

                      const SizedBox(height: 20),

                      _buildTopProducts(productSales),
                    ],

                    const SizedBox(height: 24),

                    // =================================================
                    // RECENT SALES
                    // =================================================
                    _buildSectionTitle(
                      title: 'Recent Sales',
                      subtitle: '$totalOrders orders',
                    ),

                    const SizedBox(height: 12),

                    _buildRecentSales(salesDocs),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader({required bool isTablet}) {
    return Row(
      children: [
        Container(
          width: isTablet ? 56 : 48,
          height: isTablet ? 56 : 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.storefront_outlined, color: Colors.white),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'POS Dashboard',
                style: TextStyle(
                  fontSize: isTablet ? 26 : 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                _formatLongDate(DateTime.now()),
                style: TextStyle(
                  fontSize: isTablet ? 14 : 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.notifications_none_outlined),
        ),
      ],
    );
  }

  // ============================================================
  // PERIOD SELECTOR
  // ============================================================

  Widget _buildPeriodSelector({required bool isTablet}) {
    final periods = ['Today', 'This Week', 'This Month'];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: periods.map((period) {
          final selected = _selectedPeriod == period;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (_selectedPeriod == period) {
                  return;
                }

                setState(() {
                  _selectedPeriod = period;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  period,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                    color: selected ? Colors.white : Colors.grey.shade700,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ============================================================
  // SUMMARY CARDS
  // ============================================================

  Widget _buildSummaryCards({
    required double totalSales,
    required int totalOrders,
    required double totalExpenses,
    required double netProfit,
    required bool isTablet,
  }) {
    final cards = [
      _SummaryData(
        title: 'Total Sales',
        value: '${_formatMoney(totalSales)} MMK',
        icon: Icons.payments_outlined,
      ),

      _SummaryData(
        title: 'Orders',
        value: totalOrders.toString(),
        icon: Icons.receipt_long_outlined,
      ),

      _SummaryData(
        title: 'Expenses',
        value: '${_formatMoney(totalExpenses)} MMK',
        icon: Icons.account_balance_wallet_outlined,
      ),

      _SummaryData(
        title: 'Net Profit',
        value: '${_formatMoney(netProfit)} MMK',
        icon: Icons.trending_up_outlined,
      ),
    ];

    if (isTablet) {
      return Row(
        children: cards.map((card) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildSummaryCard(data: card),
            ),
          );
        }).toList(),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        //childAspectRatio: 1.55,
        mainAxisExtent: 120,
      ),
      itemBuilder: (context, index) {
        return _buildSummaryCard(data: cards[index]);
      },
    );
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _buildSummaryCard({required _SummaryData data}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              data.icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 5),
          //const Spacer(),
          Text(
            data.title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),

          const SizedBox(height: 2),

          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              data.value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle({required String title, required String subtitle}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),

        Text(
          subtitle,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  // ============================================================
  // SALES CHART
  // ============================================================

  Widget _buildSalesChart({
    required List<double> chartData,
    required bool isTablet,
  }) {
    final maxValue = chartData.isEmpty
        ? 0.0
        : chartData.reduce((a, b) => a > b ? a : b);

    final chartMax = maxValue <= 0 ? 100.0 : maxValue * 1.25;
    final safeHorizontalInterval = chartMax > 0 ? chartMax / 4 : 1.0;

    return Container(
      height: isTablet ? 300 : 250,
      padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: chartData.isEmpty
          ? const Center(child: Text('No sales data'))
          : LineChart(
              LineChartData(
                minY: 0,
                maxY: chartMax,

                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: safeHorizontalInterval,
                ),

                borderData: FlBorderData(show: false),

                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _formatChartMoney(value),
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey.shade600,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();

                        final labels = _chartLabels();

                        if (index < 0 || index >= labels.length) {
                          return const SizedBox();
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            labels[index],
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                lineBarsData: [
                  LineChartBarData(
                    spots: chartData.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value);
                    }).toList(),

                    isCurved: true,

                    barWidth: 3,

                    dotData: const FlDotData(show: true),

                    belowBarData: BarAreaData(show: true),
                  ),
                ],
              ),
            ),
    );
  }

  // ============================================================
  // TOP CATEGORIES
  // ============================================================

  Widget _buildTopCategories(Map<String, double> categorySales) {
    final entries = categorySales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final top = entries.take(5).toList();

    return _buildWhiteSection(
      title: 'Top Categories',
      child: top.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: Text('No category data')),
            )
          : Column(
              children: top.map((entry) {
                return _buildCategoryRow(
                  name: entry.key,
                  amount: entry.value,
                  total: entries.first.value,
                );
              }).toList(),
            ),
    );
  }

  // ============================================================
  // CATEGORY ROW
  // ============================================================

  Widget _buildCategoryRow({
    required String name,
    required double amount,
    required double total,
  }) {
    final progress = total <= 0 ? 0.0 : (amount / total).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),

              Text(
                '${_formatMoney(amount)} MMK',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),

          const SizedBox(height: 7),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(value: progress, minHeight: 7),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TOP PRODUCTS
  // ============================================================

  Widget _buildTopProducts(Map<String, int> productSales) {
    final entries = productSales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final top = entries.take(5).toList();

    return _buildWhiteSection(
      title: 'Top Products',
      child: top.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: Text('No product data')),
            )
          : Column(
              children: top.asMap().entries.map((entry) {
                final index = entry.key;

                final product = entry.value;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          product.key,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),

                      Text(
                        '${product.value} sold',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  // ============================================================
  // WHITE SECTION
  // ============================================================

  Widget _buildWhiteSection({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          child,
        ],
      ),
    );
  }

  // ============================================================
  // RECENT SALES
  // ============================================================

  Widget _buildRecentSales(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> salesDocs,
  ) {
    final docs = salesDocs.take(5).toList();

    if (docs.isEmpty) {
      return _buildWhiteSection(
        title: 'Recent Sales',
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: Text('No sales yet')),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: docs.asMap().entries.map((entry) {
          final index = entry.key;

          final data = entry.value.data();

          final invoiceNo = data['invoiceNo'] ?? 'Unknown Invoice';

          final total = _toDouble(data['total']);

          final payment = data['paymentMethod'] ?? 'Unknown';

          final createdAt = _getDate(data['createdAt']);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.receipt_long_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            invoiceNo.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            '$payment • ${_formatTime(createdAt)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Text(
                      '${_formatMoney(total)} MMK',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              if (index < docs.length - 1)
                Divider(height: 1, color: Colors.grey.shade200),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ============================================================
  // CATEGORY CALCULATION
  // ============================================================

  Map<String, double> _calculateCategorySales(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final result = <String, double>{};

    for (final doc in docs) {
      final data = doc.data();

      final items = data['items'];

      if (items is! List) {
        continue;
      }

      for (final item in items) {
        if (item is! Map<String, dynamic>) {
          continue;
        }

        final category =
            item['category'] ?? item['categoryName'] ?? 'Uncategorized';

        final total = _toDouble(item['total']);

        result[category.toString()] =
            (result[category.toString()] ?? 0) + total;
      }
    }

    return result;
  }

  // ============================================================
  // PRODUCT CALCULATION
  // ============================================================

  Map<String, int> _calculateProductSales(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final result = <String, int>{};

    for (final doc in docs) {
      final data = doc.data();

      final items = data['items'];

      if (items is! List) {
        continue;
      }

      for (final item in items) {
        if (item is! Map<String, dynamic>) {
          continue;
        }

        final name = item['name'] ?? 'Unknown Product';

        final quantity = _toDouble(item['quantity']).toInt();

        result[name.toString()] = (result[name.toString()] ?? 0) + quantity;
      }
    }

    return result;
  }

  // ============================================================
  // CHART CALCULATION
  // ============================================================

  List<double> _calculateChartData(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    if (_selectedPeriod == 'Today') {
      return _calculateHourlySales(docs);
    }

    if (_selectedPeriod == 'This Week') {
      return _calculateWeeklySales(docs);
    }

    return _calculateMonthlySales(docs);
  }

  // ============================================================
  // HOURLY SALES
  // ============================================================

  List<double> _calculateHourlySales(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final result = List<double>.filled(24, 0);

    for (final doc in docs) {
      final data = doc.data();

      final date = _getDate(data['createdAt']);

      final hour = date.hour;

      result[hour] += _toDouble(data['total']);
    }

    // Show every 2 hours
    final filtered = <double>[];

    for (int i = 0; i < 24; i += 2) {
      filtered.add(result[i] + result[i + 1]);
    }

    return filtered;
  }

  // ============================================================
  // WEEKLY SALES
  // ============================================================

  List<double> _calculateWeeklySales(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final result = List<double>.filled(7, 0);

    for (final doc in docs) {
      final data = doc.data();

      final date = _getDate(data['createdAt']);

      final index = date.weekday - 1;

      if (index >= 0 && index < 7) {
        result[index] += _toDouble(data['total']);
      }
    }

    return result;
  }

  // ============================================================
  // MONTHLY SALES
  // ============================================================

  List<double> _calculateMonthlySales(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final now = DateTime.now();

    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    final result = List<double>.filled(daysInMonth, 0);

    for (final doc in docs) {
      final data = doc.data();

      final date = _getDate(data['createdAt']);

      final index = date.day - 1;

      if (index >= 0 && index < daysInMonth) {
        result[index] += _toDouble(data['total']);
      }
    }

    // Group into 4 weeks
    final grouped = <double>[];

    for (int i = 0; i < daysInMonth; i += 7) {
      double total = 0;

      final end = (i + 7) > daysInMonth ? daysInMonth : i + 7;

      for (int j = i; j < end; j++) {
        total += result[j];
      }

      grouped.add(total);
    }

    return grouped;
  }

  // ============================================================
  // CHART LABELS
  // ============================================================

  List<String> _chartLabels() {
    if (_selectedPeriod == 'Today') {
      return [
        '12AM',
        '2AM',
        '4AM',
        '6AM',
        '8AM',
        '10AM',
        '12PM',
        '2PM',
        '4PM',
        '6PM',
        '8PM',
        '10PM',
      ];
    }

    if (_selectedPeriod == 'This Week') {
      return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    }

    final now = DateTime.now();

    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    final labels = <String>[];

    int week = 1;

    for (int i = 1; i <= daysInMonth; i += 7) {
      labels.add('Week $week');

      week++;
    }

    return labels;
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.red),

            const SizedBox(height: 12),

            const Text(
              'Failed to load dashboard',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  DateTime _getDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.now();
  }

  String _formatMoney(double value) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',');
  }

  String _formatChartMoney(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }

    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }

    return value.toStringAsFixed(0);
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');

    final minute = date.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  String _formatLongDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} '
        '${date.day}, '
        '${date.year}';
  }
}

// ============================================================
// DATE RANGE MODEL
// ============================================================

class _DateRange {
  final DateTime start;
  final DateTime end;

  const _DateRange({required this.start, required this.end});
}

// ============================================================
// SUMMARY MODEL
// ============================================================

class _SummaryData {
  final String title;
  final String value;
  final IconData icon;

  const _SummaryData({
    required this.title,
    required this.value,
    required this.icon,
  });
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// enum FilterType { daily, monthly, yearly }

// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   FilterType _selectedFilter = FilterType.daily;
//   DateTime _selectedDate = DateTime.now();

//   DateTimeRange _getDateRange() {
//     final now = _selectedDate;
//     if (_selectedFilter == FilterType.daily) {
//       final start = DateTime(now.year, now.month, now.day);
//       final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
//       return DateTimeRange(start: start, end: end);
//     } else if (_selectedFilter == FilterType.monthly) {
//       final start = DateTime(now.year, now.month, 1);
//       final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
//       return DateTimeRange(start: start, end: end);
//     } else {
//       final start = DateTime(now.year, 1, 1);
//       final end = DateTime(now.year, 12, 31, 23, 59, 59);
//       return DateTimeRange(start: start, end: end);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     final range = _getDateRange();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Dashboard & Reports'),
//         backgroundColor: const Color(0xFF4CAF50),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Filter Toggle Buttons (DAILY, MONTHLY, YEARLY)
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: FilterType.values.map((filter) {
//                 final isSelected = _selectedFilter == filter;
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 4.0),
//                   child: ChoiceChip(
//                     label: Text(
//                       filter.name.toUpperCase(),
//                       style: TextStyle(
//                         color: isSelected ? Colors.white : Colors.black87,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     selected: isSelected,
//                     selectedColor: const Color(0xFF4CAF50),
//                     onSelected: (bool selected) {
//                       if (selected) {
//                         setState(() {
//                           _selectedFilter = filter;
//                         });
//                       }
//                     },
//                   ),
//                 );
//               }).toList(),
//             ),

//             const SizedBox(height: 12),

//             // Date Picker Banner
//             InkWell(
//               onTap: () async {
//                 final picked = await showDatePicker(
//                   context: context,
//                   initialDate: _selectedDate,
//                   firstDate: DateTime(2020),
//                   lastDate: DateTime.now(),
//                 );
//                 if (picked != null) {
//                   setState(() => _selectedDate = picked);
//                 }
//               },
//               child: Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade200,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Icon(Icons.calendar_month, color: Colors.green),
//                     const SizedBox(width: 8),
//                     Text(
//                       _selectedFilter == FilterType.daily
//                           ? 'Date: ${_selectedDate.toString().split(' ')[0]}'
//                           : _selectedFilter == FilterType.monthly
//                           ? 'Month: ${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}'
//                           : 'Year: ${_selectedDate.year}',
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 20),

//             // Stream Builder
//             StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('Shops')
//                   .doc(uid)
//                   .collection('sales')
//                   .where('createdAt', isGreaterThanOrEqualTo: range.start)
//                   .where('createdAt', isLessThanOrEqualTo: range.end)
//                   .snapshots(),
//               builder: (context, salesSnapshot) {
//                 return StreamBuilder<QuerySnapshot>(
//                   stream: FirebaseFirestore.instance
//                       .collection('Shops')
//                       .doc(uid)
//                       .collection('Expenses')
//                       .where('date', isGreaterThanOrEqualTo: range.start)
//                       .where('date', isLessThanOrEqualTo: range.end)
//                       .snapshots(),
//                   builder: (context, expenseSnapshot) {
//                     if (salesSnapshot.connectionState ==
//                             ConnectionState.waiting ||
//                         expenseSnapshot.connectionState ==
//                             ConnectionState.waiting) {
//                       return const Center(child: CircularProgressIndicator());
//                     }

//                     double totalRevenue = 0;
//                     Map<String, double> salesCategoryMap = {};

//                     // 🟢 Sales & Category တွက်ချက်ခြင်း
//                     if (salesSnapshot.hasData) {
//                       for (var doc in salesSnapshot.data!.docs) {
//                         final data = doc.data() as Map<String, dynamic>;
//                         totalRevenue += (data['total'] ?? 0).toDouble();

//                         // sales doc ထဲက items/products array သို့မဟုတ် map များကို စစ်ဆေးခြင်း
//                         if (data['items'] != null && data['items'] is List) {
//                           for (var item in data['items']) {
//                             String catName =
//                                 item['category'] ??
//                                 item['categoryName'] ??
//                                 'Uncategorized';
//                             double itemTotal =
//                                 (item['total'] ??
//                                         ((item['price'] ?? 0) *
//                                             (item['quantity'] ?? 1)))
//                                     .toDouble();

//                             salesCategoryMap[catName] =
//                                 (salesCategoryMap[catName] ?? 0) + itemTotal;
//                           }
//                         } else if (data['category'] != null) {
//                           // အကယ်၍ sales doc တွင် တိုက်ရိုက် category ပါပါက
//                           String catName = data['category'];
//                           double amount = (data['total'] ?? 0).toDouble();
//                           salesCategoryMap[catName] =
//                               (salesCategoryMap[catName] ?? 0) + amount;
//                         }
//                       }
//                     }

//                     // 📊 ရောင်းအားအများဆုံး Category များကို စီခြင်း (Descending Order)
//                     var sortedSalesCategories =
//                         salesCategoryMap.entries.toList()
//                           ..sort((a, b) => b.value.compareTo(a.value));

//                     // 🔴 Expense & Category တွက်ချက်ခြင်း
//                     double totalExpenses = 0;
//                     Map<String, double> expenseCategoryMap = {};

//                     if (expenseSnapshot.hasData) {
//                       for (var doc in expenseSnapshot.data!.docs) {
//                         final data = doc.data() as Map<String, dynamic>;
//                         double amt = (data['amount'] ?? 0).toDouble();
//                         totalExpenses += amt;

//                         String catName =
//                             data['category'] ??
//                             data['categoryName'] ??
//                             'အထွေထွေ (General)';
//                         expenseCategoryMap[catName] =
//                             (expenseCategoryMap[catName] ?? 0) + amt;
//                       }
//                     }

//                     // 📊 ထွက်ငွေအများဆုံး Category များကို စီခြင်း
//                     var sortedExpenseCategories =
//                         expenseCategoryMap.entries.toList()
//                           ..sort((a, b) => b.value.compareTo(a.value));

//                     double netProfit = totalRevenue - totalExpenses;

//                     return Column(
//                       children: [
//                         // 1. ဝင်ငွေ Card
//                         _buildSummaryCard(
//                           title: 'ဝင်ငွေ စုစုပေါင်း (Income)',
//                           amount: totalRevenue,
//                           color: Colors.green,
//                           icon: Icons.arrow_downward,
//                         ),

//                         // 🟢 ဝင်ငွေ Category အလိုက် ရောင်းအားအကောင်းဆုံးစာရင်း
//                         if (sortedSalesCategories.isNotEmpty)
//                           _buildCategoryBreakdown(
//                             title: 'Category အလိုက် ရောင်းအားအကောင်းဆုံးများ',
//                             categories: sortedSalesCategories,
//                             accentColor: Colors.green,
//                           ),

//                         const SizedBox(height: 16),

//                         // 2. ထွက်ငွေ Card
//                         _buildSummaryCard(
//                           title: 'ထွက်ငွေ စုစုပေါင်း (Expenses)',
//                           amount: totalExpenses,
//                           color: Colors.red,
//                           icon: Icons.arrow_upward,
//                         ),

//                         // 🔴 ထွက်ငွေ Category အလိုက် စာရင်း
//                         if (sortedExpenseCategories.isNotEmpty)
//                           _buildCategoryBreakdown(
//                             title: 'Category အလိုက် ကုန်ကျစရိတ်များ',
//                             categories: sortedExpenseCategories,
//                             accentColor: Colors.red,
//                           ),

//                         const SizedBox(height: 16),

//                         // 3. အမြတ် Card
//                         _buildSummaryCard(
//                           title: netProfit >= 0
//                               ? 'အမြတ် စုစုပေါင်း (Net Profit)'
//                               : 'အရှုံး စုစုပေါင်း (Net Loss)',
//                           amount: netProfit,
//                           color: netProfit >= 0
//                               ? const Color(0xFF1976D2)
//                               : Colors.orange.shade800,
//                           icon: netProfit >= 0
//                               ? Icons.trending_up
//                               : Icons.trending_down,
//                         ),
//                       ],
//                     );
//                   },
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // စုစုပေါင်း Card များအတွက် Widget
//   Widget _buildSummaryCard({
//     required String title,
//     required double amount,
//     required Color color,
//     required IconData icon,
//   }) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             backgroundColor: color,
//             child: Icon(icon, color: Colors.white),
//           ),
//           const SizedBox(width: 16),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey.shade800,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 '${amount.toInt()} Ks',
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   color: color,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // Category အလိုက် ခွဲခြားပြသသည့် Widget
//   Widget _buildCategoryBreakdown({
//     required String title,
//     required List<MapEntry<String, double>> categories,
//     required Color accentColor,
//   }) {
//     return Container(
//       margin: const EdgeInsets.only(top: 8),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           ),
//         ],
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
//             child: Text(
//               title,
//               style: TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.grey.shade700,
//               ),
//             ),
//           ),
//           ...categories.map((entry) {
//             return Padding(
//               padding: const EdgeInsets.symmetric(
//                 vertical: 4.0,
//                 horizontal: 4.0,
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(Icons.label_outline, size: 16, color: accentColor),
//                       const SizedBox(width: 6),
//                       Text(
//                         entry.key,
//                         style: const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                   Text(
//                     '${entry.value.toInt()} Ks',
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                       color: accentColor,
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }),
//         ],
//       ),
//     );
//   }
// }
