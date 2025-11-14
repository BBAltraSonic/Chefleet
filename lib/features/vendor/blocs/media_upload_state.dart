part of 'media_upload_bloc.dart';

enum MediaUploadStatus {
  initial,
  idle,
  loading,
  uploading,
  success,
  error,
  optimizing,
}

class MediaUploadState extends Equatable {
  final List<Map<String, dynamic>> uploadedMedia;
  final MediaUploadStatus status;
  final String? errorMessage;
  final double progress;
  final int totalUploads;
  final int completedUploads;
  final String? presignedUrl;
  final String? presignedFilePath;
  final Map<String, dynamic>? currentUploadMetadata;

  const MediaUploadState({
    this.uploadedMedia = const [],
    this.status = MediaUploadStatus.initial,
    this.errorMessage,
    this.progress = 0.0,
    this.totalUploads = 0,
    this.completedUploads = 0,
    this.presignedUrl,
    this.presignedFilePath,
    this.currentUploadMetadata,
  });

  MediaUploadState copyWith({
    List<Map<String, dynamic>>? uploadedMedia,
    MediaUploadStatus? status,
    String? errorMessage,
    double? progress,
    int? totalUploads,
    int? completedUploads,
    String? presignedUrl,
    String? presignedFilePath,
    Map<String, dynamic>? currentUploadMetadata,
    bool clearErrorMessage = false,
  }) {
    return MediaUploadState(
      uploadedMedia: uploadedMedia ?? this.uploadedMedia,
      status: status ?? this.status,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      progress: progress ?? this.progress,
      totalUploads: totalUploads ?? this.totalUploads,
      completedUploads: completedUploads ?? this.completedUploads,
      presignedUrl: presignedUrl ?? this.presignedUrl,
      presignedFilePath: presignedFilePath ?? this.presignedFilePath,
      currentUploadMetadata: currentUploadMetadata ?? this.currentUploadMetadata,
    );
  }

  @override
  List<Object?> get props => [
        uploadedMedia,
        status,
        errorMessage,
        progress,
        totalUploads,
        completedUploads,
        presignedUrl,
        presignedFilePath,
        currentUploadMetadata,
      ];

  // Getters for convenience
  bool get isInitial => status == MediaUploadStatus.initial;
  bool get isIdle => status == MediaUploadStatus.idle;
  bool get isLoading => status == MediaUploadStatus.loading;
  bool get isUploading => status == MediaUploadStatus.uploading;
  bool get isSuccess => status == MediaUploadStatus.success;
  bool get isError => status == MediaUploadStatus.error;
  bool get isOptimizing => status == MediaUploadStatus.optimizing;
  bool get hasError => errorMessage != null;
  bool get hasUploadedMedia => uploadedMedia.isNotEmpty;

  // Upload progress getters
  double get uploadProgress => totalUploads > 0 ? completedUploads / totalUploads : progress;
  String get progressPercentage => '${(uploadProgress * 100).round()}%';
  String get progressText => totalUploads > 1
      ? '$completedUploads of $totalUploads files'
      : 'Uploading...';

  // File type filters
  List<Map<String, dynamic>> get images => uploadedMedia
      .where((media) => media['file_type'] == 'image')
      .toList();

  List<Map<String, dynamic>> get documents => uploadedMedia
      .where((media) => media['file_type'] == 'document')
      .toList();

  List<Map<String, dynamic>> get videos => uploadedMedia
      .where((media) => media['file_type'] == 'video')
      .toList();

  List<Map<String, dynamic>> get otherFiles => uploadedMedia
      .where((media) => !['image', 'document', 'video'].contains(media['file_type']))
      .toList();

  // Storage statistics
  int get totalFileSize => uploadedMedia.fold<int>(
        0,
        (total, media) => total + (media['file_size'] as int? ?? 0),
      );

  String get formattedTotalFileSize => _formatFileSize(totalFileSize);

  // Date filtering
  List<Map<String, dynamic>> get mediaFromLastWeek {
    final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
    return uploadedMedia.where((media) {
      final createdAt = DateTime.tryParse(media['created_at'] ?? '');
      return createdAt != null && createdAt.isAfter(oneWeekAgo);
    }).toList();
  }

  List<Map<String, dynamic>> get mediaFromLastMonth {
    final oneMonthAgo = DateTime.now().subtract(const Duration(days: 30));
    return uploadedMedia.where((media) {
      final createdAt = DateTime.tryParse(media['created_at'] ?? '');
      return createdAt != null && createdAt.isAfter(oneMonthAgo);
    }).toList();
  }

  // Media item helpers
  static String getMediaName(Map<String, dynamic> media) {
    return media['file_name'] as String? ?? 'Unknown';
  }

  static String getMediaUrl(Map<String, dynamic> media) {
    return media['public_url'] as String? ?? '';
  }

  static String getMediaType(Map<String, dynamic> media) {
    return media['file_type'] as String? ?? 'unknown';
  }

  static int getMediaSize(Map<String, dynamic> media) {
    return media['file_size'] as int? ?? 0;
  }

  static String getFormattedMediaSize(Map<String, dynamic> media) {
    final size = getMediaSize(media);
    return _formatFileSize(size);
  }

  static DateTime? getMediaUploadDate(Map<String, dynamic> media) {
    return DateTime.tryParse(media['created_at'] ?? '');
  }

  static String getFormattedUploadDate(Map<String, dynamic> media) {
    final date = getMediaUploadDate(media);
    if (date == null) return 'Unknown';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  static bool isImage(Map<String, dynamic> media) {
    return getMediaType(media) == 'image';
  }

  static bool isDocument(Map<String, dynamic> media) {
    return getMediaType(media) == 'document';
  }

  static bool isVideo(Map<String, dynamic> media) {
    return getMediaType(media) == 'video';
  }

  static String getFileExtension(String fileName) {
    return fileName.contains('.') ? fileName.split('.').last.toLowerCase() : '';
  }

  static String getContentType(Map<String, dynamic> media) {
    return media['mime_type'] as String? ?? 'application/octet-stream';
  }

  static Map<String, dynamic>? getMetadata(Map<String, dynamic> media) {
    return media['metadata'] as Map<String, dynamic>?;
  }

  static Map<String, String>? getOptimizedUrls(Map<String, dynamic> media) {
    return media['optimized_urls'] as Map<String, String>?;
  }

  static String getOptimizedUrl(
    Map<String, dynamic> media,
    String variant, // 'thumbnail', 'medium', 'large'
  ) {
    final optimizedUrls = getOptimizedUrls(media);
    return optimizedUrls?[variant] ?? getMediaUrl(media);
  }

  // Validation helpers
  static bool isValidImageFile(String fileName) {
    final validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];
    final extension = getFileExtension(fileName);
    return validExtensions.contains(extension);
  }

  static bool isValidVideoFile(String fileName) {
    final validExtensions = ['mp4', 'mov', 'avi', 'mkv', 'webm'];
    final extension = getFileExtension(fileName);
    return validExtensions.contains(extension);
  }

  static bool isValidDocumentFile(String fileName) {
    final validExtensions = ['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx'];
    final extension = getFileExtension(fileName);
    return validExtensions.contains(extension);
  }

  static bool isFileSizeValid(int fileSize, String fileType) {
    switch (fileType.toLowerCase()) {
      case 'image':
        return fileSize <= 10 * 1024 * 1024; // 10MB
      case 'video':
        return fileSize <= 100 * 1024 * 1024; // 100MB
      case 'document':
        return fileSize <= 20 * 1024 * 1024; // 20MB
      default:
        return fileSize <= 50 * 1024 * 1024; // 50MB
    }
  }

  // Private helper method
  static String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  // Category helpers
  static const List<String> defaultCategories = [
    'Dish Photos',
    'Menu Items',
    'Restaurant',
    'Logo',
    'Documents',
    'Promotions',
    'Other',
  ];

  static String getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'dish photos':
      case 'menu items':
        return '🍽️';
      case 'restaurant':
        return '🏪';
      case 'logo':
        return '🎨';
      case 'documents':
        return '📄';
      case 'promotions':
        return '📢';
      default:
        return '📁';
    }
  }

  // URL helpers
  static String getThumbnailUrl(Map<String, dynamic> media) {
    return getOptimizedUrl(media, 'thumbnail');
  }

  static String getMediumUrl(Map<String, dynamic> media) {
    return getOptimizedUrl(media, 'medium');
  }

  static String getLargeUrl(Map<String, dynamic> media) {
    return getOptimizedUrl(media, 'large');
  }

  // Search helpers
  static bool matchesQuery(Map<String, dynamic> media, String query) {
    final fileName = getMediaName(media).toLowerCase();
    final fileType = getMediaType(media).toLowerCase();
    final metadata = getMetadata(media);

    if (fileName.contains(query.toLowerCase())) {
      return true;
    }

    if (fileType.contains(query.toLowerCase())) {
      return true;
    }

    if (metadata != null) {
      final originalName = (metadata['original_name'] as String? ?? '').toLowerCase();
      if (originalName.contains(query.toLowerCase())) {
        return true;
      }
    }

    return false;
  }
}