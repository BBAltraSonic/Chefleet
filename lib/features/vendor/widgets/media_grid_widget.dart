import 'package:flutter/material.dart';

class MediaGridWidget extends StatelessWidget {
  final List<Map<String, dynamic>> mediaItems;
  final Function(Map<String, dynamic>) onMediaSelected;
  final Function(Map<String, dynamic>) onMediaDeleted;

  const MediaGridWidget({
    super.key,
    required this.mediaItems,
    required this.onMediaSelected,
    required this.onMediaDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: mediaItems.length,
      itemBuilder: (context, index) {
        final item = mediaItems[index];
        return GestureDetector(
          onTap: () => onMediaSelected(item),
          child: Container(
            color: Colors.grey[200],
            child: const Center(child: Icon(Icons.image)),
          ),
        );
      },
    );
  }
}
