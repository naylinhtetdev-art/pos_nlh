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

  // Selected Filter ပေါ်မူတည်ပြီး Date Range တွက်ချက်ခြင်း
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
            // Filter Toggle Buttons (Daily, Monthly, Yearly)
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

            // 🟢 Sales Stream (createdAt သို့မဟုတ် timestamp field ပေါ်မူတည်၍ Filter လုပ်ခြင်း)
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Shops')
                  .doc(uid)
                  .collection(
                    'sales',
                  ) // Collection နာမည် 'sales' (အသေး) သို့ ပြင်ထားပါသည်
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

                    // 🟢 ဝင်ငွေ စုစုပေါင်း တွက်ချက်ခြင်း (Firestore ထဲက 'total' field ကို ယူသုံးထားပါသည်)
                    double totalRevenue = 0;
                    if (salesSnapshot.hasData) {
                      for (var doc in salesSnapshot.data!.docs) {
                        final data = doc.data() as Map<String, dynamic>;
                        totalRevenue += (data['total'] ?? 0)
                            .toDouble(); // 'total' field
                      }
                    }

                    // 🟢 ထွက်ငွေ စုစုပေါင်း တွက်ချက်ခြင်း
                    double totalExpenses = 0;
                    if (expenseSnapshot.hasData) {
                      for (var doc in expenseSnapshot.data!.docs) {
                        final data = doc.data() as Map<String, dynamic>;
                        totalExpenses += (data['amount'] ?? 0).toDouble();
                      }
                    }

                    // 🟢 အမြတ် တွက်ချက်ခြင်း (Net Profit / Loss)
                    double netProfit = totalRevenue - totalExpenses;

                    return Column(
                      children: [
                        // Revenue Card
                        _buildSummaryCard(
                          title: 'ဝင်ငွေ စုစုပေါင်း (Income)',
                          amount: totalRevenue,
                          color: Colors.green,
                          icon: Icons.arrow_downward,
                        ),
                        const SizedBox(height: 12),

                        // Expense Card
                        _buildSummaryCard(
                          title: 'ထွက်ငွေ စုစုပေါင်း (Expenses)',
                          amount: totalExpenses,
                          color: Colors.red,
                          icon: Icons.arrow_upward,
                        ),
                        const SizedBox(height: 12),

                        // Net Profit Card
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
}
