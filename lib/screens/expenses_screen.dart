import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense_model.dart';
import '../providers/expense_provider.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  @override
  void initState() {
    super.initState();
    // Screen စတက်သည်နှင့် Expense List များကို စတင် ယူပါမည်
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().fetchExpenses();
    });
  }

  // 🟢 Expense အသစ်ထည့်ရန် သို့မဟုတ် Update ပြုလုပ်ရန် BottomSheet
  void _showExpenseFormModal(
    BuildContext context, {
    ExpenseModel? existingExpense,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ExpenseFormWidget(existingExpense: existingExpense),
        );
      },
    );
  }

  // 🔴 Delete လုပ်ရန် သေချာ/မသေချာ မေးမည့် Dialog
  void _confirmDelete(BuildContext context, String id, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Expense'),
        content: Text('"$title" စာရင်းကို ဖျက်ရန် သေချာပါသလား?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context
                  .read<ExpenseProvider>()
                  .deleteExpense(id);
              if (mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Expense deleted successfully!'),
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses / ထွက်ငွေ စာရင်း'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showExpenseFormModal(context),
        backgroundColor: const Color(0xFF4CAF50),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Expense', style: TextStyle(color: Colors.white)),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.expenses.isEmpty) {
            return const Center(
              child: Text(
                'No expense record found.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.expenses.length,
            padding: const EdgeInsets.only(bottom: 80),
            itemBuilder: (context, index) {
              final expense = provider.expenses[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  onTap: () =>
                      _showExpenseFormModal(context, existingExpense: expense),
                  leading: CircleAvatar(
                    backgroundColor: Colors.red.shade100,
                    child: const Icon(Icons.money_off, color: Colors.red),
                  ),
                  title: Text(
                    expense.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${expense.category} • ${expense.date.toString().split(' ')[0]}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '-${expense.amount.toInt()} Ks',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: () =>
                            _confirmDelete(context, expense.id, expense.title),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ==============================================================
// 🟢 Add (သို့) Edit ပြုလုပ်ရန် သီးသန့် Form Widget
// ==============================================================
class ExpenseFormWidget extends StatefulWidget {
  final ExpenseModel? existingExpense;

  const ExpenseFormWidget({super.key, this.existingExpense});

  @override
  State<ExpenseFormWidget> createState() => _ExpenseFormWidgetState();
}

class _ExpenseFormWidgetState extends State<ExpenseFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _noteController;

  late String _selectedCategory;
  late DateTime _selectedDate;
  bool _isLoading = false;

  final List<String> _categories = [
    'Raw Material',
    'Utilities (Electric/Water)',
    'Salary',
    'Rent',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final expense = widget.existingExpense;

    _titleController = TextEditingController(text: expense?.title ?? '');
    _amountController = TextEditingController(
      text: expense != null ? expense.amount.toInt().toString() : '',
    );
    _noteController = TextEditingController(text: expense?.note ?? '');
    _selectedCategory = expense?.category ?? _categories.first;
    _selectedDate = expense?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final title = _titleController.text.trim();
    final amount = double.parse(_amountController.text.trim());
    final note = _noteController.text.trim();

    bool success;
    if (widget.existingExpense == null) {
      // 🟢 Add New Expense
      success = await context.read<ExpenseProvider>().addExpense(
        title: title,
        amount: amount,
        category: _selectedCategory,
        date: _selectedDate,
        note: note,
      );
    } else {
      // 🔵 Update Existing Expense
      success = await context.read<ExpenseProvider>().updateExpense(
        id: widget.existingExpense!.id,
        title: title,
        amount: amount,
        category: _selectedCategory,
        date: _selectedDate,
        note: note,
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.existingExpense == null
                ? 'Expense added successfully!'
                : 'Expense updated successfully!',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.existingExpense != null;

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditMode ? 'Update Expense' : 'Add New Expense',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title / Item Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Enter title' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount (MMK / Ks)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter amount' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedCategory = val);
                  }
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Date: ${_selectedDate.toString().split(' ')[0]}',
                    style: const TextStyle(fontSize: 15),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Select Date'),
                    onPressed: () async {
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
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Note (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                  ),
                  onPressed: _isLoading ? null : _saveExpense,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isEditMode ? 'Update Expense' : 'Save Expense',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
