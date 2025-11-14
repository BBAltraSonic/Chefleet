# Change: Implement Vendor Dashboard & Management System

## Why

Vendors need a comprehensive dashboard to manage their business operations on the Chefleet platform, including onboarding, menu management, order processing, customer communication, and media uploads. This implementation enables vendors to efficiently run their food business through the mobile app while maintaining proper data isolation and security.

## What Changes

- **Vendor Onboarding Flow**: In-app vendor registration with business details, location selection, and document upload
- **Menu Management System**: CRUD operations for dishes with real-time availability updates
- **Order Queue Management**: Real-time order processing with status transitions and pickup code verification
- **Vendor Chat System**: Secure messaging with buyers scoped to orders with quick replies
- **Media Upload System**: Secure image upload with signed URLs and automatic thumbnail generation
- **RLS Enforcement**: Vendor-scoped data access ensuring vendors can only modify their own data
- **Real-time Integration**: Live order updates and synchronization across all connected clients

## Impact

**Affected specs:**
- `vendor-management` - New capability for vendor onboarding and profile management
- `menu-management` - New capability for dish CRUD and inventory management
- `order-queue` - New capability for vendor order processing and status management
- `vendor-chat` - New capability for buyer-vendor communication
- `media-uploads` - New capability for secure image handling

**Affected code:**
- Flutter app: New vendor dashboard screens and BLoC state management
- Database: New `vendors` table relationships and RLS policies
- Edge Functions: New endpoints for vendor operations and media handling
- Supabase Storage: New `vendor_media` bucket with access policies
- Realtime: New vendor-specific channels for order updates

**Security implications:**
- RLS policies ensure vendor data isolation
- Signed URLs prevent unauthorized media access
- Edge functions validate all vendor operations
- Audit logging for all vendor actions