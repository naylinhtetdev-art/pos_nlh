import 'package:flutter/material.dart';
import 'package:pos_nlh/providers/item_provider.dart';
import 'package:provider/provider.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  // အသစ်ထည့်ရန် (သို့) ပြင်ဆင်ရန် Bottom Sheet ကို ခေါ်မည့် Function
  void _showItemForm(BuildContext context, {dynamic existingItem}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Keyboard ပေါ်လာလျှင် အပေါ်သို့ တွန်းတင်ပေးရန်
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx)
              .viewInsets
              .bottom, // Keyboard အမြင့်ပေါ်မူတည်ပြီး အောက်ကနေ တွန်းတင်မည်
        ),
        child: ItemFormWidget(existingItem: existingItem),
      ),
    );
  }

  // ဖျက်ရန် သေချာ/မသေချာ မေးမည့် Dialog
  void _confirmDelete(BuildContext context, String itemId, String itemName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('"$itemName" ကို ဖျက်ရန် သေချာပါသလား?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // ItemProvider ထဲမှ deleteItem ကို ခေါ်ပါမည် (Provider တွင် deleteItem method ရှိရပါမည်)
              context.read<ItemProvider>().deleteItem(itemId);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Item ဖျက်ပြီးပါပြီ')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Management'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: Consumer<ItemProvider>(
        builder: (context, itemProvider, child) {
          if (itemProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (itemProvider.items.isEmpty) {
            return const Center(
              child: Text(
                'Item များ မရှိသေးပါ။ အသစ်ထည့်ရန် + ကို နှိပ်ပါ။',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: itemProvider.items.length,
            padding: const EdgeInsets.only(bottom: 80), // FAB နှင့် မထပ်စေရန်
            itemBuilder: (context, index) {
              final item = itemProvider.items[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.amber.shade100,
                    child: Text(
                      item.name.isNotEmpty ? item.name[0].toUpperCase() : '?',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Price: ${item.price.toInt()} Ks | Stock: ${item.stock}\nCategory: ${item.category}',
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () =>
                        _confirmDelete(context, item.id, item.name),
                  ),
                  onTap: () {
                    // Item ပေါ်နှိပ်လျှင် Update လုပ်ရန် Form ကို existingItem data ဖြင့် ဖွင့်မည်
                    _showItemForm(context, existingItem: item);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showItemForm(context), // Add New Item အတွက် ခေါ်မည်
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ==============================================================
// 🟢 Add (သို့) Edit ပြုလုပ်ရန် သီးသန့်ထုတ်ထားသော Form Widget
// ==============================================================
class ItemFormWidget extends StatefulWidget {
  final dynamic
  existingItem; // Edit လုပ်ရန်ဆိုလျှင် Data ပါလာမည်၊ Add အတွက် null ဖြစ်မည်

  const ItemFormWidget({super.key, this.existingItem});

  @override
  State<ItemFormWidget> createState() => _ItemFormWidgetState();
}

class _ItemFormWidgetState extends State<ItemFormWidget> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _categoryController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Update အတွက်ဆိုလျှင် Controller ထဲသို့ Data အဟောင်းများ အရင်ထည့်ပေးထားမည်
    if (widget.existingItem != null) {
      _nameController.text = widget.existingItem.name;
      _priceController.text = widget.existingItem.price.toString();
      _stockController.text = widget.existingItem.stock.toString();
      _categoryController.text = widget.existingItem.category ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0;
    final stock = int.tryParse(_stockController.text.trim()) ?? 0;
    final category = _categoryController.text.trim();

    if (name.isEmpty || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item နာမည်နှင့် ဈေးနှုန်း မှန်ကန်စွာ ဖြည့်ပါ'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    bool success;
    if (widget.existingItem == null) {
      // 🟢 အသစ်ထည့်ခြင်း
      success = await context.read<ItemProvider>().addItem(
        name: name,
        price: price,
        stock: stock,
        category: category,
      );
    } else {
      // 🔵 အဟောင်းကို ပြင်ဆင်ခြင်း (ItemProvider တွင် updateItem method ရှိရန်လိုပါသည်)
      success = await context.read<ItemProvider>().updateItem(
        id: widget.existingItem.id,
        name: name,
        price: price,
        stock: stock,
        category: category,
      );
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.pop(context); // Bottom Sheet ကို ပိတ်မည်
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.existingItem == null
                ? 'Item အသစ် ထည့်သွင်းပြီးပါပြီ'
                : 'Item ပြင်ဆင်ပြီးပါပြီ',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.existingItem != null;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize
            .min, // Content အနည်းအများပေါ်မူတည်ပြီး အမြင့်ပြောင်းမည်
        children: [
          Text(
            isEditMode ? 'Update Item' : 'Add New Item',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Item Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Price (Ks)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Stock Quantity',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _isSaving
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: _saveItem,
                  child: Text(
                    isEditMode ? 'Update Item' : 'Save Item',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
        ],
      ),
    );
  }
}
