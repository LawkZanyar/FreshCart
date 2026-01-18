import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'owner_dashboard_screen.dart';
import 'inventory_screen.dart';
import 'monthly_profits_screen.dart';
import 'owner_profile_screen.dart';

class _CenteredNavBar extends StatelessWidget {
  final NavBarConfig config;
  const _CenteredNavBar(this.config);

  @override
  Widget build(BuildContext context) {
    final items = config.items;
    final selectedIndex = config.selectedIndex;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      height: 56,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 136, 220, 189),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final active = index == selectedIndex;
          final item = items[index];

          return Expanded(
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                splashColor: const Color.fromARGB(
                  255,
                  11,
                  75,
                  46,
                ).withOpacity(0.2),
                highlightColor: const Color.fromARGB(
                  255,
                  11,
                  75,
                  46,
                ).withOpacity(0.1),
                onTap: () => config.onItemSelected(index),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconTheme(
                      data: IconThemeData(
                        color: active
                            ? item.activeForegroundColor
                            : item.inactiveForegroundColor,
                      ),
                      child: item.icon,
                    ),
                    const SizedBox(height: 2),
                    DefaultTextStyle(
                      style: TextStyle(
                        color: active
                            ? item.activeForegroundColor
                            : item.inactiveForegroundColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      child: Text(item.title ?? ''),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class OwnerBottomShell extends StatelessWidget {
  const OwnerBottomShell({super.key});

  List<PersistentTabConfig> _tabs(BuildContext context) => [
    PersistentTabConfig(
      screen: const OwnerDashboardScreen(),
      item: ItemConfig(
        icon: const Icon(Icons.dashboard_outlined),
        title: 'Dashboard',
        activeForegroundColor: const Color(0xFF1B5E3F),
        inactiveForegroundColor: const Color(0xFF1B5E3F).withOpacity(0.5),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    ),
    PersistentTabConfig(
      screen: const InventoryScreen(),
      item: ItemConfig(
        icon: const Icon(Icons.inventory_2_outlined),
        title: 'Inventory',
        activeForegroundColor: const Color(0xFF1B5E3F),
        inactiveForegroundColor: const Color(0xFF1B5E3F).withOpacity(0.5),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    ),
    PersistentTabConfig(
      screen: const MonthlyProfitsScreen(),
      item: ItemConfig(
        icon: const Icon(Icons.bar_chart_outlined),
        title: 'Profits',
        activeForegroundColor: const Color(0xFF1B5E3F),
        inactiveForegroundColor: const Color(0xFF1B5E3F).withOpacity(0.5),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    ),
    PersistentTabConfig(
      screen: const OwnerProfileScreen(),
      item: ItemConfig(
        icon: const Icon(Icons.person_outline),
        title: 'Profile',
        activeForegroundColor: const Color(0xFF1B5E3F),
        inactiveForegroundColor: const Color(0xFF1B5E3F).withOpacity(0.5),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      tabs: _tabs(context),
      navBarBuilder: (config) => _CenteredNavBar(config),
    );
  }
}
