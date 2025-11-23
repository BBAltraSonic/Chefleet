// TODO: INCOMPLETE FEATURE - DO NOT USE
// This screen is not fully implemented and has missing dependencies:
// - Missing: package:file_picker/file_picker.dart
// - Missing: ../widgets/media_grid_widget.dart
// - Missing: ../widgets/upload_progress_widget.dart
// - Missing: ../widgets/media_details_widget.dart
// 
// To complete this feature:
// 1. Add file_picker package to pubspec.yaml
// 2. Implement the missing widget files
// 3. Test the complete upload flow
// 4. Remove this TODO comment
//
// Status: Disabled - Not referenced in routing or navigation
// Sprint: Deferred to future sprint

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../blocs/media_upload_bloc.dart';
import '../blocs/media_upload_event.dart';
import '../blocs/media_upload_state.dart';
import '../widgets/media_grid_widget.dart';
import '../widgets/upload_progress_widget.dart';
import '../widgets/media_details_widget.dart';

class MediaUploadScreen extends StatefulWidget {
  const MediaUploadScreen({super.key});

  @override
  State<MediaUploadScreen> createState() => _MediaUploadScreenState();
}

class _MediaUploadScreenState extends State<MediaUploadScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Load existing media
    context.read<MediaUploadBloc>().add(LoadUploadedMedia());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Library'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(
              icon: Icon(Icons.photo_library),
              text: 'Images',
            ),
            Tab(
              icon: Icon(Icons.description),
              text: 'Documents',
            ),
            Tab(
              icon: Icon(Icons.videocam),
              text: 'Videos',
            ),
            Tab(
              icon: Icon(Icons.folder),
              text: 'All Files',
            ),
          ],
        ),
        actions: [
          BlocBuilder<MediaUploadBloc, MediaUploadState>(
            builder: (context, state) {
              if (state.totalFileSize > 0) {
                return IconButton(
                  onPressed: () => _showStorageInfo(context, state),
                  icon: const Icon(Icons.storage),
                  tooltip: 'Storage Info',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Upload Progress Bar (visible when uploading)
          BlocBuilder<MediaUploadBloc, MediaUploadState>(
            builder: (context, state) {
              if (state.isUploading || state.isOptimizing) {
                return UploadProgressWidget(
                  progress: state.uploadProgress,
                  status: state.status,
                  totalUploads: state.totalUploads,
                  completedUploads: state.completedUploads,
                  onCancel: () {
                    context.read<MediaUploadBloc>().add(const CancelUpload());
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMediaTab('image'),
                _buildMediaTab('document'),
                _buildMediaTab('video'),
                _buildMediaTab(null), // All files
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quick Upload Buttons
          FloatingActionButton.small(
            onPressed: _pickMultipleImages,
            heroTag: 'multiple_images',
            child: const Icon(Icons.photo_library_outlined),
            tooltip: 'Upload Multiple Images',
          ),
          const SizedBox(height: 8),
          // Main Upload Button
          FloatingActionButton(
            onPressed: _showUploadOptions,
            heroTag: 'upload',
            child: const Icon(Icons.cloud_upload),
            tooltip: 'Upload Media',
          ),
        ],
      ),
    );
  }

  Widget _buildMediaTab(String? fileType) {
    return BlocBuilder<MediaUploadBloc, MediaUploadState>(
      builder: (context, state) {
        List<Map<String, dynamic>> filteredMedia;

        if (fileType == null) {
          filteredMedia = state.uploadedMedia;
        } else {
          filteredMedia = state.uploadedMedia
              .where((media) => MediaUploadState.getMediaType(media) == fileType)
              .toList();
        }

        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.isError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading media',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  state.errorMessage ?? 'Unknown error occurred',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    context.read<MediaUploadBloc>().add(LoadUploadedMedia());
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        if (filteredMedia.isEmpty) {
          return _buildEmptyState(context, fileType);
        }

        return Column(
          children: [
            // Media Summary Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${filteredMedia.length} ${fileType ?? 'file'}${filteredMedia.length == 1 ? '' : 's'}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (filteredMedia.isNotEmpty) ...[
                    Text(
                      _calculateTotalSize(filteredMedia),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: () => _showFilterOptions(context, fileType),
                      icon: const Icon(Icons.filter_list),
                      tooltip: 'Filter',
                    ),
                  ],
                ],
              ),
            ),

            // Media Grid
            Expanded(
              child: MediaGridWidget(
                mediaItems: filteredMedia,
                onMediaSelected: (media) => _showMediaDetails(context, media),
                onMediaDeleted: (media) => _deleteMedia(context, media),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, String? fileType) {
    String title, description, icon;

    switch (fileType) {
      case 'image':
        title = 'No images yet';
        description = 'Upload images for your dishes, restaurant, and promotions';
        icon = '📷';
        break;
      case 'document':
        title = 'No documents yet';
        description = 'Upload permits, menus, and other business documents';
        icon = '📄';
        break;
      case 'video':
        title = 'No videos yet';
        description = 'Upload promotional videos and restaurant tours';
        icon = '🎬';
        break;
      default:
        title = 'No media yet';
        description = 'Start uploading your media files';
        icon = '📁';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  if (fileType == 'image') {
                    _pickImages();
                  } else {
                    _pickFiles(fileType);
                  }
                },
                icon: const Icon(Icons.add),
                label: Text('Upload ${fileType ?? 'Files'}'),
              ),
              const SizedBox(width: 16),
              if (fileType == 'image')
                OutlinedButton.icon(
                  onPressed: _takePhoto,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take Photo'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showUploadOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Upload Media',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _UploadOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImages();
                  },
                ),
                _UploadOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Navigator.of(context).pop();
                    _takePhoto();
                  },
                ),
                _UploadOption(
                  icon: Icons.description,
                  label: 'Documents',
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickFiles(null);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _UploadOption(
                  icon: Icons.videocam,
                  label: 'Video',
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickVideo();
                  },
                ),
                _UploadOption(
                  icon: Icons.multiple,
                  label: 'Multiple',
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickMultipleImages();
                  },
                ),
                _UploadOption(
                  icon: Icons.folder,
                  label: 'Browse',
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickFiles(null);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    final pickedFiles = await _imagePicker.pickMultiImage(
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 85,
    );

    if (pickedFiles.isNotEmpty) {
      for (final pickedFile in pickedFiles) {
        final file = File(pickedFile.path);
        context.read<MediaUploadBloc>().add(UploadImage(
          file: file,
          category: 'Gallery Upload',
        ));
      }
    }
  }

  Future<void> _pickMultipleImages() async {
    final pickedFiles = await _imagePicker.pickMultiImage(
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (pickedFiles.isNotEmpty) {
      final files = pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();
      context.read<MediaUploadBloc>().add(UploadMultipleImages(
        files: files,
        category: 'Batch Upload',
      ));
    }
  }

  Future<void> _takePhoto() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      context.read<MediaUploadBloc>().add(UploadImage(
        file: file,
        category: 'Camera Upload',
      ));
    }
  }

  Future<void> _pickVideo() async {
    final pickedFile = await _imagePicker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 5),
    );

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      context.read<MediaUploadBloc>().add(UploadFile(
        file: file,
        category: 'Video',
      ));
    }
  }

  Future<void> _pickFiles(String? fileType) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _getAllowedExtensions(fileType),
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      for (final file in result.files) {
        if (file.path != null) {
          final filePath = File(file.path!);
          context.read<MediaUploadBloc>().add(UploadFile(
            file: filePath,
            category: fileType ?? 'Document',
          ));
        }
      }
    }
  }

  List<String> _getAllowedExtensions(String? fileType) {
    switch (fileType) {
      case 'image':
        return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];
      case 'document':
        return ['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx'];
      case 'video':
        return ['mp4', 'mov', 'avi', 'mkv', 'webm'];
      default:
        return ['jpg', 'jpeg', 'png', 'gif', 'pdf', 'doc', 'docx', 'txt'];
    }
  }

  void _showMediaDetails(BuildContext context, Map<String, dynamic> media) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: MediaDetailsWidget(media: media),
      ),
    );
  }

  void _deleteMedia(BuildContext context, Map<String, dynamic> media) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Media'),
        content: Text('Are you sure you want to delete "${MediaUploadState.getMediaName(media)}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<MediaUploadBloc>().add(DeleteMedia(
                mediaId: media['id'] as String,
                filePath: media['file_path'] as String,
              ));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions(BuildContext context, String? fileType) {
    // TODO: Implement filter options
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filter options coming soon')),
    );
  }

  void _showStorageInfo(BuildContext context, MediaUploadState state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Storage Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total files: ${state.uploadedMedia.length}'),
            Text('Total size: ${state.formattedTotalFileSize}'),
            const SizedBox(height: 16),
            const Text('Breakdown:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Images: ${state.images.length}'),
            Text('Documents: ${state.documents.length}'),
            Text('Videos: ${state.videos.length}'),
            Text('Other: ${state.otherFiles.length}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _calculateTotalSize(List<Map<String, dynamic>> mediaList) {
    final totalBytes = mediaList.fold<int>(
      0,
      (total, media) => total + (MediaUploadState.getMediaSize(media)),
    );
    return MediaUploadState._formatFileSize(totalBytes);
  }
}

class _UploadOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _UploadOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}