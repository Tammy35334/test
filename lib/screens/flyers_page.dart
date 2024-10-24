// lib/screens/flyers_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/cupertino.dart';

import '../blocs/flyers_bloc.dart';
import '../models/store.dart';
import '../repositories/flyers_repository.dart';
import '../widgets/flyer_list_item.dart';
import '../widgets/empty_list_indicator.dart';
import '../widgets/error_indicator.dart';

class FlyersPage extends StatefulWidget {
  const FlyersPage({super.key});

  @override
  FlyersPageState createState() => FlyersPageState();
}

class FlyersPageState extends State<FlyersPage> {
  Timer? _debounce;
  String _searchQuery = '';

  late final FlyersBloc _flyersBloc;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final flyersRepository =
        RepositoryProvider.of<FlyersRepository>(context, listen: false);
    _flyersBloc = FlyersBloc(repository: flyersRepository);
    _flyersBloc.add(const FetchFlyersEvent());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _flyersBloc.close();
    _searchController.dispose();
    super.dispose();
  }

  // Pull-down-to-refresh handler
  Future<void> _onRefresh() async {
    _flyersBloc.add(const FetchFlyersEvent());
  }

  // Search function with debounce
  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = value.trim();
      });
      if (_searchQuery.isNotEmpty) {
        _flyersBloc.add(SearchFlyersEvent(query: _searchQuery));
      } else {
        _flyersBloc.add(const FetchFlyersEvent());
      }
    });
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: CupertinoSearchTextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        onSubmitted: (value) {
          if (_searchQuery.isNotEmpty) {
            _flyersBloc.add(SearchFlyersEvent(query: _searchQuery));
          } else {
            _flyersBloc.add(const FetchFlyersEvent());
          }
        },
        onSuffixTap: () {
          _searchController.clear();
          setState(() {
            _searchQuery = '';
          });
          _flyersBloc.add(const FetchFlyersEvent());
        },
        placeholder: 'Search stores',
      ),
    );
  }

  Widget _buildFlyerList(List<Store> flyers) {
    // Apply search filter if necessary
    List<Store> filteredFlyers = _searchQuery.isNotEmpty
        ? flyers
            .where((store) => store.storeName
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
            .toList()
        : flyers;

    if (filteredFlyers.isEmpty) {
      return const EmptyListIndicator();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: filteredFlyers.length,
      itemBuilder: (context, index) {
        return FlyerListItem(flyer: filteredFlyers[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FlyersBloc>(
      create: (context) => _flyersBloc,
      child: Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: Column(
              children: [
                _buildSearchBar(),
                Expanded(
                  child: BlocBuilder<FlyersBloc, FlyersState>(
                    builder: (context, state) {
                      if (state is FlyersLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is FlyersLoaded) {
                        return _buildFlyerList(state.flyers);
                      } else if (state is FlyersError) {
                        return ErrorIndicator(
                          error: state.message,
                          onTryAgain: () =>
                              _flyersBloc.add(const FetchFlyersEvent()),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
