/**
 * Zod validation schemas for Edge Functions
 * Provides type-safe request validation
 */

import { z } from 'https://deno.land/x/zod@v3.22.4/mod.ts';

/**
 * create_order schema
 */
export const CreateOrderSchema = z.object({
  vendor_id: z.string().uuid('Invalid vendor ID format'),
  items: z.array(z.object({
    dish_id: z.string().uuid('Invalid dish ID format'),
    quantity: z.number().int().min(1, 'Quantity must be at least 1').max(99, 'Quantity cannot exceed 99'),
    special_instructions: z.string().max(500, 'Special instructions too long').optional(),
  })).min(1, 'Order must contain at least one item').max(20, 'Order cannot exceed 20 items'),
  pickup_time: z.string().datetime('Invalid pickup time format'),
  delivery_address: z.object({
    street: z.string(),
    city: z.string(),
    state: z.string(),
    postal_code: z.string(),
    lat: z.number(),
    lng: z.number(),
  }).optional(),
  special_instructions: z.string().max(1000, 'Special instructions too long').optional(),
  idempotency_key: z.string().uuid('Invalid idempotency key format'),
  guest_user_id: z.string().startsWith('guest_', 'Invalid guest ID format').optional(),
});

export type CreateOrderRequest = z.infer<typeof CreateOrderSchema>;

/**
 * change_order_status schema
 */
export const ChangeOrderStatusSchema = z.object({
  order_id: z.string().uuid('Invalid order ID format'),
  new_status: z.enum([
    'pending', 'confirmed', 'preparing', 'ready', 'picked_up', 'completed', 'cancelled'
  ], { errorMap: () => ({ message: 'Invalid status value' }) }),
  pickup_code: z.string().length(6, 'Pickup code must be 6 digits').optional(),
  reason: z.string().min(1, 'Cancellation reason required').max(500, 'Reason too long').optional(),
  idempotency_key: z.string().uuid('Invalid idempotency key format').optional(),
});

export type ChangeOrderStatusRequest = z.infer<typeof ChangeOrderStatusSchema>;

/**
 * generate_pickup_code schema
 */
export const GeneratePickupCodeSchema = z.object({
  order_id: z.string().uuid('Invalid order ID format'),
  idempotency_key: z.string().uuid('Invalid idempotency key format').optional(),
});

export type GeneratePickupCodeRequest = z.infer<typeof GeneratePickupCodeSchema>;

/**
 * report_user schema
 */
export const ReportUserSchema = z.object({
  reported_user_id: z.string().uuid('Invalid user ID format'),
  reason: z.enum([
    'inappropriate_behavior', 'fraud', 'harassment', 'spam', 'other'
  ], { errorMap: () => ({ message: 'Invalid reason' }) }),
  description: z.string().min(10, 'Description must be at least 10 characters').max(1000, 'Description too long'),
  context_type: z.enum(['message', 'order', 'profile', 'review']).optional(),
  context_id: z.string().uuid('Invalid context ID format').optional(),
  idempotency_key: z.string().uuid('Invalid idempotency key format').optional(),
});

export type ReportUserRequest = z.infer<typeof ReportUserSchema>;

/**
 * send_push schema
 */
export const SendPushSchema = z.object({
  user_ids: z.array(z.string().uuid('Invalid user ID format')).min(1, 'At least one user ID required').max(100, 'Cannot send to more than 100 users at once'),
  title: z.string().min(1, 'Title required').max(100, 'Title too long'),
  body: z.string().min(1, 'Body required').max(500, 'Body too long'),
  data: z.record(z.unknown()).optional(),
  image_url: z.string().url('Invalid image URL').optional(),
  idempotency_key: z.string().uuid('Invalid idempotency key format').optional(),
});

export type SendPushRequest = z.infer<typeof SendPushSchema>;

/**
 * upload_image_signed_url schema
 */
export const UploadImageSignedUrlSchema = z.object({
  file_name: z.string().min(1, 'File name required').max(255, 'File name too long'),
  file_type: z.enum([
    'image/jpeg', 'image/jpg', 'image/png', 'image/webp'
  ], { errorMap: () => ({ message: 'Invalid file type. Must be JPEG, PNG, or WebP' }) }),
  file_size: z.number().int().min(1, 'File size required').max(10 * 1024 * 1024, 'File too large. Maximum 10MB'),
  bucket: z.enum(['vendor_media', 'user_avatars', 'temp_uploads']).default('vendor_media'),
  purpose: z.enum(['dish_image', 'vendor_logo', 'user_avatar']).optional(),
  idempotency_key: z.string().uuid('Invalid idempotency key format').optional(),
});

export type UploadImageSignedUrlRequest = z.infer<typeof UploadImageSignedUrlSchema>;

/**
 * migrate_guest_data schema
 */
export const MigrateGuestDataSchema = z.object({
  guest_id: z.string().startsWith('guest_', 'Invalid guest ID format'),
  new_user_id: z.string().uuid('Invalid user ID format'),
  idempotency_key: z.string().uuid('Invalid idempotency key format').optional(),
});

export type MigrateGuestDataRequest = z.infer<typeof MigrateGuestDataSchema>;

/**
 * Validate request body against schema
 */
export function validateRequest<T>(
  schema: z.ZodSchema<T>,
  data: unknown
): { success: true; data: T } | { success: false; errors: z.ZodError } {
  const result = schema.safeParse(data);

  if (result.success) {
    return { success: true, data: result.data };
  }

  return { success: false, errors: result.error };
}

