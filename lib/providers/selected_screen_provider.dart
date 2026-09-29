import 'package:flutter/material.dart';
import 'package:pos_nlh/screens/home_screen.dart';

class SelectedScreenProvider extends ChangeNotifier {
  // စစဖွင့်ခြင်း ပြသမည့် Screen (Default Widget)
  Widget _currentScreen = const HomeScreen();

  // လက်ရှိ ရွေးချယ်ထားသော Screen ၏ Index သို့မဟုတ် Name (UI ထဲတွင် active state ပြရန်)
  String _selectedMenu = 'home';

  Widget get currentScreen => _currentScreen;
  String get selectedMenu => _selectedMenu;

  // Screen အသစ် သို့ ပြောင်းလဲသည့် Function
  void setScreen(Widget screen, String menuName) {
    _currentScreen = screen;
    _selectedMenu = menuName;
    notifyListeners(); // UI ကို Refresh လုပ်ပေးရန်
  }
}
