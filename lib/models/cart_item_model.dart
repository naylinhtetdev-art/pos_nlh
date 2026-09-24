import 'package:pos_nlh/models/item_model.dart';

class CartItemModel {
  final ItemModel product;
  int quantity;

  CartItemModel({required this.product, this.quantity = 1});

  double get total {
    return product.price * quantity;
  }
}
