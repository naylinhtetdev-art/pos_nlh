import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pos_nlh/providers/item_provider.dart';
import 'package:pos_nlh/screens/login_screen.dart';
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
  bool _isTabletDrawerOpen = false; // Tablet အတွက် Side Drawer ပွင့်/ပိတ် state

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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text('All items', style: TextStyle(color: Colors.white)),
        // Tablet ဖြစ်ရင် Custom Menu Icon သုံးပြီး၊ Phone ဖြစ်ရင် Scaffold ရဲ့ Normal Drawer Icon သုံးမည်
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

      // Phone မှာဆိုရင် Standard Overlay Drawer ကို သုံးမည်
      drawer: isTablet
          ? null
          : MyDrawerContent(ownerName: _ownerName, shopName: _shopName),

      // Body တွင် Tablet သို့မဟုတ် Phone ပေါ်မူတည်၍ Layout ခွဲပြမည်
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
            child: Consumer<ItemProvider>(
              builder: (context, itemProvider, _) {
                if (itemProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (itemProvider.items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('No Items Added Yet'),
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
                    // Phone မှာ ၃ ကော်လံ၊ Tablet မှာ Drawer ပွင့်ချိန် ၄ ကော်လံ/ ပိတ်ချိန် ၅ ကော်လံ[cite: 3]
                    crossAxisCount: isTablet
                        ? (_isTabletDrawerOpen ? 4 : 5)
                        : 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: itemProvider.items.length,
                  itemBuilder: (context, index) {
                    final item = itemProvider.items[index];
                    return Card(
                      elevation: 2,
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          Container(
                            color: Colors.amber.shade100,
                            child: Center(
                              child: Text(
                                item.name.isNotEmpty
                                    ? item.name.substring(0, 1).toUpperCase()
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
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
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.list_alt),
                  title: const Text('Items'),
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
