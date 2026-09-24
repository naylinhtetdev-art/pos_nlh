import 'package:flutter/material.dart';
import 'package:pos_nlh/models/cart_item_model.dart';
import 'package:pos_nlh/models/item_model.dart';

class CartItem {
  final String id;
  final String name;
  final double price;
  int quantity;
  final String categoryName;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
    required this.categoryName,
  });
}

class CartProvider with ChangeNotifier {
  final List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;

  final List<CartItemModel> _items = [];
  List<CartItemModel> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;
  int get totalQuantity =>
      _cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0, (sum, item) => sum + item.total);

  // Cart ထဲ Item ထည့်ရန်
  void addItem(String id, String name, double price, String categoryName) {
    int index = _cartItems.indexWhere((item) => item.id == id);
    if (index >= 0) {
      _cartItems[index].quantity++;
    } else {
      _cartItems.add(
        CartItem(id: id, name: name, price: price, categoryName: categoryName),
      );
    }
    notifyListeners();
  }

  bool addProduct(ItemModel product) {
    if (product.stock <= 0) return false;

    final index = _items.indexWhere((item) => item.product.id == product.id);

    if (index != -1) {
      // ရှိပြီးသား item ဖြစ်ပါက Stock မကျော်မှ Quantity တိုးမည်
      if (_items[index].quantity < product.stock) {
        _items[index].quantity++;
        notifyListeners();
        return true;
      } else {
        return false; // Stock ပြည့်နေပါက false Return ပြန်မည်
      }
    } else {
      // Item အသစ်ထည့်မည်
      _items.add(CartItemModel(product: product, quantity: 1));
      notifyListeners();
      return true;
    }
  }

  // စုစုပေါင်း ကုန်ကျစရိတ် တွက်ရန်
  double get totalPrice {
    return _cartItems.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  // Final Total Amount
  double get total {
    final calculatedTotal = subtotal;
    return calculatedTotal < 0 ? 0 : calculatedTotal;
  }

  // Cart ရှင်းရန်
  void clearCart() {
    _cartItems.clear();
    _items.clear();
    notifyListeners();
  }

  // 1. Quantity တိုးရန် (+)
  void increaseQuantity(String id) {
    int index = _cartItems.indexWhere((item) => item.id == id);
    if (index >= 0) {
      _cartItems[index].quantity++;
      notifyListeners();
    }
  }

  // 2. Quantity လျှော့ရန် (-)
  void decreaseQuantity(String id) {
    int index = _cartItems.indexWhere((item) => item.id == id);
    if (index >= 0) {
      if (_cartItems[index].quantity > 1) {
        _cartItems[index].quantity--;
      } else {
        // Quantity 1 ဖြစ်နေချိန် - နှိပ်ရင် Cart ထဲက ပါ လုံးဝဖျက်မည်
        _cartItems.removeAt(index);
      }
      notifyListeners();
    }
  }

  // 3. Item ကို Cart ထဲမှ လုံးဝ ဖျက်ရန် (Trash Icon)
  void removeItem(String id) {
    _cartItems.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}
