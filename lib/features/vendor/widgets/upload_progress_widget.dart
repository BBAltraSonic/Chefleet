import 'package:flutter/material.dart';

class UploadProgressWidget extends StatelessWidget {
  final double progress;
  final dynamic status; // Dynamic to avoid dependency on bloc state enum for now
  final int totalUploads;
  final int completedUploads;
  final VoidCallback onCancel;

  const UploadProgressWidget({
    super.key,
    required this.progress,
    required this.status,
    required this.totalUploads,
    required this.completedUploads,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue[50],
      child: Row(
        children: [
          CircularProgressIndicator(value: progress),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Uploading... $completedUploads/$totalUploads'),
                LinearProgressIndicator(value: progress),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.cancel),
            onPressed: onCancel,
          ),
        ],
      ),
    );
  }
}
