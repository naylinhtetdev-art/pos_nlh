import 'package:flutter/material.dart';
import 'package:pos_nlh/providers/cart_provider.dart';
import 'package:pos_nlh/widgets/ticket_panel_widget.dart';
import 'package:provider/provider.dart';

class FloatingCheckoutBarWidget extends StatelessWidget {
  const FloatingCheckoutBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumer သုံးပြီး Cart ရဲ့ totalQuantity နဲ့ total ပြောင်းမှပဲ ဒီ Bar Rebuild ဖြစ်မည်
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            // onPressed: () {
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (_) => const Scaffold(
            //         body: SafeArea(child: TicketPanelWidget()),
            //       ),
            //     ),
            //   );
            // },
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled:
                    true, // Height ကို အပြည့် သို့မဟုတ် လိုသလို ချိန်ရန်
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) {
                  return SizedBox(
                    height:
                        MediaQuery.of(context).size.height *
                        0.85, // Screen ၏ 85% အထိ မြင့်မည်
                    child: const TicketPanelWidget(),
                  );
                },
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${cart.totalQuantity} Items | ${cart.total.toStringAsFixed(0)} MMK',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Row(
                  children: [
                    Text(
                      'Checkout',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
