
import 'package:flutter/material.dart';
import 'package:mobile_developer_task/fetures/mainlayout/tabs/Customer_Details_Screen/Customer_Details%20_Screen.dart';
import 'package:mobile_developer_task/fetures/mainlayout/tabs/Customer_List_Screen/CustomerListScreen.dart';
import 'package:mobile_developer_task/fetures/mainlayout/tabs/Sales/Sales.dart';

import '../../core/Coloursmanger/ColorsManger.dart';
import '../../l10n/app_localizations.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late final List<Widget> _tabs = [
    const CustomerListScreen(),
    const CustomerDetailsScreen(customer: CustomerModel()),
    const Sales(),
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
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings),
          label: AppLocalizations.of(context)!.settings,
        ),
      ],
    );
  }
}
