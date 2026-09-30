import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pos_nlh/providers/cart_provider.dart';
import 'package:pos_nlh/providers/item_provider.dart';
import 'package:pos_nlh/screens/dashboard_screen.dart';
import 'package:pos_nlh/screens/display_screen.dart';
import 'package:pos_nlh/screens/expenses_screen.dart';
import 'package:pos_nlh/screens/login_screen.dart';
import 'package:pos_nlh/screens/sale_history_screen.dart';
import 'package:pos_nlh/widgets/floating_checkout_bar_widget.dart';
import 'package:pos_nlh/widgets/ticket_panel_widget.dart';
import 'package:provider/provider.dart';
import 'add_item_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _shopName = 'POS Shop';
  String _ownerName = 'Owner';
  bool _isTabletDrawerOpen =
      true; // Tablet တွင် Default အနေဖြင့် Drawer ပွင့်ထားမည်
  String _selectedCategory = 'All items';

  // 🟢 Tablet မြင်ကွင်းအတွက် ညာဘက်အခြမ်းတွင် ပြသမည့် Active Screen State
  Widget? _activeTabletDetailScreen;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItemProvider>().fetchItems();
      _fetchShopData();
    });
  }

  Future<void> _fetchShopData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance
          .collection('Shops')
          .doc(uid)
          .get();
      if (doc.exists && mounted) {
        setState(() {
          _shopName = doc.data()?['shopName'] ?? 'POS Shop';
        });
      }
    }
  }

  // 🟢 Screen များကို Navigate လုပ်ပေးသည့် Helper Function
  void _navigateToScreen(Widget screen, bool isTablet) {
    if (isTablet) {
      // Tablet ဖြစ်ပါက Drawer ကို မပိတ်ဘဲ ညာဘက် Main View တွင် Screen အစားထိုးမည်
      setState(() {
        _activeTabletDetailScreen = screen;
      });
    } else {
      // Phone ဖြစ်ပါက standard Navigator push အသုံးပြုပြီး Drawer ကို ပိတ်မည်

      Navigator.pop(context);

      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    final cartProvider = context.watch<CartProvider>();

    return Consumer<ItemProvider>(
      builder: (context, itemProvider, _) {
        // Category စစ်ထုတ်ခြင်း
        final Set<String> categorySet = {'All items'};
        for (var item in itemProvider.items) {
          if (item.category != null && item.category!.trim().isNotEmpty) {
            categorySet.add(item.category!);
          }
        }
        final List<String> categories = categorySet.toList();

        if (!categories.contains(_selectedCategory)) {
          _selectedCategory = 'All items';
        }

        final filteredItems = _selectedCategory == 'All items'
            ? itemProvider.items
            : itemProvider.items.where((item) {
                return item.category == _selectedCategory;
              }).toList();

        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF4CAF50),
            title: PopupMenuButton<String>(
              initialValue: _selectedCategory,
              onSelected: (String newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
              },
              offset: const Offset(0, 40),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedCategory,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.white,
                    size: 28,
                  ),
                ],
              ),
              itemBuilder: (BuildContext context) {
                return categories.map((String category) {
                  return PopupMenuItem<String>(
                    value: category,
                    child: Row(
                      children: [
                        if (_selectedCategory == category)
                          const Icon(
                            Icons.check,
                            color: Color(0xFF4CAF50),
                            size: 18,
                          )
                        else
                          const SizedBox(width: 18),
                        const SizedBox(width: 8),
                        Text(
                          category,
                          style: TextStyle(
                            fontWeight: _selectedCategory == category
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: _selectedCategory == category
                                ? const Color(0xFF4CAF50)
                                : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList();
              },
            ),
            leading: isTablet
                ? IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _isTabletDrawerOpen = !_isTabletDrawerOpen;
                      });
                    },
                  )
                : null,
            actions: [
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  _navigateToScreen(const AddItemScreen(), isTablet);
                },
              ),
            ],
          ),

          // 📱 Phone တွင်သာ Overlay Drawer ကို အသုံးပြုမည်
          drawer: isTablet
              ? null
              : Builder(
                  builder: (scaffoldContext) {
                    // scaffoldContext ကို အသုံးပြုမည်
                    return MyDrawerContent(
                      ownerName: _ownerName,
                      shopName: _shopName,
                      onSelectMenu: (screen) =>
                          _navigateToScreen(screen, false),
                      onSelectSales: () {
                        // context နေရာမှာ scaffoldContext ကို သုံးပေးရပါမည်
                        if (Scaffold.of(scaffoldContext).isDrawerOpen) {
                          Navigator.pop(scaffoldContext);
                        }
                      },
                    );
                  },
                ),

          body: Row(
            children: [
              // 📱 Tablet တွင် Drawer ပွင့်နေပါက Permanent Side Panel အနေဖြင့် ပြမည်
              if (isTablet && _isTabletDrawerOpen)
                SizedBox(
                  width: 280,
                  child: MyDrawerContent(
                    ownerName: _ownerName,
                    shopName: _shopName,
                    onSelectMenu: (screen) => _navigateToScreen(screen, true),
                    onSelectSales: () {
                      setState(() {
                        _activeTabletDetailScreen =
                            null; // Sales View သို့ ပြန်သွားမည်
                      });
                    },
                  ),
                ),

              if (isTablet && _isTabletDrawerOpen)
                const VerticalDivider(width: 1, thickness: 1),

              // 📱 Tablet တွင် Screen တစ်ခုခု ရွေးထားပါက ထို Screen ကို ပြမည်။ မဟုတ်ပါက GridView (Sales Main Screen) ကို ပြမည်
              Expanded(
                child: _activeTabletDetailScreen != null && isTablet
                    ? _activeTabletDetailScreen!
                    : Builder(
                        builder: (context) {
                          if (itemProvider.isLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (filteredItems.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _selectedCategory == 'All items'
                                        ? 'No Items Added Yet'
                                        : 'No items found in "$_selectedCategory"',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      _navigateToScreen(
                                        const AddItemScreen(),
                                        isTablet,
                                      );
                                    },
                                    child: const Text('Add Item Now'),
                                  ),
                                ],
                              ),
                            );
                          }

                          return GridView.builder(
                            padding: const EdgeInsets.all(12),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: isTablet
                                      ? (_isTabletDrawerOpen ? 4 : 5)
                                      : 3,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,

                                  // Card ကို နည်းနည်းပိုကျစ်လစ်အောင်
                                  //childAspectRatio: isTablet ? 0.85 : 0.72,
                                  mainAxisExtent: isTablet ? 225 : 205,
                                ),
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];

                              final bool outOfStock = item.stock <= 0;
                              final bool lowStock =
                                  item.stock > 0 && item.stock <= 5;

                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(18),
                                  onTap: outOfStock
                                      ? null
                                      : () {
                                          final cart = context
                                              .read<CartProvider>();

                                          // cart.addItem(
                                          //   item.id,
                                          //   item.name,
                                          //   item.price.toDouble(),
                                          //   item.category,
                                          //   item.stock,
                                          // );

                                          final success = cart.addProduct(item);

                                          if (!success) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).hideCurrentSnackBar();

                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Stock ထက် ပိုထည့်၍ မရပါ',
                                                ),
                                                duration: Duration(seconds: 1),
                                              ),
                                            );
                                          }
                                        },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.outline.withOpacity(0.12),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(18),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // ─────────────────────────
                                          // Product Image / Initial
                                          // ─────────────────────────
                                          Expanded(
                                            flex: 5,
                                            child: Stack(
                                              children: [
                                                Container(
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      colors: [
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .primary
                                                            .withOpacity(0.08),
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .primary
                                                            .withOpacity(0.18),
                                                      ],
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Container(
                                                      width: 52,
                                                      height: 52,
                                                      decoration: BoxDecoration(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary
                                                            .withOpacity(0.12),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              18,
                                                            ),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          item.name.isNotEmpty
                                                              ? item.name
                                                                    .substring(
                                                                      0,
                                                                      1,
                                                                    )
                                                                    .toUpperCase()
                                                              : '?',
                                                          style: TextStyle(
                                                            fontSize: 30,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .primary,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                // ─────────────────────
                                                // Stock Badge
                                                // ─────────────────────
                                                Positioned(
                                                  top: 8,
                                                  right: 8,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: outOfStock
                                                          ? Colors.red
                                                          : lowStock
                                                          ? Colors.orange
                                                          : Colors.green,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      outOfStock
                                                          ? 'Out'
                                                          : 'Stock ${item.stock}',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                // ─────────────────────
                                                // Out of Stock Overlay
                                                // ─────────────────────
                                                if (outOfStock)
                                                  Positioned.fill(
                                                    child: Container(
                                                      color: Colors.white
                                                          .withOpacity(0.55),
                                                      child: const Center(
                                                        child: Icon(
                                                          Icons
                                                              .remove_shopping_cart_outlined,
                                                          size: 30,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),

                                          // ─────────────────────────
                                          // Product Information
                                          // ─────────────────────────
                                          Expanded(
                                            flex: 4,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                    10,
                                                    8,
                                                    10,
                                                    8,
                                                  ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Product Name
                                                  Text(
                                                    item.name,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),

                                                  const SizedBox(height: 4),

                                                  // Category
                                                  if (item.category.isNotEmpty)
                                                    Text(
                                                      item.category,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors
                                                            .grey
                                                            .shade500,
                                                      ),
                                                    ),

                                                  const Spacer(),

                                                  // Price + Add Button
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: FittedBox(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          fit: BoxFit.scaleDown,
                                                          child: Text(
                                                            '${item.price.toInt()} Ks',
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Theme.of(
                                                                        context,
                                                                      )
                                                                      .colorScheme
                                                                      .primary,
                                                            ),
                                                          ),
                                                        ),
                                                      ),

                                                      const SizedBox(width: 6),

                                                      // Add Button
                                                      Container(
                                                        width: 30,
                                                        height: 30,
                                                        decoration: BoxDecoration(
                                                          color: outOfStock
                                                              ? Colors
                                                                    .grey
                                                                    .shade200
                                                              : Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .primary,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                        ),
                                                        child: Icon(
                                                          Icons.add,
                                                          size: 19,
                                                          color: outOfStock
                                                              ? Colors.grey
                                                              : Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),

              // ညာဘက် Ticket Panel (Sales Screen ပေါ်နေချိန်တွင်သာ ပြမည်)
              if (isTablet &&
                  _activeTabletDetailScreen == null &&
                  cartProvider.cartItems.isNotEmpty)
                const SizedBox(width: 320, child: TicketPanelWidget()),
            ],
          ),
          bottomNavigationBar: !isTablet
              ? Selector<CartProvider, int>(
                  selector: (_, cart) => cart.totalQuantity,
                  builder: (context, totalQuantity, child) {
                    if (totalQuantity == 0) return const SizedBox.shrink();

                    return const FloatingCheckoutBarWidget();
                  },
                )
              : null,
        );
      },
    );
  }
}

// 🟢 Reusable Drawer Content Widget
class MyDrawerContent extends StatelessWidget {
  final String ownerName;
  final String shopName;
  final Function(Widget screen) onSelectMenu;
  final VoidCallback onSelectSales;

  const MyDrawerContent({
    super.key,
    required this.ownerName,
    required this.shopName,
    required this.onSelectMenu,
    required this.onSelectSales,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(color: Color(0xFF4CAF50)),
                  accountName: Text(
                    ownerName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  accountEmail: Text(
                    shopName,
                    style: const TextStyle(fontSize: 16),
                  ),
                  currentAccountPicture: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.store,
                      color: Color(0xFF4CAF50),
                      size: 36,
                    ),
                  ),
                  accountPhone: null,
                ),
                ListTile(
                  leading: const Icon(
                    Icons.dashboard,
                    color: Color.fromARGB(255, 76, 106, 175),
                  ),
                  title: const Text('Dashboard'),
                  onTap: () => onSelectMenu(const DashboardScreen()),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.shopping_basket,
                    color: Color(0xFF4CAF50),
                  ),
                  title: const Text('Sales'),
                  onTap: onSelectSales,
                ),
                ListTile(
                  leading: const Icon(Icons.receipt_long),
                  title: const Text('Receipts'),
                  onTap: () => onSelectMenu(const SaleHistoryScreen()),
                ),
                ListTile(
                  leading: const Icon(Icons.list_alt),
                  title: const Text('My Items'),
                  onTap: () => onSelectMenu(const AddItemScreen()),
                ),
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet_outlined),
                  title: const Text('Expenses'),
                  onTap: () => onSelectMenu(const ExpensesScreen()),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.light_mode_outlined,
                    color: Colors.black87,
                  ),
                  title: const Text('Display Setting'),
                  onTap: () => onSelectMenu(const DisplayScreen()),
                ),
                ListTile(
                  leading: const Icon(Icons.language, color: Colors.black87),
                  title: const Text('Language'),
                  onTap: () {
                    if (Scaffold.of(context).isDrawerOpen) {
                      Navigator.pop(context);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: InkWell(
              onTap: () async {
                if (Scaffold.of(context).isDrawerOpen) {
                  Navigator.pop(context);
                }

                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text(
                      'Are you sure you want to logout? All local cache will be cleared.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await FirebaseAuth.instance.signOut();
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'POS for Android v1.0.0',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
