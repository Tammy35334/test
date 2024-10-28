import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../repositories/flyer_repository.dart';
import '../models/flyer.dart';
import 'flyer_detail_screen.dart';

class FlyersPage extends StatelessWidget {
  const FlyersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flyers'),
      ),
      body: BlocBuilder<FlyerRepository, List<Flyer>>(
        builder: (context, flyers) {
          if (flyers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: flyers.length,
            itemBuilder: (context, index) {
              final flyer = flyers[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FlyerDetailScreen(flyer: flyer),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Hero(
                        tag: 'flyer_${flyer.storeId}_0',
                        child: CachedNetworkImage(
                          imageUrl: flyer.flyerImages.first,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                      ListTile(
                        title: Text(
                          flyer.storeName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        subtitle: Text(flyer.province),
                        trailing: const Icon(Icons.arrow_forward_ios),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
