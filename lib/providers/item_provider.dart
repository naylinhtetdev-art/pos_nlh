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

  String? get currentUid => _auth.currentUser?.uid;

  // 0. Shop Name ယူရန် Function (ပြင်ဆင်ထားပါသည်)
  Future<String?> fetchShopName() async {
    if (currentUid == null) return null;
    if (_currentShopName != null) return _currentShopName;

    try {
      final doc = await _firestore.collection('Shops').doc(currentUid).get();
      if (doc.exists) {
        _currentShopName = doc.data()?['shopName'] ?? 'POS Shop';
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching shop name: $e');
    }
    return _currentShopName;
  }

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
        .listen(
          (snapshot) {
            _items = snapshot.docs
                .map((doc) => ItemModel.fromMap(doc.id, doc.data()))
                .toList();
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            debugPrint('Error fetching items: $error');
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  // 2. Item အသစ် ထည့်သွင်းခြင်း (Name, Price, Stock, Category)
  Future<bool> addItem({
    required String name,
    required double price,
    required int stock,
    required String category,
  }) async {
    if (currentUid == null) return false;

    try {
      final newItemMap = {
        'name': name,
        'price': price,
        'stock': stock,
        'category': category,
        'createdAt':
            FieldValue.serverTimestamp(), // ဖန်တီးခဲ့သည့် အချိန်ထည့်ရန်
      };

      await _firestore
          .collection('Shops')
          .doc(currentUid)
          .collection('items')
          .add(newItemMap);

      return true;
    } catch (e) {
      debugPrint('Error adding item: $e');
      return false;
    }
  }

  // 🟢 3. Item ပြင်ဆင်ခြင်း (Update Item) - အသစ်ထည့်သွင်းထားသည်
  Future<bool> updateItem({
    required String id,
    required String name,
    required double price,
    required int stock,
    required String category,
  }) async {
    if (currentUid == null) return false;

    try {
      await _firestore
          .collection('Shops')
          .doc(currentUid)
          .collection('items')
          .doc(id)
          .update({
            'name': name,
            'price': price,
            'stock': stock,
            'category': category,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      return true;
    } catch (e) {
      debugPrint('Error updating item: $e');
      return false;
    }
  }

  // 🔴 4. Item ဖျက်ခြင်း (Delete Item) - အသစ်ထည့်သွင်းထားသည်
  Future<bool> deleteItem(String id) async {
    if (currentUid == null) return false;

    try {
      await _firestore
          .collection('Shops')
          .doc(currentUid)
          .collection('items')
          .doc(id)
          .delete();

      return true;
    } catch (e) {
      debugPrint('Error deleting item: $e');
      return false;
    }
  }
}
