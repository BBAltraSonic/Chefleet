import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_strings.dart';

class ChatInputWidget extends StatefulWidget {
  final String conversationId;
  final Function(String content, String messageType, String? mediaUrl) onSendMessage;

  const ChatInputWidget({
    super.key,
    required this.conversationId,
    required this.onSendMessage,
  });

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isTyping = false;
  File? _selectedFile;
  String? _mediaUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isTyping = _focusNode.hasFocus;
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty && _selectedFile == null) {
      return;
    }

    final content = _messageController.text.trim();
    final messageType = _selectedFile != null ? _getFileType() : 'text';

    widget.onSendMessage(
      content.isNotEmpty ? content : (_selectedFile != null ? AppStrings.sharedFile : ''),
      messageType,
      _mediaUrl,
    );

    // Clear input
    _messageController.clear();
    setState(() {
      _selectedFile = null;
      _mediaUrl = null;
    });

    // Keep focus for continuous typing
    _focusNode.requestFocus();
  }

  String _getFileType() {
    if (_selectedFile == null) return 'text';

    final extension = _selectedFile!.path.toLowerCase().split('.').last;
    if (['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(extension)) {
      return 'image';
    } else if (['mp4', 'mov', 'avi', 'mkv'].contains(extension)) {
      return 'video';
    } else if (['mp3', 'wav', 'm4a', 'aac'].contains(extension)) {
      return 'audio';
    } else {
      return 'file';
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      await _handleFileSelection(File(pickedFile.path));
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      await _handleFileSelection(File(pickedFile.path));
    }
  }

  Future<void> _pickFile() async {
    // Note: file_picker package would be needed for actual file picking
    // For now, we'll just show a placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.filePickerNotImplemented)),
    );
  }

  Future<void> _handleFileSelection(File file) async {
    setState(() {
      _selectedFile = file;
      _isUploading = true;
    });

    try {
      // Simulate upload process
      await Future.delayed(const Duration(seconds: 1));

      // In a real implementation, you would upload to a service like Supabase Storage
      // and get back a URL
      setState(() {
        _mediaUrl = 'https://placeholder.url/${file.path.split('/').last}';
        _isUploading = false;
      });
    } catch (e) {
      setState(() {
        _selectedFile = null;
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.uploadFileError}${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
      _mediaUrl = null;
    });
  }

  void _showMediaOptions() {
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
              AppStrings.shareMedia,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _MediaOption(
                  icon: Icons.photo_library,
                  label: AppStrings.gallery,
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage();
                  },
                ),
                _MediaOption(
                  icon: Icons.camera_alt,
                  label: AppStrings.camera,
                  onTap: () {
                    Navigator.of(context).pop();
                    _takePhoto();
                  },
                ),
                _MediaOption(
                  icon: Icons.attach_file,
                  label: AppStrings.file,
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickFile();
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          // File preview
          if (_selectedFile != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _getFileIcon(),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedFile!.path.split('/').last,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (_isUploading)
                          Text(
                            AppStrings.uploading,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (!_isUploading)
                    IconButton(
                      onPressed: _removeFile,
                      icon: const Icon(Icons.close),
                      tooltip: AppStrings.tooltipRemoveFile,
                    ),
                  if (_isUploading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Input row
          Row(
            children: [
              // Media button
              IconButton(
                onPressed: _showMediaOptions,
                icon: const Icon(Icons.add_circle_outline),
                tooltip: AppStrings.tooltipAddMedia,
              ),

              // Text input
              Expanded(
                child: TextField(
                  controller: _messageController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: AppStrings.typeMessage,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceVariant,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    suffixIcon: _messageController.text.isNotEmpty
                        ? IconButton(
                            onPressed: _messageController.clear,
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (value) {
                    setState(() {});
                  },
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),

              const SizedBox(width: 8),

              // Send button
              Container(
                decoration: BoxDecoration(
                  color: (_messageController.text.trim().isNotEmpty || _selectedFile != null)
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: (_messageController.text.trim().isNotEmpty || _selectedFile != null) &&
                          !_isUploading
                      ? _sendMessage
                      : null,
                  icon: Icon(
                    Icons.send,
                    color: (_messageController.text.trim().isNotEmpty || _selectedFile != null)
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.outline,
                  ),
                  tooltip: AppStrings.tooltipSendMessage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon() {
    final fileType = _getFileType();
    switch (fileType) {
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.videocam;
      case 'audio':
        return Icons.audiotrack;
      default:
        return Icons.insert_drive_file;
    }
  }
}

class _MediaOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MediaOption({
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