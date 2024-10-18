// lib/widgets/likes_drawer.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/likes_bloc.dart';
import '../models/like.dart';
import '../screens/flyer_detail_page.dart';
import '../utils/logger.dart';

class LikesDrawer extends StatelessWidget {
  const LikesDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LikesBloc, LikesState>(
      builder: (context, state) {
        if (state is LikesLoaded) {
          final likes = state.likes;

          if (likes.isEmpty) {
            return Center(
              child: Text(
                'No likes yet.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // Group likes by store
          final Map<String, List<Like>> likesByStore = {};
          for (var like in likes) {
            likesByStore.putIfAbsent(like.storeName, () => []).add(like);
          }

          final storeNames = likesByStore.keys.toList();

          return DefaultTabController(
            length: storeNames.length > 20 ? 20 : storeNames.length, // Limit to 20 tabs
            child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Colors.white,
                elevation: 0,
                bottom: TabBar(
                  isScrollable: true,
                  tabs: storeNames.take(20).map((store) => Tab(text: store)).toList(),
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.black,
                ),
              ),
              body: TabBarView(
                children: storeNames.take(20).map((store) {
                  final storeLikes = likesByStore[store]!;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      itemCount: storeLikes.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                      ),
                      itemBuilder: (context, index) {
                        final like = storeLikes[index];
                        return GestureDetector(
                          onTap: () {
                            logger.info('Navigating to like at (${like.x}, ${like.y}) in store $store.');
                            Navigator.pop(context); // Close the drawer
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FlyerDetailPage(
                                  flyerImages: [/* Provide the relevant image URL */],
                                  storeName: store,
                                  imageId: like.imageId,
                                ),
                              ),
                            ).then((_) {
                              // Optionally, trigger an animation to the specific like
                            });
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // Placeholder for the 100x100 pixel area
                                Container(
                                  color: Colors.grey[300],
                                  child: Icon(Icons.favorite, color: Colors.red),
                                ),
                                // Optionally, display the cropped thumbnail
                                // Implement caching or pre-generated thumbnails for better performance
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        } else if (state is LikesError) {
          return Center(
            child: Text(
              'Error loading likes: ${state.message}',
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
