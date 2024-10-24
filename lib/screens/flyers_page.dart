// lib/screens/flyers_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../blocs/flyers_bloc.dart';
import '../models/store.dart';
import '../repositories/flyers_repository.dart';
import '../widgets/flyer_list_item.dart';
import '../widgets/empty_list_indicator.dart';
import '../widgets/error_indicator.dart';

class FlyersPage extends StatefulWidget {
  const FlyersPage({super.key});

  static const String routeName = '/flyers';

  @override
  FlyersPageState createState() => FlyersPageState();
}

class FlyersPageState extends State<FlyersPage> {
  Timer? _debounce;
  String _searchQuery = '';

  late final FlyersBloc _flyersBloc;

  @override
  void initState() {
    super.initState();
    final flyersRepository =
        Provider.of<FlyersRepository>(context, listen: false);
    _flyersBloc = FlyersBloc(repository: flyersRepository);
    _flyersBloc.add(const FetchFlyersEvent());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _flyersBloc.close();
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
      _flyersBloc.add(const FetchFlyersEvent());
    });
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: _showPincodeBottomSheet,
            child: const Text(
              'M1G1R2',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Handle profile icon tap
            },
            tooltip: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: CachedNetworkImage(
          imageUrl:
              'https://your-image-url.com/image.jpg', // Replace with your actual image URL
          placeholder: (context, url) => Container(
            width: double.infinity,
            height: 150,
            color: Colors.grey[300],
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => const Center(
            child: Text(
              'Failed to load image',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: CupertinoSearchTextField(
        controller: TextEditingController(text: _searchQuery),
        onChanged: (value) {
          _onSearchChanged(value);
        },
        onSubmitted: (value) {
          _flyersBloc.add(const FetchFlyersEvent());
        },
        onSuffixTap: () {
          setState(() {
            _searchQuery = '';
          });
          _flyersBloc.add(const FetchFlyersEvent());
        },
        placeholder: 'Search flyers',
      ),
    );
  }

  Widget _buildFlyerList(List<Store> flyers) {
    // Apply search filter if necessary
    List<Store> filteredFlyers = _searchQuery.isNotEmpty
        ? flyers
            .where((flyer) => flyer.storeName
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
            .toList()
        : flyers;

    if (filteredFlyers.isEmpty) {
      return const EmptyListIndicator();
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
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
        appBar: null,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 8.0),
                  _buildImageSection(),
                  const SizedBox(height: 16.0),
                  _buildSearchBar(),
                  const SizedBox(height: 16.0),
                  BlocBuilder<FlyersBloc, FlyersState>(
                    builder: (context, state) {
                      if (state is FlyersLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
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
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Handle FAB tap, e.g., open a new action
          },
          tooltip: 'Cat Action',
          child: const Icon(Icons.pets),
        ),
      ),
    );
  }

  Future<void> _showPincodeBottomSheet() async {
    if (!mounted) return;

    String pincode = '';
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter Pincode',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Pincode'),
                onChanged: (value) {
                  pincode = value;
                },
                onSubmitted: (value) async {
                  await _savePincode(value.trim());
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  if (pincode.trim().isEmpty) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pincode cannot be empty')),
                      );
                    }
                    return;
                  }
                  await _savePincode(pincode.trim());
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _savePincode(String pincode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pincode', pincode);
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pincode set to $pincode')),
    );
  }
}
