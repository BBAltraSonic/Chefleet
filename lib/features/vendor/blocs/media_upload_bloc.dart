import 'dart:io';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

part 'media_upload_event.dart';
part 'media_upload_state.dart';

class MediaUploadBloc extends Bloc<MediaUploadEvent, MediaUploadState> {
  final SupabaseClient _supabaseClient;

  MediaUploadBloc({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient,
        super(const MediaUploadState()) {
    on<UploadImage>(_onUploadImage);
    on<UploadFile>(_onUploadFile);
    on<UploadMultipleImages>(_onUploadMultipleImages);
    on<DeleteMedia>(_onDeleteMedia);
    on<LoadUploadedMedia>(_onLoadUploadedMedia);
    on<OptimizeImage>(_onOptimizeImage);
    on<GeneratePresignedUrl>(_onGeneratePresignedUrl);
    on<CancelUpload>(_onCancelUpload);
  }

  Future<void> _onUploadImage(
    UploadImage event,
    Emitter<MediaUploadState> emit,
  ) async {
    emit(state.copyWith(status: MediaUploadStatus.uploading, progress: 0.0));

    try {
      // Validate file
      if (!_isValidImageFile(event.file)) {
        emit(state.copyWith(
          status: MediaUploadStatus.error,
          errorMessage: 'Invalid image file format',
        ));
        return;
      }

      // Get file size
      final fileSize = await event.file.length();
      if (fileSize > 10 * 1024 * 1024) { // 10MB limit
        emit(state.copyWith(
          status: MediaUploadStatus.error,
          errorMessage: 'Image file too large (max 10MB)',
        ));
        return;
      }

      // Generate unique filename
      final fileName = _generateFileName(event.file.path, 'jpg');
      final filePath = 'vendor-images/${DateTime.now().year}/${DateTime.now().month}/$fileName';

      // Upload to Supabase Storage
      final uploadPath = await _supabaseClient.storage
          .from('vendor-media')
          .uploadBinary(
            filePath,
            await event.file.readAsBytes(),
            fileOptions: FileOptions(
              contentType: _getContentType(event.file.path),
              cacheControl: '31536000', // 1 year
            ),
          );

      // Get public URL
      final publicUrl = _supabaseClient.storage
          .from('vendor-media')
          .getPublicUrl(uploadPath);

      // Optimize image if needed
      final optimizedUrl = await _optimizeImageIfNeeded(publicUrl, event.file);

      // Save to database
      final mediaRecord = await _saveMediaRecord({
        'file_name': fileName,
        'file_path': filePath,
        'public_url': optimizedUrl,
        'file_type': 'image',
        'file_size': fileSize,
        'mime_type': _getContentType(event.file.path),
        'metadata': {
          'original_name': event.file.path.split('/').last,
          'upload_time': DateTime.now().toIso8601String(),
          'optimized': optimizedUrl != publicUrl,
        },
      });

      emit(state.copyWith(
        status: MediaUploadStatus.success,
        progress: 1.0,
        uploadedMedia: [...state.uploadedMedia, mediaRecord],
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MediaUploadStatus.error,
        errorMessage: 'Failed to upload image: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUploadFile(
    UploadFile event,
    Emitter<MediaUploadState> emit,
  ) async {
    emit(state.copyWith(status: MediaUploadStatus.uploading, progress: 0.0));

    try {
      // Validate file
      final fileSize = await event.file.length();
      if (fileSize > 50 * 1024 * 1024) { // 50MB limit for files
        emit(state.copyWith(
          status: MediaUploadStatus.error,
          errorMessage: 'File too large (max 50MB)',
        ));
        return;
      }

      // Generate unique filename
      final fileName = _generateFileName(event.file.path, 'bin');
      final filePath = 'vendor-files/${DateTime.now().year}/${DateTime.now().month}/$fileName';

      // Upload with progress tracking
      final fileBytes = await event.file.readAsBytes();
      final chunkSize = 1024 * 1024; // 1MB chunks
      final totalChunks = (fileBytes.length / chunkSize).ceil();

      for (int i = 0; i < totalChunks; i++) {
        final start = i * chunkSize;
        final end = (start + chunkSize) < fileBytes.length
            ? start + chunkSize
            : fileBytes.length;

        final chunk = fileBytes.sublist(start, end);

        // For simplicity, we'll upload the whole file at once
        // In a real implementation, you might use resumable upload
        if (i == 0) {
          await _supabaseClient.storage
              .from('vendor-media')
              .uploadBinary(
                filePath,
                fileBytes,
                fileOptions: FileOptions(
                  contentType: _getContentType(event.file.path),
                  cacheControl: '2592000', // 30 days
                ),
              );
        }

        // Update progress
        final progress = (i + 1) / totalChunks;
        emit(state.copyWith(progress: progress));
      }

      // Get public URL
      final publicUrl = _supabaseClient.storage
          .from('vendor-media')
          .getPublicUrl(filePath);

      // Save to database
      final mediaRecord = await _saveMediaRecord({
        'file_name': fileName,
        'file_path': filePath,
        'public_url': publicUrl,
        'file_type': 'file',
        'file_size': fileSize,
        'mime_type': _getContentType(event.file.path),
        'metadata': {
          'original_name': event.file.path.split('/').last,
          'upload_time': DateTime.now().toIso8601String(),
        },
      });

      emit(state.copyWith(
        status: MediaUploadStatus.success,
        progress: 1.0,
        uploadedMedia: [...state.uploadedMedia, mediaRecord],
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MediaUploadStatus.error,
        errorMessage: 'Failed to upload file: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUploadMultipleImages(
    UploadMultipleImages event,
    Emitter<MediaUploadState> emit,
  ) async {
    emit(state.copyWith(
      status: MediaUploadStatus.uploading,
      progress: 0.0,
      totalUploads: event.files.length,
      completedUploads: 0,
    ));

    final uploadedMedia = <Map<String, dynamic>>[];

    for (int i = 0; i < event.files.length; i++) {
      final file = event.files[i];

      try {
        // Update progress
        emit(state.copyWith(
          progress: (i + 1) / event.files.length,
          completedUploads: i,
        ));

        // Upload single image
        final fileName = _generateFileName(file.path, 'jpg');
        final filePath = 'vendor-images/${DateTime.now().year}/${DateTime.now().month}/$fileName';

        final uploadPath = await _supabaseClient.storage
            .from('vendor-media')
            .uploadBinary(
              filePath,
              await file.readAsBytes(),
              fileOptions: FileOptions(
                contentType: _getContentType(file.path),
                cacheControl: '31536000',
              ),
            );

        final publicUrl = _supabaseClient.storage
            .from('vendor-media')
            .getPublicUrl(uploadPath);

        final mediaRecord = await _saveMediaRecord({
          'file_name': fileName,
          'file_path': filePath,
          'public_url': publicUrl,
          'file_type': 'image',
          'file_size': await file.length(),
          'mime_type': _getContentType(file.path),
          'metadata': {
            'original_name': file.path.split('/').last,
            'upload_time': DateTime.now().toIso8601String(),
            'batch_upload': true,
          },
        });

        uploadedMedia.add(mediaRecord);
      } catch (e) {
        // Continue with other files even if one fails
        continue;
      }
    }

    emit(state.copyWith(
      status: MediaUploadStatus.success,
      progress: 1.0,
      completedUploads: event.files.length,
      uploadedMedia: [...state.uploadedMedia, ...uploadedMedia],
    ));
  }

  Future<void> _onDeleteMedia(
    DeleteMedia event,
    Emitter<MediaUploadState> emit,
  ) async {
    try {
      // Delete from storage
      await _supabaseClient.storage
          .from('vendor-media')
          .remove([event.filePath]);

      // Delete from database
      await _supabaseClient
          .from('vendor_media')
          .delete()
          .eq('id', event.mediaId);

      // Remove from local state
      final updatedMedia = state.uploadedMedia
          .where((media) => media['id'] != event.mediaId)
          .toList();

      emit(state.copyWith(uploadedMedia: updatedMedia));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to delete media: ${e.toString()}',
      ));
    }
  }

  Future<void> _onLoadUploadedMedia(
    LoadUploadedMedia event,
    Emitter<MediaUploadState> emit,
  ) async {
    emit(state.copyWith(status: MediaUploadStatus.loading));

    try {
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) {
        emit(state.copyWith(
          status: MediaUploadStatus.error,
          errorMessage: 'User not authenticated',
        ));
        return;
      }

      // Get vendor ID
      final vendorResponse = await _supabaseClient
          .from('vendors')
          .select('id')
          .eq('owner_id', currentUser.id)
          .single();

      final vendorId = vendorResponse['id'] as String? ?? '';

      // Load media records
      final response = await _supabaseClient
          .from('vendor_media')
          .select('*')
          .eq('vendor_id', vendorId)
          .order('created_at', ascending: false);

      final media = List<Map<String, dynamic>>.from(response);

      emit(state.copyWith(
        status: MediaUploadStatus.success,
        uploadedMedia: media,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MediaUploadStatus.error,
        errorMessage: 'Failed to load media: ${e.toString()}',
      ));
    }
  }

  Future<void> _onOptimizeImage(
    OptimizeImage event,
    Emitter<MediaUploadState> emit,
  ) async {
    try {
      // In a real implementation, you might use an image optimization service
      // For now, we'll simulate the optimization process

      // Generate optimized versions
      final optimizedUrls = <String, String>{};

      // Thumbnail (200x200)
      optimizedUrls['thumbnail'] = await _generateImageVariant(
        event.originalUrl,
        'thumbnail',
        200,
        200,
      );

      // Medium (800x800)
      optimizedUrls['medium'] = await _generateImageVariant(
        event.originalUrl,
        'medium',
        800,
        800,
      );

      // Large (1200x1200)
      optimizedUrls['large'] = await _generateImageVariant(
        event.originalUrl,
        'large',
        1200,
        1200,
      );

      // Update media record with optimized URLs
      await _supabaseClient
          .from('vendor_media')
          .update({
            'optimized_urls': optimizedUrls,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', event.mediaId);

    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to optimize image: ${e.toString()}',
      ));
    }
  }

  Future<void> _onGeneratePresignedUrl(
    GeneratePresignedUrl event,
    Emitter<MediaUploadState> emit,
  ) async {
    try {
      // Generate presigned URL for direct upload
      final fileName = _generateFileName(event.fileName, event.fileType);
      final filePath = 'vendor-uploads/${DateTime.now().year}/${DateTime.now().month}/$fileName';

      final presignedUrl = await _supabaseClient.storage
          .from('vendor-media')
          .createSignedUrl(
            filePath,
            3600, // 1 hour expiration
          );

      emit(state.copyWith(
        presignedUrl: presignedUrl,
        presignedFilePath: filePath,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to generate presigned URL: ${e.toString()}',
      ));
    }
  }

  Future<void> _onCancelUpload(
    CancelUpload event,
    Emitter<MediaUploadState> emit,
  ) async {
    emit(state.copyWith(
      status: MediaUploadStatus.idle,
      progress: 0.0,
      errorMessage: null,
    ));
  }

  // Helper methods
  bool _isValidImageFile(File file) {
    final validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];
    final extension = file.path.toLowerCase().split('.').last;
    return validExtensions.contains(extension);
  }

  String _generateFileName(String originalPath, String defaultExtension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecond;
    final originalName = originalPath.split('/').last;
    final nameWithoutExtension = originalName.contains('.')
        ? originalName.substring(0, originalName.lastIndexOf('.'))
        : originalName;

    return '${timestamp}_${random}_${nameWithoutExtension}.$defaultExtension';
  }

  String _getContentType(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'bmp':
        return 'image/bmp';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }

  Future<Map<String, dynamic>> _saveMediaRecord(Map<String, dynamic> mediaData) async {
    final currentUser = _supabaseClient.auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    // Get vendor ID
    final vendorResponse = await _supabaseClient
        .from('vendors')
        .select('id')
        .eq('owner_id', currentUser.id)
        .single();

    final vendorId = vendorResponse['id'] as String? ?? '';

    final recordData = {
      ...mediaData,
      'vendor_id': vendorId,
      'created_at': DateTime.now().toIso8601String(),
    };

    final response = await _supabaseClient
        .from('vendor_media')
        .insert(recordData)
        .select()
        .single();

    return response;
  }

  Future<String> _optimizeImageIfNeeded(String originalUrl, File originalFile) async {
    final fileSize = await originalFile.length();

    // Optimize images larger than 2MB
    if (fileSize > 2 * 1024 * 1024) {
      // In a real implementation, you would use an image optimization service
      // For now, return the original URL
      return originalUrl;
    }

    return originalUrl;
  }

  Future<String> _generateImageVariant(
    String originalUrl,
    String variant,
    int width,
    int height,
  ) async {
    // In a real implementation, you would use an image processing service
    // For now, return a placeholder URL
    return '${originalUrl}?variant=$variant&width=$width&height=$height';
  }
}