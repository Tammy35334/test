// lib/screens/flyers_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../blocs/flyers_bloc.dart';
import '../repositories/flyers_repository.dart';
import '../widgets/store_list_item.dart';
import '../widgets/empty_list_indicator.dart';
import '../widgets/error_indicator.dart';
import '../models/store.dart'; 

class FlyersPage extends StatefulWidget {
  static const routeName = '/flyers';

  const FlyersPage({super.key});

  @override
  FlyersPageState createState() => FlyersPageState();
}

class FlyersPageState extends State<FlyersPage> {
  late final FlyersBloc _flyersBloc;

  @override
  void initState() {
    super.initState();
    final flyersRepository = Provider.of<FlyersRepository>(context, listen: false);
    _flyersBloc = FlyersBloc(repository: flyersRepository);
    _loadCachedFlyers();
  }

  Future<void> _loadCachedFlyers() async {
    final cachedFlyers = await _flyersBloc.repository.getCachedFlyers();
    if (mounted) { // Check if the widget is still mounted
      if (cachedFlyers.isNotEmpty) {
        // Implement local pagination with cached data
        _flyersBloc.pagingController.appendLastPage(cachedFlyers);
        print('Loaded cached flyers.');
      } else {
        _flyersBloc.pagingController.refresh();
        print('No cached flyers found. Refreshing to fetch new data.');
      }
    }
  }

  @override
  void dispose() {
    _flyersBloc.close();
    super.dispose();
  }

  // Pull-down-to-refresh handler
  Future<void> _onRefresh() async {
    print('Refreshing flyers list.');
    _flyersBloc.pagingController.refresh();
  }

  Widget _buildFlyersList() {
    return PagedSliverList<int, Store>(
      pagingController: _flyersBloc.pagingController,
      builderDelegate: PagedChildBuilderDelegate<Store>(
        itemBuilder: (context, item, index) => StoreListItem(store: item),
        firstPageErrorIndicatorBuilder: (context) => ErrorIndicator(
          error: (_flyersBloc.pagingController.error as Exception).toString(),
          onTryAgain: () {
            print('Retrying to fetch flyers.');
            _flyersBloc.pagingController.refresh();
          },
        ),
        noItemsFoundIndicatorBuilder: (context) => const EmptyListIndicator(
          message: 'No flyers available.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FlyersBloc>(
      create: (context) => _flyersBloc,
      child: Scaffold(
        // Customized AppBar
        appBar: AppBar(
          backgroundColor: Colors.white, // Set AppBar background to white
          elevation: 0, // Remove AppBar shadow
          title: const Text(
            'Flyers',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 24,
              color: Colors.black, // Set title color to black
            ),
          ),
          centerTitle: false, // Align title to the left
          iconTheme: const IconThemeData(color: Colors.black), // Set icon color to black
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: CustomScrollView(
              slivers: [
                _buildFlyersList(),
              ],
            ),
          ),
        ),
        // FloatingActionButton is handled by HomePage
      ),
    );
  }
}
