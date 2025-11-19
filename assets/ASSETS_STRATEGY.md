# Assets Strategy

## Image Assets Strategy

### 1. Remote Images (Primary)
- **Dish Images**: Stored in Supabase Storage (`dish-images/` bucket)
- **Vendor Logos**: Stored in Supabase Storage (`vendor-logos/` bucket)
- **User Avatars**: Stored in Supabase Storage (`avatars/` bucket)
- **Format**: JPEG/PNG, max 2MB per image
- **Caching**: Use `cached_network_image` package for automatic caching

### 2. Local Placeholder Images
Located in `assets/images/`:
- `placeholder_dish.png` - Generic dish placeholder
- `placeholder_vendor.png` - Generic vendor logo placeholder
- `placeholder_avatar.png` - Generic user avatar placeholder
- `logo.png` - App logo (various sizes)
- `splash_bg.png` - Splash screen background

### 3. SVG Icons
Located in `assets/icons/`:
- UI icons for common actions
- Category icons
- Status indicators
- Use `flutter_svg` package for rendering

### 4. Thumbnail Strategy
- Generate thumbnails server-side (Edge Function)
- Sizes:
  - **Thumbnail**: 150x150px (list views)
  - **Medium**: 400x400px (detail views)
  - **Large**: 800x800px (full screen)
- Store in Supabase with naming convention: `{id}_thumb.jpg`, `{id}_medium.jpg`, `{id}_large.jpg`

### 5. Image Optimization
- Compress images before upload (80% quality for JPEG)
- Progressive JPEG for faster perceived loading
- WebP format support where possible
- Lazy loading for list views

### 6. Caching Strategy
```dart
CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (context, url) => AssetImage('assets/images/placeholder_dish.png'),
  errorWidget: (context, url, error) => Icon(Icons.error),
  cacheManager: CustomCacheManager(),
  maxHeightDiskCache: 800,
  maxWidthDiskCache: 800,
)
```

### 7. Image Upload Flow
1. User selects image via `image_picker`
2. Client validates size/format
3. Request signed URL from Edge Function `upload_image_signed_url`
4. Upload directly to Supabase Storage
5. Generate thumbnails via Edge Function
6. Update database with image URLs

### 8. Asset Organization
```
assets/
├── fonts/
│   └── PlusJakartaSans-*.ttf
├── images/
│   ├── placeholder_dish.png
│   ├── placeholder_vendor.png
│   ├── placeholder_avatar.png
│   ├── logo.png
│   └── splash_bg.png
└── icons/
    ├── category_*.svg
    ├── status_*.svg
    └── action_*.svg
```

## Required Package
Add to `pubspec.yaml`:
```yaml
dependencies:
  cached_network_image: ^3.3.0
```
