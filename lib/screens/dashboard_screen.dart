import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum FilterType { daily, monthly, yearly }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  FilterType _selectedFilter = FilterType.daily;
  DateTime _selectedDate = DateTime.now();

  DateTimeRange _getDateRange() {
    final now = _selectedDate;
    if (_selectedFilter == FilterType.daily) {
      final start = DateTime(now.year, now.month, now.day);
      final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
      return DateTimeRange(start: start, end: end);
    } else if (_selectedFilter == FilterType.monthly) {
      final start = DateTime(now.year, now.month, 1);
      final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      return DateTimeRange(start: start, end: end);
    } else {
      final start = DateTime(now.year, 1, 1);
      final end = DateTime(now.year, 12, 31, 23, 59, 59);
      return DateTimeRange(start: start, end: end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final range = _getDateRange();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard & Reports'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Toggle Buttons (DAILY, MONTHLY, YEARLY)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: FilterType.values.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(
                      filter.name.toUpperCase(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF4CAF50),
                    onSelected: (bool selected) {
                      if (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            // Date Picker Banner
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_month, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      _selectedFilter == FilterType.daily
                          ? 'Date: ${_selectedDate.toString().split(' ')[0]}'
                          : _selectedFilter == FilterType.monthly
                          ? 'Month: ${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}'
                          : 'Year: ${_selectedDate.year}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Stream Builder
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Shops')
                  .doc(uid)
                  .collection('sales')
                  .where('createdAt', isGreaterThanOrEqualTo: range.start)
                  .where('createdAt', isLessThanOrEqualTo: range.end)
                  .snapshots(),
              builder: (context, salesSnapshot) {
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Shops')
                      .doc(uid)
                      .collection('Expenses')
                      .where('date', isGreaterThanOrEqualTo: range.start)
                      .where('date', isLessThanOrEqualTo: range.end)
                      .snapshots(),
                  builder: (context, expenseSnapshot) {
                    if (salesSnapshot.connectionState ==
                            ConnectionState.waiting ||
                        expenseSnapshot.connectionState ==
                            ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    double totalRevenue = 0;
                    Map<String, double> salesCategoryMap = {};

                    // 🟢 Sales & Category တွက်ချက်ခြင်း
                    if (salesSnapshot.hasData) {
                      for (var doc in salesSnapshot.data!.docs) {
                        final data = doc.data() as Map<String, dynamic>;
                        totalRevenue += (data['total'] ?? 0).toDouble();

                        // sales doc ထဲက items/products array သို့မဟုတ် map များကို စစ်ဆေးခြင်း
                        if (data['items'] != null && data['items'] is List) {
                          for (var item in data['items']) {
                            String catName =
                                item['category'] ??
                                item['categoryName'] ??
                                'Uncategorized';
                            double itemTotal =
                                (item['total'] ??
                                        ((item['price'] ?? 0) *
                                            (item['quantity'] ?? 1)))
                                    .toDouble();

                            salesCategoryMap[catName] =
                                (salesCategoryMap[catName] ?? 0) + itemTotal;
                          }
                        } else if (data['category'] != null) {
                          // အကယ်၍ sales doc တွင် တိုက်ရိုက် category ပါပါက
                          String catName = data['category'];
                          double amount = (data['total'] ?? 0).toDouble();
                          salesCategoryMap[catName] =
                              (salesCategoryMap[catName] ?? 0) + amount;
                        }
                      }
                    }

                    // 📊 ရောင်းအားအများဆုံး Category များကို စီခြင်း (Descending Order)
                    var sortedSalesCategories =
                        salesCategoryMap.entries.toList()
                          ..sort((a, b) => b.value.compareTo(a.value));

                    // 🔴 Expense & Category တွက်ချက်ခြင်း
                    double totalExpenses = 0;
                    Map<String, double> expenseCategoryMap = {};

                    if (expenseSnapshot.hasData) {
                      for (var doc in expenseSnapshot.data!.docs) {
                        final data = doc.data() as Map<String, dynamic>;
                        double amt = (data['amount'] ?? 0).toDouble();
                        totalExpenses += amt;

                        String catName =
                            data['category'] ??
                            data['categoryName'] ??
                            'အထွေထွေ (General)';
                        expenseCategoryMap[catName] =
                            (expenseCategoryMap[catName] ?? 0) + amt;
                      }
                    }

                    // 📊 ထွက်ငွေအများဆုံး Category များကို စီခြင်း
                    var sortedExpenseCategories =
                        expenseCategoryMap.entries.toList()
                          ..sort((a, b) => b.value.compareTo(a.value));

                    double netProfit = totalRevenue - totalExpenses;

                    return Column(
                      children: [
                        // 1. ဝင်ငွေ Card
                        _buildSummaryCard(
                          title: 'ဝင်ငွေ စုစုပေါင်း (Income)',
                          amount: totalRevenue,
                          color: Colors.green,
                          icon: Icons.arrow_downward,
                        ),

                        // 🟢 ဝင်ငွေ Category အလိုက် ရောင်းအားအကောင်းဆုံးစာရင်း
                        if (sortedSalesCategories.isNotEmpty)
                          _buildCategoryBreakdown(
                            title: 'Category အလိုက် ရောင်းအားအကောင်းဆုံးများ',
                            categories: sortedSalesCategories,
                            accentColor: Colors.green,
                          ),

                        const SizedBox(height: 16),

                        // 2. ထွက်ငွေ Card
                        _buildSummaryCard(
                          title: 'ထွက်ငွေ စုစုပေါင်း (Expenses)',
                          amount: totalExpenses,
                          color: Colors.red,
                          icon: Icons.arrow_upward,
                        ),

                        // 🔴 ထွက်ငွေ Category အလိုက် စာရင်း
                        if (sortedExpenseCategories.isNotEmpty)
                          _buildCategoryBreakdown(
                            title: 'Category အလိုက် ကုန်ကျစရိတ်များ',
                            categories: sortedExpenseCategories,
                            accentColor: Colors.red,
                          ),

                        const SizedBox(height: 16),

                        // 3. အမြတ် Card
                        _buildSummaryCard(
                          title: netProfit >= 0
                              ? 'အမြတ် စုစုပေါင်း (Net Profit)'
                              : 'အရှုံး စုစုပေါင်း (Net Loss)',
                          amount: netProfit,
                          color: netProfit >= 0
                              ? const Color(0xFF1976D2)
                              : Colors.orange.shade800,
                          icon: netProfit >= 0
                              ? Icons.trending_up
                              : Icons.trending_down,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // စုစုပေါင်း Card များအတွက် Widget
  Widget _buildSummaryCard({
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${amount.toInt()} Ks',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Category အလိုက် ခွဲခြားပြသသည့် Widget
  Widget _buildCategoryBreakdown({
    required String title,
    required List<MapEntry<String, double>> categories,
    required Color accentColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          ...categories.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 4.0,
                horizontal: 4.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.label_outline, size: 16, color: accentColor),
                      const SizedBox(width: 6),
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${entry.value.toInt()} Ks',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
