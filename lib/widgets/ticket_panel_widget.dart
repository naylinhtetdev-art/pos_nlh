import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pos_nlh/models/receipt_model.dart';
import 'package:pos_nlh/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class TicketPanelWidget extends StatefulWidget {
  const TicketPanelWidget({super.key});

  @override
  State<TicketPanelWidget> createState() => _TicketPanelWidget();
}

class _TicketPanelWidget extends State<TicketPanelWidget> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Column(
      children: [
        // Ticket Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ticket',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {},
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Selected Items List
        Expanded(
          child: cart.cartItems.isEmpty
              ? const Center(
                  child: Text(
                    'No items in ticket',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: cart.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cart.cartItems[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // အပေါ်တန်း - Name, Total Price & Delete Button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${(item.price * item.quantity).toInt()} MMK',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () {
                                  context.read<CartProvider>().removeItem(
                                    item.id,
                                  );
                                },
                                child: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // အောက်တန်း - Single Price & (- 1 +) Controls
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${item.price.toInt()} MMK',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                              // Quantity Controls Box (- 1 +)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        context
                                            .read<CartProvider>()
                                            .decreaseQuantity(item.id);
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.all(2.0),
                                        child: Icon(Icons.remove, size: 16),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Text(
                                        '${item.quantity}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        // 🟢 Stock ထက်ကျော်လွန်၍ မတိုးအောင် စစ်ဆေးခြင်း
                                        if (item.quantity < item.stock) {
                                          context
                                              .read<CartProvider>()
                                              .increaseQuantity(item.id);
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Stock ထက် ပို၍ ရောင်းမရပါ။ (လက်ကျန်: ${item.stock})',
                                              ),
                                              duration: const Duration(
                                                seconds: 1,
                                              ),
                                            ),
                                          );
                                        }
                                        // context
                                        //     .read<CartProvider>()
                                        //     .increaseQuantity(item.id);
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.all(2.0),
                                        child: Icon(Icons.add, size: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),

        // Total Price Summary Section
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Items',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  Text(
                    '${cart.totalQuantity}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Subtotal',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  Text(
                    '${cart.totalPrice.toInt()} MMK',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Discount',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  Text(
                    '0 MMK',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TOTAL',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${cart.totalPrice.toInt()} MMK',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // CHECKOUT Button
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5C5494),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  onPressed: cart.cartItems.isEmpty
                      ? null
                      : () {
                          // Checkout Logic
                          _showPaymentDialog(context, cart);
                        },
                  child: const Text(
                    'CHECKOUT',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showPaymentDialog(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total: ${cart.totalPrice.toStringAsFixed(0)} MMK',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.money),
                title: const Text('Cash'),
                onTap: () {
                  Navigator.pop(context);
                  _completeSale('Cash');
                },
              ),
              ListTile(
                leading: const Icon(Icons.phone_android),
                title: const Text('Mobile Pay'),
                onTap: () {
                  Navigator.pop(context);
                  _completeSale('Mobile Pay');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _completeSale(String paymentMethod) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login first')));
      return;
    }
    String shopName = '';
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance
          .collection('Shops')
          .doc(uid)
          .get();
      if (doc.exists && mounted) {
        setState(() {
          shopName = doc.data()?['shopName'] ?? 'POS Shop';
        });
      }
    }
    final cart = context.read<CartProvider>();

    // 🟢 cart.items အစား cart.cartItems ကို သုံးပေးပါ
    if (cart.cartItems.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // =====================================
      // 1. SAVE CART DATA BEFORE CLEAR
      // =====================================

      final subtotal = cart.totalPrice; // CartProvider ထဲမှ totalPrice
      final discount = 0.0; // Discount ရှိပါက ထည့်ပါ
      final totalAmount = subtotal - discount;

      // =====================================
      // 2. CREATE INVOICE NUMBER
      // =====================================
      final invoiceNo = 'INV-${DateTime.now().millisecondsSinceEpoch}';

      // =====================================
      // 3. CREATE SALE ITEMS (Firestore Format)
      // =====================================
      // 🟢 CartItem Model structure အတိုင်း ပြင်ထားပါသည်
      final items = cart.cartItems.map((item) {
        return {
          'productId': item.id,
          'name': item.name,
          'price': item.price,
          'quantity': item.quantity,
          'total': item.price * item.quantity,
        };
      }).toList();

      // =====================================
      // 4. CREATE RECEIPT ITEMS
      // =====================================
      final receiptItems = cart.cartItems.map((item) {
        return ReceiptItem(
          name: item.name,
          price: item.price,
          quantity: item.quantity,
          categoryName: item.categoryName,
        );
      }).toList();

      // 3. FIRESTORE WRITE BATCH (Sale သိမ်းမည် + Stock လျှော့မည်)
      // =========================================================
      final batch = FirebaseFirestore.instance.batch();

      // (A) Sales collection ထဲသို့ Document reference ယူပြီး Add လုပ်ရန် ပြင်ခြင်း
      final saleRef = FirebaseFirestore.instance
          .collection('Shops')
          .doc(uid)
          .collection('sales')
          .doc();

      batch.set(saleRef, {
        'uid': uid,
        'invoiceNo': invoiceNo,
        'subtotal': subtotal,
        'discount': discount,
        'total': totalAmount,
        'paymentMethod': paymentMethod,
        'items': items,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // (B) Cart ထဲရှိ Product တိုင်း၏ Stock ကို FieldValue.increment(-quantity) ဖြင့် လျှော့ခြင်း
      for (var item in cart.cartItems) {
        // ⚠️ သင်၏ Products collection လမ်းကြောင်းကို စစ်ဆေးပါ
        // ဥပမာ- 'Shops/$uid/products/$itemId' သို့မဟုတ် 'products/$itemId'
        final productRef = FirebaseFirestore.instance
            .collection('Shops')
            .doc(uid)
            .collection('items')
            .doc(item.id);

        batch.update(productRef, {
          'stock': FieldValue.increment(-item.quantity),
          // သို့မဟုတ် 'quantity': FieldValue.increment(-item.quantity),
        });
      }

      // (C) Batch ကို တစ်ပြိုင်နက်တည်း Commit လုပ်ခြင်း
      await batch.commit();

      // =====================================
      // 5. SAVE SALE TO FIRESTORE
      // =====================================
      // 🟢 FirebaseFirestore သို့ တိုက်ရိုက် သို့မဟုတ် SaleService မှတစ်ဆင့် သိမ်းဆည်းခြင်း
      // await FirebaseFirestore.instance
      //     .collection('Shops/$uid/sales') // သို့မဟုတ် 'shops/${user.uid}/sales'
      //     .add({
      //       'uid': user.uid,
      //       'invoiceNo': invoiceNo,
      //       'subtotal': subtotal,
      //       'discount': discount,
      //       'total': totalAmount,
      //       'paymentMethod': paymentMethod,
      //       'items': items,
      //       'createdAt': FieldValue.serverTimestamp(),
      //     });

      // =====================================
      // 6. CREATE RECEIPT MODEL
      // =====================================
      final receipt = ReceiptModel(
        shopName: shopName, // မိမိ ဆိုင်နာမည် ထည့်ရန်
        invoiceNo: invoiceNo,
        date: DateTime.now(),
        items: receiptItems,
        subtotal: subtotal,
        discount: discount,
        total: totalAmount,
        paymentMethod: paymentMethod,
      );

      // =====================================
      // 7. CLEAR CART
      // =====================================
      cart.clearCart();

      if (!mounted) return;

      // =====================================
      // 8. SHOW RECEIPT PREVIEW
      // =====================================
      _showReceiptPreview(context, receipt);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sale failed: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showReceiptPreview(BuildContext context, ReceiptModel receipt) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420, maxHeight: 700),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // =========================
                  // HEADER
                  // =========================
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Receipt Preview',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // =========================
                  // RECEIPT
                  // =========================
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // SHOP NAME
                            Text(
                              receipt.shopName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 4),

                            const Text(
                              'Thank you for shopping with us',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),

                            const SizedBox(height: 12),

                            const Divider(),

                            // INVOICE
                            Text('Invoice: ${receipt.invoiceNo}'),

                            const SizedBox(height: 4),

                            Text('Date: ${_formatDate(receipt.date)}'),

                            const Divider(),

                            const SizedBox(height: 5),

                            // ITEM HEADER
                            Row(
                              children: const [
                                Expanded(
                                  child: Text(
                                    'Item',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  width: 95,
                                  child: Text(
                                    'Qty × Price',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  width: 65,
                                  child: Text(
                                    'Total',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // ITEMS
                            ...receipt.items.map((item) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 5,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(item.name)),

                                    SizedBox(
                                      width: 95,
                                      child: Text(
                                        '${item.quantity} × '
                                        '${item.price.toStringAsFixed(0)}',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),

                                    SizedBox(
                                      width: 65,
                                      child: Text(
                                        item.total.toStringAsFixed(0),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),

                            const Divider(),

                            // SUBTOTAL
                            _receiptSummaryRow('Subtotal', receipt.subtotal),

                            // DISCOUNT
                            _receiptSummaryRow('Discount', receipt.discount),

                            const Divider(),

                            // TOTAL
                            _receiptSummaryRow(
                              'TOTAL',
                              receipt.total,
                              isTotal: true,
                            ),

                            const SizedBox(height: 12),

                            // PAYMENT
                            Text(
                              'Payment: ${receipt.paymentMethod}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const SizedBox(height: 18),

                            const Text(
                              'Thank You!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // =========================
                  // PRINT
                  // =========================
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Printer will be added here
                      },
                      icon: const Icon(Icons.print),
                      label: const Text('Print Receipt'),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // =========================
                  // CLOSE
                  // =========================
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _receiptSummaryRow(
    String title,
    double value, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: isTotal ? 18 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),

          Text(
            '${value.toStringAsFixed(0)} MMK',
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');

    final month = date.month.toString().padLeft(2, '0');

    final year = date.year.toString();

    final hour = date.hour.toString().padLeft(2, '0');

    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }
}
