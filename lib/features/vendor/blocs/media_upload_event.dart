part of 'media_upload_bloc.dart';

abstract class MediaUploadEvent extends Equatable {
  const MediaUploadEvent();

  @override
  List<Object> get props => [];
}

class UploadImage extends MediaUploadEvent {
  final File file;
  final String? category;
  final Map<String, dynamic>? metadata;

  const UploadImage({
    required this.file,
    this.category,
    this.metadata,
  });

  @override
  List<Object> get props => [file, category ?? '', metadata ?? {}];
}

class UploadFile extends MediaUploadEvent {
  final File file;
  final String? category;
  final Map<String, dynamic>? metadata;

  const UploadFile({
    required this.file,
    this.category,
    this.metadata,
  });

  @override
  List<Object> get props => [file, category ?? '', metadata ?? {}];
}

class UploadMultipleImages extends MediaUploadEvent {
  final List<File> files;
  final String? category;

  const UploadMultipleImages({
    required this.files,
    this.category,
  });

  @override
  List<Object> get props => [files, category ?? ''];
}

class DeleteMedia extends MediaUploadEvent {
  final String mediaId;
  final String filePath;

  const DeleteMedia({
    required this.mediaId,
    required this.filePath,
  });

  @override
  List<Object> get props => [mediaId, filePath];
}

class LoadUploadedMedia extends MediaUploadEvent {
  final String? category;
  final String? fileType;

  const LoadUploadedMedia({
    this.category,
    this.fileType,
  });

  @override
  List<Object> get props => [category ?? '', fileType ?? ''];
}

class OptimizeImage extends MediaUploadEvent {
  final String mediaId;
  final String originalUrl;

  const OptimizeImage({
    required this.mediaId,
    required this.originalUrl,
  });

  @override
  List<Object> get props => [mediaId, originalUrl];
}

class GeneratePresignedUrl extends MediaUploadEvent {
  final String fileName;
  final String fileType;
  final String? category;

  const GeneratePresignedUrl({
    required this.fileName,
    required this.fileType,
    this.category,
  });

  @override
  List<Object> get props => [fileName, fileType, category ?? ''];
}

class CancelUpload extends MediaUploadEvent {
  const CancelUpload();
}

class UpdateMediaMetadata extends MediaUploadEvent {
  final String mediaId;
  final Map<String, dynamic> metadata;

  const UpdateMediaMetadata({
    required this.mediaId,
    required this.metadata,
  });

  @override
  List<Object> get props => [mediaId, metadata];
}

class SearchMedia extends MediaUploadEvent {
  final String query;
  final String? category;
  final String? fileType;

  const SearchMedia({
    required this.query,
    this.category,
    this.fileType,
  });

  @override
  List<Object> get props => [query, category ?? '', fileType ?? ''];
}

class FilterMedia extends MediaUploadEvent {
  final String? category;
  final String? fileType;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? minSize;
  final int? maxSize;

  const FilterMedia({
    this.category,
    this.fileType,
    this.startDate,
    this.endDate,
    this.minSize,
    this.maxSize,
  });

  @override
  List<Object> get props => [
        if (category != null) category!,
        if (fileType != null) fileType!,
        if (startDate != null) startDate!,
        if (endDate != null) endDate!,
        if (minSize != null) minSize!,
        if (maxSize != null) maxSize!,
      ];
}