import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/dish_categories.dart';
import '../../feed/models/dish_model.dart';
import '../blocs/menu_management_bloc.dart';

class DishEditScreen extends StatefulWidget {
  final Dish? dish;

  const DishEditScreen({super.key, this.dish});

  @override
  State<DishEditScreen> createState() => _DishEditScreenState();
}

class _DishEditScreenState extends State<DishEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _longDescriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _prepTimeController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _allergensController = TextEditingController();

  String? _selectedCategory;
  String? _imageUrl;
  File? _imageFile;
  bool _available = true;
  bool _isFeatured = false;
  int _spiceLevel = 0;
  List<String> _dietaryRestrictions = [];

  // Use standardized category display names that map to database enum values
  final List<String> _categories = DishCategories.displayNames;

  final List<String> _dietaryOptions = [
    'Vegetarian',
    'Vegan',
    'Gluten-Free',
    'Dairy-Free',
    'Nut-Free',
    'Halal',
    'Kosher',
    'Low-Carb',
    'Keto',
    'Low-Sodium',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.dish != null) {
      _initializeForm();
    }
  }

  void _initializeForm() {
    final dish = widget.dish!;
    _nameController.text = dish.name;
    _descriptionController.text = dish.description ?? '';
    _longDescriptionController.text = dish.descriptionLong ?? '';
    _priceController.text = (dish.priceCents / 100).toStringAsFixed(2);
    _prepTimeController.text = dish.preparationTimeMinutes.toString() ?? '';
    _ingredientsController.text = dish.ingredients?.join(', ') ?? '';
    _allergensController.text = dish.allergens.join(', ') ?? '';
    // Convert database enum value to display name for UI
    _selectedCategory = DishCategories.toDisplayName(dish.categoryEnum);
    _imageUrl = dish.imageUrl;
    _available = dish.available;
    _isFeatured = dish.isFeatured ?? false;
    _spiceLevel = dish.spiceLevel ?? 0;
    _dietaryRestrictions = List.from(dish.dietaryRestrictions ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _longDescriptionController.dispose();
    _priceController.dispose();
    _prepTimeController.dispose();
    _ingredientsController.dispose();
    _allergensController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      // Request storage/photos permission
      PermissionStatus status;
      if (Platform.isAndroid) {
        // Android 13+ uses photos permission
        if (await Permission.photos.isGranted) {
          status = PermissionStatus.granted;
        } else {
          status = await Permission.photos.request();
        }
      } else {
        status = await Permission.photos.request();
      }
      
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Storage permission is required to select images'),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: openAppSettings,
              ),
            ),
          );
        }
        return;
      }

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Validate file size (max 5MB)
        final file = File(pickedFile.path);
        final fileSize = await file.length();
        if (fileSize > 5 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image size must be less than 5MB'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        // Validate file type
        final extension = pickedFile.path.split('.').last.toLowerCase();
        if (!['jpg', 'jpeg', 'png', 'webp'].contains(extension)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Only JPG, PNG, and WebP images are supported'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        setState(() {
          _imageFile = file;
          _imageUrl = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final fileSize = await file.length();
        if (fileSize > 5 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image size must be less than 5MB'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        setState(() {
          _imageFile = file;
          _imageUrl = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error taking photo: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveDish(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final progressMessage = ValueNotifier<String>('Preparing...');
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ValueListenableBuilder<String>(
            valueListenable: progressMessage,
            builder: (context, message, child) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 16),
                Flexible(child: Text(message)),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      String? finalImageUrl = _imageUrl;
      if (_imageFile != null) {
        progressMessage.value = 'Uploading image...';
        try {
          finalImageUrl = await _uploadImageToSupabase(_imageFile!);
        } on TimeoutException catch (e) {
          if (mounted) {
            Navigator.of(context, rootNavigator: true).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Upload timeout: ${e.message ?? "Connection too slow"}'),
                backgroundColor: Colors.orange,
                action: SnackBarAction(
                  label: 'Retry',
                  onPressed: () => _saveDish(context),
                ),
              ),
            );
          }
          return;
        }
        
        if (finalImageUrl == null) {
          if (mounted) {
            Navigator.of(context, rootNavigator: true).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to upload image. Please check your connection.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      final priceCents = (double.parse(_priceController.text) * 100).round();
      final prepTime = _prepTimeController.text.isNotEmpty
          ? int.tryParse(_prepTimeController.text)
          : null;

      final ingredients = _ingredientsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final allergens = _allergensController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final dish = Dish(
        id: widget.dish?.id ?? '',
        vendorId: '', // Set by BLoC
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : '',
        descriptionLong: _longDescriptionController.text.trim().isNotEmpty
            ? _longDescriptionController.text.trim()
            : null,
        priceCents: priceCents,
        prepTimeMinutes: prepTime ?? 0,
        preparationTimeMinutes: prepTime ?? 0,
        category: _selectedCategory,
        categoryEnum: DishCategories.toEnum(_selectedCategory),
        imageUrl: finalImageUrl,
        available: _available,
        isFeatured: _isFeatured,
        ingredients: ingredients.isNotEmpty ? ingredients : null,
        allergens: allergens.isNotEmpty ? allergens : const [],
        dietaryRestrictions: _dietaryRestrictions.isNotEmpty ? _dietaryRestrictions : null,
        spiceLevel: _spiceLevel > 0 ? _spiceLevel : 0,
        createdAt: widget.dish?.createdAt,
        updatedAt: DateTime.now(),
      );

      // Dispatch the event to BLoC - BlocListener will handle navigation AND close dialog
      progressMessage.value = 'Saving dish...';
      if (mounted) {
        if (widget.dish == null) {
          context.read<MenuManagementBloc>().add(CreateDish(dish: dish));
        } else {
          context.read<MenuManagementBloc>().add(UpdateDish(dish: dish));
        }

        // DON'T close dialog here - BlocListener will close it after operation completes
        // Dialog stays open until success/error is received
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Remove loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving dish: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _uploadImageToSupabase(File imageFile) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        debugPrint('Upload failed: No authenticated user');
        return null;
      }

      debugPrint('Fetching vendor ID for user: ${user.id}');
      final vendorResponse = await Supabase.instance.client
          .from('vendors')
          .select('id')
          .eq('owner_id', user.id)
          .single()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Vendor lookup timed out'),
          );

      final vendorId = vendorResponse['id'] as String?;
      if (vendorId == null || vendorId.isEmpty) {
        debugPrint('Upload failed: No vendor ID found for user');
        return null;
      }

      final fileExt = imageFile.path.split('.').last;
      final fileName = '${vendorId}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      
      debugPrint('Uploading image to dish-images bucket: $fileName');

      final bytes = await imageFile.readAsBytes();
      debugPrint('Image size: ${bytes.length} bytes');
      
      final uploadResponse = await Supabase.instance.client.storage
          .from('dish-images')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(
              contentType: 'image/$fileExt',
              upsert: false,
            ),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw TimeoutException('Image upload timed out after 30 seconds'),
          );

      debugPrint('Upload successful: $uploadResponse');

      final imageUrl = Supabase.instance.client.storage
          .from('dish-images')
          .getPublicUrl(fileName);
      
      debugPrint('Public URL generated: $imageUrl');
      return imageUrl;
    } on TimeoutException catch (e) {
      debugPrint('Timeout error: $e');
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('Error uploading image: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.dish != null;

    return BlocProvider(
      create: (context) => MenuManagementBloc(supabaseClient: Supabase.instance.client),
      child: Builder(
        builder: (context) {
          return BlocListener<MenuManagementBloc, MenuManagementState>(
            listener: (context, state) {
              if (state.status == MenuManagementStatus.loaded && 
                  state.lastAction != null) {
                // Operation successful - close loading dialog (using rootNavigator), then close the screen
                Navigator.of(context, rootNavigator: true).pop(); // Close loading dialog
                Navigator.of(context).pop(); // Close dish edit screen
                
                // Show success message after navigation
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          state.lastAction == MenuManagementAction.create
                              ? 'Dish created successfully'
                              : 'Dish updated successfully',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                });
              } else if (state.status == MenuManagementStatus.error) {
                // Close loading dialog (using rootNavigator) and show error message
                Navigator.of(context, rootNavigator: true).pop(); // Close loading dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage ?? 'An error occurred'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text(isEditing ? 'Edit Dish' : 'Add New Dish'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () => _saveDish(context),
                  ),
                ],
              ),
              body: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildImageSection(),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Dish Name *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a dish name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Short Description',
                      border: OutlineInputBorder(),
                      hintText: 'Brief description for menu listings',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _longDescriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Detailed Description',
                      border: OutlineInputBorder(),
                      hintText: 'Full description with ingredients, etc.',
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                          ),
                          items: _categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          decoration: const InputDecoration(
                            labelText: 'Price *',
                            prefixText: 'R',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Required';
                            }
                            if (double.tryParse(value) == null ||
                                double.parse(value) <= 0) {
                              return 'Invalid';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _prepTimeController,
                          decoration: const InputDecoration(
                            labelText: 'Prep Time (min)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Spice Level',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Row(
                              children: List.generate(5, (index) {
                                return IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _spiceLevel = index + 1;
                                    });
                                  },
                                  icon: Icon(
                                    index < _spiceLevel
                                        ? Icons.local_fire_department
                                        : Icons.local_fire_department_outlined,
                                    color: index < _spiceLevel ? Colors.orange : null,
                                    size: 20,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _ingredientsController,
                    decoration: const InputDecoration(
                      labelText: 'Ingredients',
                      border: OutlineInputBorder(),
                      hintText: 'Comma-separated',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _allergensController,
                    decoration: const InputDecoration(
                      labelText: 'Allergens',
                      border: OutlineInputBorder(),
                      hintText: 'Comma-separated',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDietaryRestrictions(),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Available'),
                    value: _available,
                    onChanged: (value) => setState(() => _available = value),
                  ),
                  SwitchListTile(
                    title: const Text('Featured'),
                    value: _isFeatured,
                    onChanged: (value) => setState(() => _isFeatured = value),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => _saveDish(context),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: Text(isEditing ? 'Update Dish' : 'Add Dish'),
                  ),
                ],
              ),
            ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          if (_imageFile != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                _imageFile!,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else if (_imageUrl != null && _imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                _imageUrl!,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildImagePlaceholder(),
              ),
            )
          else
            _buildImagePlaceholder(),
          Positioned(
            bottom: 8,
            right: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  onPressed: _pickImage,
                  heroTag: 'gallery',
                  child: const Icon(Icons.photo_library),
                ),
                const SizedBox(width: 8),
                FloatingActionButton.small(
                  onPressed: _takePhoto,
                  heroTag: 'camera',
                  child: const Icon(Icons.camera_alt),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.restaurant, size: 48, color: Colors.grey),
          const SizedBox(height: 8),
          Text(
            'Add Dish Photo',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildDietaryRestrictions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Dietary Restrictions'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _dietaryOptions.map((option) {
            final isSelected = _dietaryRestrictions.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _dietaryRestrictions.add(option);
                  } else {
                    _dietaryRestrictions.remove(option);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
