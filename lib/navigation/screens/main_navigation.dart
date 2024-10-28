import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/navigation_cubit.dart';
import '../../screens/market_page.dart';
import '../../screens/flyers_page.dart';
import '../../screens/shopping_list_page.dart';

class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationTab>(
      builder: (context, tab) {
        return Scaffold(
          body: IndexedStack(
            index: tab.index,
            children: const [
              MarketPage(),
              FlyersPage(),
              ShoppingListPage(),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: tab.index,
            onDestinationSelected: (index) {
              context
                  .read<NavigationCubit>()
                  .setTab(NavigationTab.values[index]);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.store),
                label: 'Market',
              ),
              NavigationDestination(
                icon: Icon(Icons.newspaper),
                label: 'Flyers',
              ),
              NavigationDestination(
                icon: Icon(Icons.shopping_cart),
                label: 'Shopping List',
              ),
            ],
          ),
        );
      },
    );
  }
}
