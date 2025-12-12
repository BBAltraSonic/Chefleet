-- ===========================================
-- MIGRATION: Blue Downs Vendor Seed Data
-- Date: 2025-02-11
-- Description: Create 5 realistic vendors in Blue Downs, Cape Town
--              with diverse cuisines and complete dish menus
-- ===========================================

BEGIN;

-- Note: Blue Downs coordinates range approximately:
-- Latitude: -33.91 to -33.93
-- Longitude: 18.68 to 18.71
-- Center: -33.9207, 18.6919

-- ==========================================
-- 1. SAKURA RAMEN & GRILL (Japanese)
-- Location: Cape Town Road, Blue Downs
-- ==========================================

INSERT INTO vendors (
  owner_id,
  business_name,
  description,
  cuisine_type,
  phone,
  business_email,
  address,
  latitude,
  longitude,
  logo_url,
  status,
  rating,
  review_count,
  dish_count,
  is_active,
  created_at,
  updated_at
) VALUES (
  (SELECT id FROM auth.users LIMIT 1),
  'Sakura Ramen & Grill',
  'Authentic Japanese ramen, sushi rolls, and grilled specialties. Fresh ingredients sourced daily.',
  'Japanese',
  '+27 21 555 0101',
  'info@sakura-ramen.co.za',
  '45 Cape Town Road, Blue Downs, Cape Town 7800',
  -33.9195,
  18.6895,
  'https://images.unsplash.com/photo-1632709810780-1b32e747857f?w=400',
  'active',
  4.6,
  47,
  0,
  true,
  NOW(),
  NOW()
) ON CONFLICT DO NOTHING;

-- Insert Sakura dishes
INSERT INTO dishes (vendor_id, name, description, description_long, price, category, available, image_url, preparation_time_minutes, is_featured, created_at, updated_at)
SELECT 
  v.id,
  'Tonkotsu Ramen',
  'Rich pork bone broth with tender chashu pork, soft-boiled egg, noodles',
  'Traditional Tonkotsu ramen featuring a creamy pork bone broth simmered for 18 hours. Topped with melt-in-your-mouth chashu pork, ajitsuke tamago (soft-boiled egg), fresh green onions, and crispy fried garlic. Served with fresh ramen noodles.',
  12500,
  'Ramen',
  true,
  'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=400',
  12,
  true,
  NOW(),
  NOW()
FROM vendors v WHERE v.business_name = 'Sakura Ramen & Grill'
ON CONFLICT DO NOTHING;

INSERT INTO dishes (vendor_id, name, description, description_long, price, category, available, image_url, preparation_time_minutes, is_featured, created_at, updated_at)
SELECT 
  v.id,
  'Spicy Miso Ramen',
  'Medium heat miso broth with shrimp, vegetables, and soft noodles',
  'Fiery and flavorful miso-based broth with a perfect balance of heat and umami. Topped with succulent shrimp, fresh shiitake mushrooms, bamboo shoots, corn, and crispy fried garlic. Perfect for spice lovers.',
  11500,
  'Ramen',
  true,
  'https://images.unsplash.com/photo-1626871742281-28d3c68b03d8?w=400',
  10,
  true,
  NOW(),
  NOW()
FROM vendors v WHERE v.business_name = 'Sakura Ramen & Grill'
ON CONFLICT DO NOTHING;

INSERT INTO dishes (vendor_id, name, description, description_long, price, category, available, image_url, preparation_time_minutes, created_at, updated_at)
SELECT 
  v.id,
  'California Roll',
  'Imitation crab, avocado, cucumber rolled in sushi rice and seaweed',
  'Our signature California roll made with fresh imitation crab, creamy avocado, crisp cucumber, and seasoned sushi rice wrapped in crispy seaweed. A perfect introduction to sushi.',
  9500,
  'Sushi',
  true,
  'https://images.unsplash.com/photo-1622973536221-7ec33ce46eea?w=400',
  8,
  NOW(),
  NOW()
FROM vendors v WHERE v.business_name = 'Sakura Ramen & Grill'
ON CONFLICT DO NOTHING;

INSERT INTO dishes (vendor_id, name, description, description_long, price, category, available, image_url, preparation_time_minutes, created_at, updated_at)
SELECT 
  v.id,
  'Vegetable Tempura',
  'Seasonal vegetables in light, crispy tempura batter',
  'Perfectly battered and deep-fried seasonal vegetables including zucchini, bell peppers, eggplant, sweet potato, and shiitake mushrooms. Served with traditional dipping sauce.',
  8500,
  'Sides',
  true,
  'https://images.unsplash.com/photo-1599043513691-9c79cf01a5ae?w=400',
  6,
  NOW(),
  NOW()
FROM vendors v WHERE v.business_name = 'Sakura Ramen & Grill'
ON CONFLICT DO NOTHING;

-- ==========================================
-- 2. MAMA'S KITCHEN (Cape Malay / African)
-- Location: Blue Downs Drive, Blue Downs
-- ==========================================

INSERT INTO vendors (
  owner_id,
  business_name,
  description,
  cuisine_type,
  phone,
  business_email,
  address,
  latitude,
  longitude,
  logo_url,
  status,
  rating,
  review_count,
  dish_count,
  is_active,
  created_at,
  updated_at
) VALUES (
  (SELECT id FROM auth.users WHERE id != (SELECT owner_id FROM vendors LIMIT 1) LIMIT 1),
  'Mama''s Kitchen',
  'Authentic Cape Malay and African cuisine. Traditional family recipes passed down through generations.',
  'Cape Malay',
  '+27 21 555 0102',
  'hello@mamaskitchen.co.za',
  '78 Blue Downs Drive, Blue Downs, Cape Town 7800',
  -33.9210,
  18.6920,
  'https://images.unsplash.com/photo-1596103442097-8f74c7f1aaf1?w=400',
  'active',
  4.8,
  92,
  0,
  true,
  NOW(),
  NOW()
) ON CONFLICT DO NOTHING;

-- Insert Mama's Kitchen dishes
INSERT INTO dishes (vendor_id, name, description, description_long, price, category, available, image_url, preparation_time_minutes, is_featured, created_at, updated_at)
SELECT 
  v.id,
  'Beef Breyani',
  'Fragrant rice with spiced beef, potatoes, and boiled eggs',
  'Traditional Cape Malay breyani with perfectly cooked basmati rice layered with tender beef pieces marinated in exotic spices. Topped with crispy fried onions, fresh herbs, and boiled eggs. Served with aromatic raita.',
  13500,
  'Mains',
  true,
  'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',
  20,
  true,
  NOW(),
  NOW()
FROM vendors v WHERE v.business_name = 'Mama''s Kitchen'
ON CONFLICT DO NOTHING;

INSERT INTO dishes (vendor_id, name, description, description_long, price, category, available, image_url, preparation_time_minutes, is_featured, created_at, updated_at)
SELECT 
  v.id,
  'Sosaties',
  'Marinated lamb and pepper skewers with curry sauce',
  'Tender lamb cubes marinated in a blend of ginger, garlic, and warm spices, threaded onto skewers with fresh peppers and onions. Grilled to perfection and served with tangy curry sauce and pita bread.',
  11500,
  'Mains',
  true,
  'https://images.unsplash.com/photo-1599103442097-8f74c7f1aaf1?w=400',
  15,
  true,
  NOW(),
  NOW()
FROM vendors v WHERE v.business_name = 'Mama''s Kitchen'
ON CONFLICT DO NOTHING;

INSERT INTO dishes (vendor_id, name, description, description_long, price, category, available, image_url, preparation_time_minutes, created_at, updated_at)
SELECT 
  v.id,
  'Dal Dhal (Lentil Curry)',
  'Creamy lentil curry with warm spices and fresh coriander',
  'Silky smooth red lentil curry cooked with aromatic spices including cumin, coriander, and turmeric. Finished with fresh coriander and a touch of coconut cream. Vegan and protein-packed.',
  8500,
  'Vegetarian',
  true,
  'https://images.unsplash.com/photo-1568225531569-30699f379f0c?w=400',
  12,
  NOW(),
  NOW()
FROM vendors v WHERE v.business_name = 'Mama''s Kitchen'
ON CONFLICT DO NOTHING;

INSERT INTO dishes (vendor_id, name, description, description_long, price, category, available, image_url, preparation_time_minutes, created_at, updated_at)
SELECT 
  v.id,
  'Samoosas (3 pieces)',
  'Crispy pastry with spiced mince or vegetable filling',
  'Golden-fried pastries filled with spiced beef mince or spiced vegetables and potatoes. Served with sweet tamarind chutney. A perfect starter or snack.',
  6500,
  'Appetizers',
  true,
  'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=400',
  8,
  NOW(),
  NOW()
FROM vendors v WHERE v.business_name = 'Mama''s Kitchen'
ON CONFLICT DO NOTHING;

-- ==========================================
-- 3. GRILL HOUSE BLUE DOWNS (Steakhouse)
-- Location: Falcon Street, Blue Downs
-- ==========================================

INSERT INTO vendors (
  owner_id,
  business_name,
  description,
  cuisine_type,
  phone,
  business_email,
  address,
  latitude,
  longitude,
  logo_url,
  status,
  rating,
  review_count,
  dish_count,
  is_active,
  created_at,
  updated_at
) VALUES (
  (SELECT id FROM auth.users WHERE id NOT IN (SELECT owner_id FROM vendors LIMIT 2) LIMIT 1),
  'Grill House Blue Downs',
  'Premium steakhouse with wood-fired grills. Offering the finest cuts of South African beef.',
  'Steakhouse',
  '+27 21 555 0103',
  'reservations@grillhousebd.co.za',
  '23 Falcon Street, Blue Downs, Cape Town 7800',
  -33.9225,
  18.6905,
  'https://images.unsplash.com/photo-1555939594-58d7cb561af1?w=400',
  'active',
  4.7,
  63,
  0,
  true,
  NOW(),
  NOW()
) ON CONFLICT DO NOTHING;

-- Insert Grill House dishes
INSERT INTO dishes (vendor_id, name, description, description_long, price, category, available, image_url, preparation_time_minutes, is_featured, created_at, updated_at)
SELECT 
  v.id,
  'Prime Ribeye Steak (400g)',
  'Succulent ribeye with bone marrow jus, seasonal vegetables',
  'Perfectly grilled prime ribeye steak from the finest South African cattle, cooked to your preference. Finished with a rich bone marrow jus and served with seasonal roasted vegetables and creamy mashed potatoes.',
  24500,
  'Steaks',
  true,
  'https://images.unsplash.com/photo-1576599810694-01dd52f97bfd?w=400',
  18,
  true,
  NOW(),
  NOW()
FROM vendors v WHERE v.business_name = 'Grill House Blue Downs'
ON CONFLICT DO NOTHING;

INSERT INTO dishes (vendor_id, name, description, description_long, price, category, available, image_url, preparation_time_minutes, is_featured, created_at, updated_at)
SELECT 
  v.id,
  'Filet Mignon (350g)',
  'Tender filet mignon with garlic butter and truffle fries',
  'The most tender cut available - our premium filet mignon grilled to perfection. Topped with herb-infused garlic butter and served with crispy truffle fries and grilled asparagus.',
  26500,
  'Steaks',
  true,
  'https://images.unsplash.com/photo-1600103266347-c40f0f42ff1a?w=400',
  16,
  true,
  NOW(),
  NOW()
FROM vendors v WHERE v.business_name = 'Grill House Blue Downs'
ON CONFLICT DO NOTHING;

INSERT INTO dishes (vendor_id, name, description, description_long, price, category, available, image_url, preparation_time_minutes, created_at, updated_at)
SELECT 
  v.id,
  'Grilled Fish of the Day',
  'Fresh catch grilled with herbs and lemon, seasonal sides',
  'Our chef selects the finest fish available daily. Grilled simply to preserve its delicate flavors, finished with fresh lemon and herbs. Served with seasonal sides and house salad.',
  18500,
  'Seafood',
  true,
  'https://images.unsplash.com/photo-1580822261290-991b38693d1b?w=400',
  12,
  NOW(),
  NOW()
FROM vendors v WHERE v.business_name = 'Grill House Blue Downs'
ON CONFLICT DO NOTHING;

INSERT INTO dishes (vendor_id, name, description, description_long, price, category, available, image_url, preparation_time_minutes, created_at, updated_at)
SELECT 
  v.id,
  'Grilled Prawns',
  'Jumbo prawns with garlic, chili, and fresh herbs',
  'Succulent king prawns marinated in garlic, chili, and fresh herbs, grilled until just cooked. Served with truffle fries and house salad. Perfect for seafood lovers.',
  16500,
  'Seafood',
  true,
  'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=400',
  10,
  NOW(),
  NOW()
FROM vendors v WHERE v.business_name = 'Grill House Blue Downs'
ON CONFLICT DO NOTHING;

-- ==========================================
-- 4. GREEN LEAF CAFE (Health & Vegetarian)
-- Location: Main Road, Blue Downs
-- ==========================================

INSERT INTO vendors (
  owner_id,
  business_name,
  description,
  cuisine_type,
  phone,
  business_email,
  address,
  latitude,
  longitude,
  logo_url,
  status,
  rating,
  review_count,
  dish_count,
  is_active,
  created_at,
  updated_at
) VALUES (
  (SELECT id FROM auth.users WHERE id NOT IN (SELECT owner_id FROM vendors LIMIT 3) LIMIT 1),
  'Green Leaf Cafe',
  'Fresh, healthy, and organic vegetarian and vegan cuisine. Farm-to-table philosophy.',
  'Vegetarian',
  '+27 21 555 0104',
  'info@greenleafcafe.co.za',
  '156 Main Road, Blue Downs, Cape Town 7800',
  -33.9200,
  18.6935,
  'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=400',
  'active',
  4.9,
  108,
  0,
  true,
  NOW(),
  NOW()
) ON CONFLICT DO NOTHING;

-- Insert Green Leaf dishes
INSERT INTO dishes (vendor_id, name, description, description_long, price, category, available, image_url, preparation_time_minutes, is_featured, created_at, updated_at)
SELECT 
  v.id,
  'Buddha Bowl',
  'Roasted vegetables, quinoa, chickpeas, tahini dressing',
  'Colorful and nutritious bowl featuring roasted sweet potato, chickpeas, kale, avocado, and cherry tomatoes on a bed of fluffy quinoa. Topped with a creamy tahini dressing and toasted seeds.',
  9500,
  'Bowls',
  true,
  'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',
  8,
  true,
  NOW(),
  NOW()
FROM vendors v WHERE v.business_name = 'Green Leaf Cafe'
ON CONFLICT DO NOTHING;

INSERT INTO dishes (vendor_id, name, description, description_long, price, category, available, image_url, preparation_time_minutes, is_featured, created_at, updated_at)
SELECT 
  v.id,
  'Mushroom & Walnut Burger',
  'Plant-based patty with avocado, lettuce, and tahini mayo',
  'Hearty burger made with sautéed mushrooms and crushed walnuts, bound together with breadcrumbs and herbs. Topped with creamy avocado, fresh lettuce, tomato, and homemade tahini mayo on a toasted wholegrain bun.',
  10500,
  'Mains',
  true,
  'https://images.unsplash.com/photo-1585238341710-4b4e6b7ea6fe?w=400',
  10,
  true,
  NOW(),
  NOW()
FROM vendors v WHERE v.business_name = 'Green Leaf Cafe'
ON CONFLICT DO NOTHING;

INSERT INTO dishes (vendor_id, name, description, description_long, price, category, available, image_url, preparation_time_minutes, created_at, updated_at)
SELECT 
  v.id,
  'Acai Smoothie Bowl',
  'Acai berries, granola, fresh fruit, coconut yogurt',
  'Thick and creamy acai smoothie topped with crunchy granola, fresh berries, sliced banana, coconut flakes, and a drizzle of almond butter. Perfect breakfast or light lunch option.',
  8500,
  'Bowls',
  true,
  'https://images.unsplash.com/photo-1590080876/smoothie-bowl?w=400',
  5,
  NOW(),
  NOW()
FROM vendors v WHERE v.business_name = 'Green Leaf Cafe'
ON CONFLICT DO NOTHING;

INSERT INTO dishes (vendor_id, name, description, description_long, price, category, available, image_url, preparation_time_minutes, created_at, updated_at)
SELECT 
  v.id,
  'Seasonal Salad',
  'Fresh organic vegetables, homemade dressing, choice of protein',
  'Crisp seasonal vegetables sourced from local farms. Choose from feta cheese, grilled halloumi, or chickpeas. Dressed with our signature olive oil and vinegar dressing.',
  9000,
  'Salads',
  true,
  'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=400',
  6,
  NOW(),
  NOW()
FROM vendors v WHERE v.business_name = 'Green Leaf Cafe'
ON CONFLICT DO NOTHING;

-- ==========================================
-- 5. SPICE TRAIL (Indian)
-- Location: Sunrise Avenue, Blue Downs
-- ==========================================

INSERT INTO vendors (
  owner_id,
  business_name,
  description,
  cuisine_type,
  phone,
  business_email,
  address,
  latitude,
  longitude,
  logo_url,
  status,
  rating,
  review_count,
  dish_count,
  is_active,
  created_at,
  updated_at
) VALUES (
  (SELECT id FROM auth.users WHERE id NOT IN (SELECT owner_id FROM vendors LIMIT 4) LIMIT 1),
  'Spice Trail',
  'Authentic North and South Indian cuisine. Rich flavors and traditional recipes.',
  'Indian',
  '+27 21 555 0105',
  'hello@spicetrail.co.za',
  '92 Sunrise Avenue, Blue Downs, Cape Town 7800',
  -33.9215,
  18.6910,
  'https://images.unsplash.com/photo-1585238341710-4b4e6b7ea6fe?w=400',
  'active',
  4.6,
  71,
  0,
  true,
  NOW(),
  NOW()
) ON CONFLICT DO NOTHING;

-- Insert Spice Trail dishes
INSERT INTO dishes (vendor_id, name, description, description_long, price, category, available, image_url, preparation_time_minutes, is_featured, spice_level, created_at, updated_at)
SELECT 
  v.id,
  'Butter Chicken',
  'Tender chicken in creamy tomato sauce with warm spices',
  'Succulent pieces of chicken cooked in a rich, creamy tomato-based sauce with fenugreek, cream, and butter. Perfectly balanced with warm spices. Served with steamed basmati rice or naan bread.',
  12500,
  'Curries',
  true,
  'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=400',
  14,
  true,
  2,
  NOW(),
  NOW()
FROM vendors v WHERE v.business_name = 'Spice Trail'
ON CONFLICT DO NOTHING;

INSERT INTO dishes (vendor_id, name, description, description_long, price, category, available, image_url, preparation_time_minutes, is_featured, spice_level, created_at, updated_at)
SELECT 
  v.id,
  'Chana Masala',
  'Chickpeas in spiced tomato sauce with onions and peppers',
  'Hearty vegan curry featuring tender chickpeas cooked in an aromatic tomato sauce with cumin, coriander, ginger, and garlic. Rich, warming, and naturally vegan. Served with rice or bread.',
  9500,
  'Curries',
  true,
  'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=400',
  12,
  true,
  2,
  NOW(),
  NOW()
FROM vendors v WHERE v.business_name = 'Spice Trail'
ON CONFLICT DO NOTHING;

INSERT INTO dishes (vendor_id, name, description, description_long, price, category, available, image_url, preparation_time_minutes, spice_level, created_at, updated_at)
SELECT 
  v.id,
  'Lamb Vindaloo',
  'Tender lamb with fiery vindaloo spice blend',
  'For the brave! Tender lamb pieces in a fiery red curry sauce with dried chilies, vinegar, and warming spices. Intense heat balanced with complex flavors. For spice enthusiasts only.',
  14500,
  'Curries',
  true,
  'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=400',
  16,
  4,
  NOW(),
  NOW()
FROM vendors v WHERE v.business_name = 'Spice Trail'
ON CONFLICT DO NOTHING;

INSERT INTO dishes (vendor_id, name, description, description_long, price, category, available, image_url, preparation_time_minutes, created_at, updated_at)
SELECT 
  v.id,
  'Garlic Naan',
  'Soft Indian flatbread with roasted garlic and herbs',
  'Fluffy Indian flatbread freshly cooked in the tandoor, brushed with garlic-infused ghee and fresh coriander. Perfect for dipping into curries.',
  4500,
  'Breads',
  true,
  'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=400',
  4,
  NOW(),
  NOW()
FROM vendors v WHERE v.business_name = 'Spice Trail'
ON CONFLICT DO NOTHING;

-- Update dish counts for all vendors
UPDATE vendors SET dish_count = (SELECT COUNT(*) FROM dishes WHERE dishes.vendor_id = vendors.id)
WHERE business_name IN ('Sakura Ramen & Grill', 'Mama''s Kitchen', 'Grill House Blue Downs', 'Green Leaf Cafe', 'Spice Trail');

COMMIT;
