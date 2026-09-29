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
import 'package:pos_nlh/services/route_service.dart';
import 'package:pos_nlh/widgets/floating_checkout_bar_widget.dart';
import 'package:pos_nlh/widgets/ticket_panel_widget.dart';
import 'package:provider/provider.dart';
import 'add_item_screen.dart';

void _push(BuildContext context, Widget screen) {
  RouteService.popAndPush(context, screen);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _shopName = 'POS Shop';
  String _ownerName = 'Owner';
  bool _isTabletDrawerOpen = false; // Tablet အတွက် Side Drawer ပွင့်/ပိတ် state
  String _selectedCategory = 'All items';

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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600; // Screen ကျယ်/ကျဉ်း စစ်ဆေးခြင်း

    final cartProvider = context.watch<CartProvider>();

    // 🟢 Consumer<ItemProvider> ဖြင့် တစ်ခုတည်း ချုံ့ထားပါသည်
    return Consumer<ItemProvider>(
      builder: (context, itemProvider, _) {
        // 🟢 Category List ကို Dynamic စစ်ထုတ်ခြင်း
        final Set<String> categorySet = {'All items'};
        for (var item in itemProvider.items) {
          if (item.category != null && item.category!.trim().isNotEmpty) {
            categorySet.add(item.category!);
          }
        }
        final List<String> categories = categorySet.toList();

        // အကယ်၍ ရွေးထားသော category က list ထဲမှာ မရှိတော့ပါက 'All items' သို့ ပြန်ပြောင်းပေးခြင်း
        if (!categories.contains(_selectedCategory)) {
          _selectedCategory = 'All items';
        }

        // 🟢 Category အလိုက် Filter စစ်ပေးခြင်း
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddItemScreen()),
                  );
                },
              ),
            ],
          ),

          // Phone မှာဆိုရင် Standard Overlay Drawer
          drawer: isTablet
              ? null
              : MyDrawerContent(ownerName: _ownerName, shopName: _shopName),

          body: Row(
            children: [
              // Tablet ဖြစ်ပြီး Drawer ပွင့်ထားချိန်တွင် ဘေးတွင် ဘေးချင်းကပ် ပေါ်မည်
              if (isTablet && _isTabletDrawerOpen)
                SizedBox(
                  width: 280,
                  child: MyDrawerContent(
                    ownerName: _ownerName,
                    shopName: _shopName,
                  ),
                ),

              if (isTablet && _isTabletDrawerOpen)
                const VerticalDivider(width: 1, thickness: 1),

              // GridView ပိုင်း
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (itemProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AddItemScreen(),
                                  ),
                                );
                              },
                              child: const Text('Add Item Now'),
                            ),
                          ],
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(8.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isTablet
                            ? (_isTabletDrawerOpen ? 4 : 5)
                            : 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return Card(
                          elevation: 2,
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () {
                              context.read<CartProvider>().addItem(
                                item.id,
                                item.name,
                                item.price.toDouble(),
                                item.category,
                              );
                              final success = context
                                  .read<CartProvider>()
                                  .addProduct(item);
                              if (!success) {
                                ScaffoldMessenger.of(
                                  context,
                                ).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Stock ထက် ပိုထည့်၍ မရပါ'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              }
                            },
                            child: Stack(
                              children: [
                                Container(
                                  color: Colors.amber.shade100,
                                  child: Center(
                                    child: Text(
                                      item.name.isNotEmpty
                                          ? item.name
                                                .substring(0, 1)
                                                .toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    color: Colors.grey.shade800,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                      horizontal: 6,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          item.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          '${item.price.toInt()} Ks',
                                          style: const TextStyle(
                                            color: Colors.yellowAccent,
                                            fontSize: 11,
                                          ),
                                        ),
                                        Text(
                                          'Stock: ${item.stock}',
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // ညာဘက် Ticket Panel Area
              if (isTablet && cartProvider.cartItems.isNotEmpty)
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

// Drawer Widget
class MyDrawerContent extends StatelessWidget {
  final String ownerName;
  final String shopName;

  const MyDrawerContent({
    super.key,
    required this.ownerName,
    required this.shopName,
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
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DashboardScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.shopping_basket,
                    color: Color(0xFF4CAF50),
                  ),
                  title: const Text('Sales'),
                  onTap: () {
                    if (Scaffold.of(context).isDrawerOpen) {
                      Navigator.pop(context);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.receipt_long),
                  title: const Text('Receipts'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SaleHistoryScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.list_alt),
                  title: const Text('My Items'),
                  onTap: () {
                    if (Scaffold.of(context).isDrawerOpen) {
                      Navigator.pop(context);
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddItemScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet_outlined),
                  title: const Text('Expenses'),
                  onTap: () {
                    if (Scaffold.of(context).isDrawerOpen) {
                      Navigator.pop(context);
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ExpensesScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.light_mode_outlined,
                    color: Colors.black87,
                  ),
                  title: const Text('Display Setting'),
                  //onTap: () => Navigator.pop(context),
                  onTap: () => _push(context, const DisplayScreen()),
                ),
                ListTile(
                  leading: const Icon(Icons.language, color: Colors.black87),
                  title: const Text('Language'),
                  onTap: () => Navigator.pop(context),
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
