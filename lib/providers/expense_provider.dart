import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/expense_model.dart';

class ExpenseProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<ExpenseModel> _expenses = [];
  bool _isLoading = false;

  List<ExpenseModel> get expenses => _expenses;
  bool get isLoading => _isLoading;

  String? get currentUid => _auth.currentUser?.uid;

  // 🟢 1. Expenses များကို Real-time Stream ဖြင့် ယူခြင်း
  void fetchExpenses() {
    if (currentUid == null) return;

    _isLoading = true;
    notifyListeners();

    _firestore
        .collection('Shops')
        .doc(currentUid)
        .collection('Expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            _expenses = snapshot.docs
                .map((doc) => ExpenseModel.fromMap(doc.data(), doc.id))
                .toList();
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            debugPrint('Error fetching expenses: $error');
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  // 🟢 2. Expense အသစ် ထည့်သွင်းခြင်း
  Future<bool> addExpense({
    required String title,
    required double amount,
    required String category,
    required DateTime date,
    required String note,
  }) async {
    if (currentUid == null) return false;

    try {
      final docRef = _firestore
          .collection('Shops')
          .doc(currentUid)
          .collection('Expenses')
          .doc();

      final expense = ExpenseModel(
        id: docRef.id,
        title: title,
        amount: amount,
        category: category,
        date: date,
        note: note,
      );

      await docRef.set(expense.toMap());
      return true;
    } catch (e) {
      debugPrint('Error adding expense: $e');
      return false;
    }
  }

  // 🔵 3. Expense ပြင်ဆင်ခြင်း (Update Expense)
  Future<bool> updateExpense({
    required String id,
    required String title,
    required double amount,
    required String category,
    required DateTime date,
    required String note,
  }) async {
    if (currentUid == null) return false;

    try {
      await _firestore
          .collection('Shops')
          .doc(currentUid)
          .collection('Expenses')
          .doc(id)
          .update({
            'title': title,
            'amount': amount,
            'category': category,
            'date': Timestamp.fromDate(date),
            'note': note,
          });
      return true;
    } catch (e) {
      debugPrint('Error updating expense: $e');
      return false;
    }
  }

  // 🔴 4. Expense ဖျက်ခြင်း (Delete Expense)
  Future<bool> deleteExpense(String id) async {
    if (currentUid == null) return false;

    try {
      await _firestore
          .collection('Shops')
          .doc(currentUid)
          .collection('Expenses')
          .doc(id)
          .delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting expense: $e');
      return false;
    }
  }
}
