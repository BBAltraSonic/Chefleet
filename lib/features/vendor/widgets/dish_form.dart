import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../feed/models/dish_model.dart';
import '../blocs/menu_management_bloc.dart';

class DishForm extends StatefulWidget {
  final Dish? dish;

  const DishForm({super.key, this.dish});

  @override
  State<DishForm> createState() => _DishFormState();
}

class _DishFormState extends State<DishForm> {
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

  final List<String> _categories = [
    'Appetizers',
    'Main Course',
    'Desserts',
    'Beverages',
    'Snacks',
    'Salads',
    'Soups',
    'Breakfast',
    'Side Dishes',
  ];

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
    _prepTimeController.text = dish.preparationTimeMinutes?.toString() ?? '';
    _ingredientsController.text = dish.ingredients?.join(', ') ?? '';
    _allergensController.text = dish.allergens?.join(', ') ?? '';
    _selectedCategory = dish.categoryEnum;
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
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 600,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _imageUrl = null; // Clear existing URL
      });
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      maxHeight: 600,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _imageUrl = null; // Clear existing URL
      });
    }
  }

  Future<void> _saveDish() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Dialog(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Saving dish...'),
            ],
          ),
        ),
      ),
    );

    try {
      // Upload image if a new one was selected
      String? finalImageUrl = _imageUrl;
      if (_imageFile != null) {
        finalImageUrl = await _uploadImageToSupabase(_imageFile!);
        if (finalImageUrl == null) {
          Navigator.of(context).pop(); // Remove loading dialog
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to upload image'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      final priceCents = (double.parse(_priceController.text) * 100).round();
      final prepTime = _prepTimeController.text.isNotEmpty
          ? int.tryParse(_prepTimeController.text) ?? 0
          : 0;

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
        vendorId: '', // Will be set by BLoC
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : '',
        descriptionLong: _longDescriptionController.text.trim().isNotEmpty
            ? _longDescriptionController.text.trim()
            : null,
        priceCents: priceCents,
        prepTimeMinutes: prepTime,
        category: _selectedCategory,
        categoryEnum: _selectedCategory,
        imageUrl: finalImageUrl,
        available: _available,
        isFeatured: _isFeatured,
        ingredients: ingredients.isNotEmpty ? ingredients : null,
        allergens: allergens,
        dietaryRestrictions: _dietaryRestrictions.isNotEmpty ? _dietaryRestrictions : null,
        preparationTimeMinutes: prepTime,
        spiceLevel: _spiceLevel,
        createdAt: widget.dish?.createdAt,
        updatedAt: DateTime.now(),
      );

      if (widget.dish == null) {
        context.read<MenuManagementBloc>().add(CreateDish(dish: dish));
      } else {
        context.read<MenuManagementBloc>().add(UpdateDish(dish: dish));
      }

      Navigator.of(context).pop(); // Remove loading dialog
      Navigator.of(context).pop(); // Close form
    } catch (e) {
      Navigator.of(context).pop(); // Remove loading dialog
      if (mounted) {
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
      if (user == null) return null;

      // Get vendor ID
      final vendorResponse = await Supabase.instance.client
          .from('vendors')
          .select('id')
          .eq('owner_id', user.id)
          .single();

      final vendorId = vendorResponse['id'] as String? ?? '';

      // Generate unique filename
      final fileExt = imageFile.path.split('.').last;
      final fileName = '${vendorId}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      // Upload to Supabase Storage
      final bytes = await imageFile.readAsBytes();
      await Supabase.instance.client.storage
          .from('dish-images')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(
              contentType: 'image/$fileExt',
              upsert: false,
            ),
          );

      // Get public URL
      final imageUrl = Supabase.instance.client.storage
          .from('dish-images')
          .getPublicUrl(fileName);

      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.dish != null;

    return DraggableScrollableSheet(
      initialChildSize: 0.95,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle Bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        isEditing ? 'Edit Dish' : 'Add New Dish',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              // Form
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Image Upload
                      _buildImageSection(),

                      const SizedBox(height: 16),

                      // Basic Info
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
                          hintText: 'Full description with ingredients, preparation details, etc.',
                        ),
                        maxLines: 4,
                      ),

                      const SizedBox(height: 16),

                      // Category and Price
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              value: _selectedCategory,
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
                                prefixText: '\$',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(value) == null ||
                                    double.parse(value) <= 0) {
                                  return 'Invalid price';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Preparation Time and Spice Level
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _prepTimeController,
                              decoration: const InputDecoration(
                                labelText: 'Prep Time (minutes)',
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
                                        index < _spiceLevel ? Icons.local_fire_department : Icons.local_fire_department_outlined,
                                        color: index < _spiceLevel ? Colors.orange : null,
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Ingredients
                      TextFormField(
                        controller: _ingredientsController,
                        decoration: const InputDecoration(
                          labelText: 'Ingredients',
                          border: OutlineInputBorder(),
                          hintText: 'Comma-separated list of main ingredients',
                        ),
                        maxLines: 2,
                      ),

                      const SizedBox(height: 16),

                      // Allergens
                      TextFormField(
                        controller: _allergensController,
                        decoration: const InputDecoration(
                          labelText: 'Allergens',
                          border: OutlineInputBorder(),
                          hintText: 'Comma-separated list of allergens',
                        ),
                        maxLines: 2,
                      ),

                      const SizedBox(height: 16),

                      // Dietary Restrictions
                      _buildDietaryRestrictions(),

                      const SizedBox(height: 16),

                      // Switches
                      Row(
                        children: [
                          Expanded(
                            child: SwitchListTile(
                              title: const Text('Available'),
                              subtitle: const Text('Show in menu'),
                              value: _available,
                              onChanged: (value) {
                                setState(() {
                                  _available = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                      SwitchListTile(
                        title: const Text('Featured Dish'),
                        subtitle: const Text('Highlight in special sections'),
                        value: _isFeatured,
                        onChanged: (value) {
                          setState(() {
                            _isFeatured = value;
                          });
                        },
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Bottom Action Bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveDish,
                        child: Text(isEditing ? 'Update Dish' : 'Add Dish'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageSection() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Display Image
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
                errorBuilder: (context, error, stackTrace) {
                  return _buildImagePlaceholder();
                },
              ),
            )
          else
            _buildImagePlaceholder(),

          // Image Actions
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
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 8),
          Text(
            'Add Dish Photo',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDietaryRestrictions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dietary Restrictions',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
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