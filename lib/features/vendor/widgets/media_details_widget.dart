import 'package:flutter/material.dart';

class MediaDetailsWidget extends StatelessWidget {
  final Map<String, dynamic> media;

  const MediaDetailsWidget({
    super.key,
    required this.media,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Media Details'),
          const SizedBox(height: 16),
          Text('ID: ${media['id']}'),
          Text('Path: ${media['file_path']}'),
        ],
      ),
    );
  }
}
