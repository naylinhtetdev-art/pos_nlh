import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pos_nlh/models/item_model.dart';

class ItemProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<ItemModel> _items = [];
  bool _isLoading = false;
  String? _currentShopName;

  List<ItemModel> get items => _items;
  bool get isLoading => _isLoading;
  String? get currentShopName => _currentShopName;

  Future<String?> _getShopName() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    if (_currentShopName != null) return _currentShopName;

    final userDoc = await _firestore.collectionGroup('items').get();

    return _currentShopName;
  }

  String? get currentUid => _auth.currentUser?.uid;

  // 1. Items များကို Firestore မှ Fetch လုပ်ခြင်း (Real-time Stream)
  void fetchItems() {
    if (currentUid == null) return;

    _isLoading = true;
    notifyListeners();

    _firestore
        .collection('Shops')
        .doc(currentUid)
        .collection('items')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          _items = snapshot.docs
              .map((doc) => ItemModel.fromMap(doc.id, doc.data()))
              .toList();
          _isLoading = false;
          notifyListeners();
        });
  }

  // 2. Item အသစ် ထည့်သွင်းခြင်း (Name, Price, Stock)
  Future<bool> addItem({
    required String name,
    required double price,
    required int stock,
    required String category,
  }) async {
    if (currentUid == null) return false;

    try {
      final newItem = ItemModel(
        id: '',
        name: name,
        price: price,
        stock: stock,
        category: category,
      );

      await _firestore
          .collection('Shops')
          .doc(currentUid)
          .collection('items')
          .add(newItem.toMap());

      return true;
    } catch (e) {
      debugPrint('Error adding item: $e');
      return false;
    }
  }
}
