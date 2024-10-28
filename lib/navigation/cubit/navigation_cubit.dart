import 'package:flutter_bloc/flutter_bloc.dart';

enum NavigationTab { market, flyers, shoppingList }

class NavigationCubit extends Cubit<NavigationTab> {
  NavigationCubit() : super(NavigationTab.market);

  void setTab(NavigationTab tab) => emit(tab);
}
