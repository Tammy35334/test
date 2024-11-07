import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/models/flyer.dart';
import '../repositories/flyer_repository.dart';

class FlyersPage extends StatefulWidget {
  const FlyersPage({super.key});

  @override
  State<FlyersPage> createState() => _FlyersPageState();
}

class _FlyersPageState extends State<FlyersPage> {
  List<Flyer>? _flyers;

  @override
  void initState() {
    super.initState();
    _loadFlyers();
  }

  Future<void> _loadFlyers() async {
    final flyers = await context.read<FlyerRepository>().getFlyers();
    if (mounted) {
      setState(() {
        _flyers = flyers;
      });
    }
  }

  void _openFlyerDetails(Flyer flyer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlyerDetailScreen(
          flyer: flyer,
        ),
      ),
    );
  }

  Widget _buildStoreList() {
    if (_flyers == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadFlyers,
      child: ListView.builder(
        itemCount: _flyers!.length,
        itemBuilder: (context, index) {
          final flyer = _flyers![index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: SizedBox(
                width: 56,
                height: 56,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    flyer.flyerImages.first,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.store),
                      );
                    },
                  ),
                ),
              ),
              title: Text(flyer.storeName),
              subtitle: Text(flyer.province),
              trailing: Text('${flyer.flyerImages.length} pages'),
              onTap: () => _openFlyerDetails(flyer),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flyers'),
      ),
      body: _buildStoreList(),
    );
  }
}

class FlyerDetailScreen extends StatelessWidget {
  final Flyer flyer;

  const FlyerDetailScreen({
    super.key,
    required this.flyer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(flyer.storeName),
      ),
      body: PageView.builder(
        itemCount: flyer.flyerImages.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 1.0,
            maxScale: 4.0,
            child: Image.network(
              flyer.flyerImages[index],
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.error_outline, size: 48),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
