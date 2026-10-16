
import 'package:flutter/material.dart';
import 'package:mobile_developer_task/fetures/mainlayout/tabs/Coustomers/Customer_List_Screen/CustomerListScreenUI.dart';
import 'package:mobile_developer_task/fetures/mainlayout/tabs/Sales/SalesUI.dart';

import '../../core/Coloursmanger/ColorsManger.dart';
import '../../l10n/app_localizations.dart';

class MainLayout extends StatefulWidget {
   MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late final List<Widget> _tabs = [
     CustomerListScreen(),
    Sales(),
  ];

  int selectedIndex = 0;

  void _onTap(int newIndex) {
    if (newIndex < 0 || newIndex >= _tabs.length || newIndex == selectedIndex) {
      return;
    }
    setState(() {
      selectedIndex = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: selectedIndex.clamp(0, _tabs.length - 1),
        children: _tabs,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: _onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colorsmanger.darkblue,
      unselectedItemColor: Colorsmanger.Grey,
      backgroundColor: Colorsmanger.White,
      items: [

        BottomNavigationBarItem(
          icon: const Icon(Icons.people),
          label: AppLocalizations.of(context)!.customers,
        ),

        BottomNavigationBarItem(
          icon: const Icon(Icons.monetization_on),
          label: AppLocalizations.of(context)!.sales_orders,
        ),

      ],
    );
  }
}






