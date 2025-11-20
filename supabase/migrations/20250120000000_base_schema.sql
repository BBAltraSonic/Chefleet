-- ===========================================
-- CHEFLEET DATABASE BASE SCHEMA
-- Migration: 20250120000000_base_schema.sql
-- Description: Initial database schema for Chefleet application
-- ===========================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- ===========================================
-- USER TABLES
-- ===========================================

-- Users public profile table (synced with auth.users)
CREATE TABLE IF NOT EXISTS users_public (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    avatar_url TEXT,
    address JSONB,
    notification_preferences JSONB DEFAULT '{"order_updates": true, "chat_messages": true, "promotions": false, "vendor_updates": false}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Profiles table (alternative user profile storage)
CREATE TABLE IF NOT EXISTS profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    avatar_url TEXT,
    address JSONB,
    notification_preferences JSONB DEFAULT '{"order_updates": true, "chat_messages": true, "promotions": false, "vendor_updates": false}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===========================================
-- VENDOR TABLES
-- ===========================================

-- Vendors table
CREATE TABLE IF NOT EXISTS vendors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    business_name TEXT NOT NULL,
    description TEXT,
    cuisine_type TEXT,
    phone TEXT NOT NULL,
    business_email TEXT,
    address TEXT,
    address_text TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    logo_url TEXT,
    license_url TEXT,
    status TEXT NOT NULL DEFAULT 'pending_review' CHECK (status IN ('pending_review', 'pending', 'approved', 'active', 'suspended', 'inactive', 'deactivated')),
    rating DOUBLE PRECISION DEFAULT 0.0 CHECK (rating >= 0 AND rating <= 5),
    review_count INTEGER DEFAULT 0 CHECK (review_count >= 0),
    dish_count INTEGER DEFAULT 0 CHECK (dish_count >= 0),
    is_active BOOLEAN DEFAULT true,
    open_hours JSONB,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(owner_id)
);

-- Dishes table
CREATE TABLE IF NOT EXISTS dishes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_id UUID NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT DEFAULT '',
    description_long TEXT,
    price INTEGER NOT NULL CHECK (price > 0),
    prep_time_minutes INTEGER NOT NULL DEFAULT 0 CHECK (prep_time_minutes >= 0),
    preparation_time_minutes INTEGER,
    available BOOLEAN DEFAULT true,
    image_url TEXT,
    category TEXT,
    category_enum TEXT,
    tags TEXT[] DEFAULT ARRAY[]::TEXT[],
    ingredients TEXT[] DEFAULT ARRAY[]::TEXT[],
    dietary_restrictions TEXT[] DEFAULT ARRAY[]::TEXT[],
    spice_level INTEGER DEFAULT 0 CHECK (spice_level >= 0 AND spice_level <= 5),
    is_vegetarian BOOLEAN DEFAULT false,
    is_vegan BOOLEAN DEFAULT false,
    is_gluten_free BOOLEAN DEFAULT false,
    is_featured BOOLEAN DEFAULT false,
    nutritional_info JSONB,
    allergens TEXT[] DEFAULT ARRAY[]::TEXT[],
    popularity_score DOUBLE PRECISION DEFAULT 0.0,
    order_count INTEGER DEFAULT 0 CHECK (order_count >= 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Vendor hours table
CREATE TABLE IF NOT EXISTS vendor_hours (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_id UUID NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
    day_of_week INTEGER NOT NULL CHECK (day_of_week >= 0 AND day_of_week <= 6),
    open_time TIME NOT NULL,
    close_time TIME NOT NULL,
    is_closed BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(vendor_id, day_of_week)
);

-- Vendor quick replies table
CREATE TABLE IF NOT EXISTS vendor_quick_replies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_id UUID NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    category TEXT NOT NULL CHECK (category IN ('general', 'pickup', 'preparation', 'pricing', 'custom')),
    is_active BOOLEAN DEFAULT true,
    usage_count INTEGER DEFAULT 0 CHECK (usage_count >= 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===========================================
-- ORDER TABLES
-- ===========================================

-- Orders table
CREATE TABLE IF NOT EXISTS orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    vendor_id UUID NOT NULL REFERENCES vendors(id) ON DELETE RESTRICT,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'preparing', 'ready', 'picked_up', 'completed', 'cancelled')),
    total_cents INTEGER NOT NULL CHECK (total_cents >= 0),
    subtotal_cents INTEGER NOT NULL CHECK (subtotal_cents >= 0),
    tax_cents INTEGER DEFAULT 0 CHECK (tax_cents >= 0),
    fee_cents INTEGER DEFAULT 0 CHECK (fee_cents >= 0),
    payment_method TEXT DEFAULT 'cash' CHECK (payment_method IN ('cash', 'card', 'wallet')),
    payment_status TEXT DEFAULT 'pending' CHECK (payment_status IN ('pending', 'completed', 'failed', 'refunded')),
    pickup_code TEXT,
    pickup_time TIMESTAMP WITH TIME ZONE,
    notes TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Order items table
CREATE TABLE IF NOT EXISTS order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    dish_id UUID NOT NULL REFERENCES dishes(id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    price_cents INTEGER NOT NULL CHECK (price_cents > 0),
    subtotal_cents INTEGER NOT NULL CHECK (subtotal_cents >= 0),
    special_instructions TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Order status history table
CREATE TABLE IF NOT EXISTS order_status_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    status TEXT NOT NULL,
    notes TEXT,
    changed_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===========================================
-- COMMUNICATION TABLES
-- ===========================================

-- Messages table (chat between users and vendors)
CREATE TABLE IF NOT EXISTS messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    recipient_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    message_type TEXT DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'system')),
    is_read BOOLEAN DEFAULT false,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===========================================
-- MODERATION TABLES
-- ===========================================

-- Moderation reports table
CREATE TABLE IF NOT EXISTS moderation_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporter_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    reported_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    reported_vendor_id UUID REFERENCES vendors(id) ON DELETE SET NULL,
    report_type TEXT NOT NULL CHECK (report_type IN ('harassment', 'spam', 'inappropriate', 'fraud', 'other')),
    description TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'under_review', 'resolved', 'dismissed')),
    resolution_notes TEXT,
    resolved_by UUID REFERENCES auth.users(id),
    resolved_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User reviews table
CREATE TABLE IF NOT EXISTS user_reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    vendor_id UUID NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    is_visible BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(order_id, user_id)
);

-- ===========================================
-- SYSTEM TABLES
-- ===========================================

-- App settings table
CREATE TABLE IF NOT EXISTS app_settings (
    key TEXT PRIMARY KEY,
    value JSONB NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===========================================
-- INDEXES FOR PERFORMANCE
-- ===========================================

-- Users indexes
CREATE INDEX IF NOT EXISTS idx_users_public_created_at ON users_public(created_at);
CREATE INDEX IF NOT EXISTS idx_profiles_created_at ON profiles(created_at);

-- Vendors indexes
CREATE INDEX IF NOT EXISTS idx_vendors_owner_id ON vendors(owner_id);
CREATE INDEX IF NOT EXISTS idx_vendors_status ON vendors(status);
CREATE INDEX IF NOT EXISTS idx_vendors_is_active ON vendors(is_active);
CREATE INDEX IF NOT EXISTS idx_vendors_location ON vendors USING GIST(
    ST_MakePoint(longitude, latitude)::geography
) WHERE latitude IS NOT NULL AND longitude IS NOT NULL;

-- Dishes indexes
CREATE INDEX IF NOT EXISTS idx_dishes_vendor_id ON dishes(vendor_id);
CREATE INDEX IF NOT EXISTS idx_dishes_available ON dishes(available);
CREATE INDEX IF NOT EXISTS idx_dishes_category ON dishes(category);
CREATE INDEX IF NOT EXISTS idx_dishes_created_at ON dishes(created_at);
CREATE INDEX IF NOT EXISTS idx_dishes_popularity_score ON dishes(popularity_score DESC);

-- Orders indexes
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_vendor_id ON orders(vendor_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at);
CREATE INDEX IF NOT EXISTS idx_orders_pickup_code ON orders(pickup_code);

-- Order items indexes
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_dish_id ON order_items(dish_id);

-- Messages indexes
CREATE INDEX IF NOT EXISTS idx_messages_order_id ON messages(order_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender_id ON messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_recipient_id ON messages(recipient_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at);
CREATE INDEX IF NOT EXISTS idx_messages_is_read ON messages(is_read);

-- Moderation indexes
CREATE INDEX IF NOT EXISTS idx_moderation_reports_reporter_id ON moderation_reports(reporter_id);
CREATE INDEX IF NOT EXISTS idx_moderation_reports_status ON moderation_reports(status);
CREATE INDEX IF NOT EXISTS idx_user_reviews_vendor_id ON user_reviews(vendor_id);
CREATE INDEX IF NOT EXISTS idx_user_reviews_user_id ON user_reviews(user_id);

-- ===========================================
-- TRIGGERS
-- ===========================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at triggers to relevant tables
CREATE TRIGGER update_users_public_updated_at BEFORE UPDATE ON users_public
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_vendors_updated_at BEFORE UPDATE ON vendors
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_dishes_updated_at BEFORE UPDATE ON dishes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_messages_updated_at BEFORE UPDATE ON messages
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to update vendor dish count
CREATE OR REPLACE FUNCTION update_vendor_dish_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE vendors 
        SET dish_count = dish_count + 1 
        WHERE id = NEW.vendor_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE vendors 
        SET dish_count = GREATEST(0, dish_count - 1) 
        WHERE id = OLD.vendor_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_vendor_dish_count_trigger
AFTER INSERT OR DELETE ON dishes
FOR EACH ROW EXECUTE FUNCTION update_vendor_dish_count();

-- Function to update vendor rating
CREATE OR REPLACE FUNCTION update_vendor_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE vendors v
    SET 
        rating = (
            SELECT COALESCE(AVG(rating), 0)
            FROM user_reviews
            WHERE vendor_id = v.id AND is_visible = true
        ),
        review_count = (
            SELECT COUNT(*)
            FROM user_reviews
            WHERE vendor_id = v.id AND is_visible = true
        )
    WHERE id = NEW.vendor_id;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_vendor_rating_trigger
AFTER INSERT OR UPDATE ON user_reviews
FOR EACH ROW EXECUTE FUNCTION update_vendor_rating();

-- ===========================================
-- ENABLE ROW LEVEL SECURITY
-- ===========================================

ALTER TABLE users_public ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendors ENABLE ROW LEVEL SECURITY;
ALTER TABLE dishes ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendor_hours ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendor_quick_replies ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_status_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE moderation_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_settings ENABLE ROW LEVEL SECURITY;

-- ===========================================
-- RLS POLICIES
-- ===========================================

-- Users public table policies
CREATE POLICY "Users can view own profile" ON users_public
    FOR SELECT USING (id = auth.uid());

CREATE POLICY "Users can update own profile" ON users_public
    FOR UPDATE USING (id = auth.uid());

CREATE POLICY "Users can insert own profile" ON users_public
    FOR INSERT WITH CHECK (id = auth.uid());

-- Profiles table policies
CREATE POLICY "Users can view own profile" ON profiles
    FOR SELECT USING (id = auth.uid());

CREATE POLICY "Users can update own profile" ON profiles
    FOR UPDATE USING (id = auth.uid());

CREATE POLICY "Users can insert own profile" ON profiles
    FOR INSERT WITH CHECK (id = auth.uid());

-- Vendors table policies
CREATE POLICY "Vendors can view own profile" ON vendors
    FOR SELECT USING (owner_id = auth.uid());

CREATE POLICY "Vendors can update own profile" ON vendors
    FOR UPDATE USING (owner_id = auth.uid());

CREATE POLICY "Vendors can insert own profile" ON vendors
    FOR INSERT WITH CHECK (owner_id = auth.uid());

CREATE POLICY "Public can view active vendors" ON vendors
    FOR SELECT USING (is_active = true AND status IN ('active', 'approved'));

-- Dishes table policies
CREATE POLICY "Vendors can manage own dishes" ON dishes
    FOR ALL USING (
        vendor_id IN (
            SELECT id FROM vendors WHERE owner_id = auth.uid()
        )
    );

CREATE POLICY "Public can view available dishes" ON dishes
    FOR SELECT USING (
        available = true AND 
        vendor_id IN (
            SELECT id FROM vendors WHERE is_active = true AND status IN ('active', 'approved')
        )
    );

-- Vendor hours policies
CREATE POLICY "Vendors can manage own hours" ON vendor_hours
    FOR ALL USING (
        vendor_id IN (
            SELECT id FROM vendors WHERE owner_id = auth.uid()
        )
    );

CREATE POLICY "Public can view vendor hours" ON vendor_hours
    FOR SELECT USING (
        vendor_id IN (
            SELECT id FROM vendors WHERE is_active = true
        )
    );

-- Vendor quick replies policies
CREATE POLICY "Vendors can manage own quick replies" ON vendor_quick_replies
    FOR ALL USING (
        vendor_id IN (
            SELECT id FROM vendors WHERE owner_id = auth.uid()
        )
    );

-- Orders table policies
CREATE POLICY "Users can view own orders" ON orders
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can insert own orders" ON orders
    FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Vendors can view orders for their vendor" ON orders
    FOR SELECT USING (
        vendor_id IN (
            SELECT id FROM vendors WHERE owner_id = auth.uid()
        )
    );

CREATE POLICY "Vendors can update orders for their vendor" ON orders
    FOR UPDATE USING (
        vendor_id IN (
            SELECT id FROM vendors WHERE owner_id = auth.uid()
        )
    );

-- Order items policies
CREATE POLICY "Users can view own order items" ON order_items
    FOR SELECT USING (
        order_id IN (
            SELECT id FROM orders WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert own order items" ON order_items
    FOR INSERT WITH CHECK (
        order_id IN (
            SELECT id FROM orders WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Vendors can view order items for their orders" ON order_items
    FOR SELECT USING (
        order_id IN (
            SELECT o.id FROM orders o
            INNER JOIN vendors v ON o.vendor_id = v.id
            WHERE v.owner_id = auth.uid()
        )
    );

-- Order status history policies
CREATE POLICY "Users can view own order history" ON order_status_history
    FOR SELECT USING (
        order_id IN (
            SELECT id FROM orders WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Vendors can view and insert order history" ON order_status_history
    FOR ALL USING (
        order_id IN (
            SELECT o.id FROM orders o
            INNER JOIN vendors v ON o.vendor_id = v.id
            WHERE v.owner_id = auth.uid()
        )
    );

-- Messages table policies
CREATE POLICY "Users can view own messages" ON messages
    FOR SELECT USING (
        sender_id = auth.uid() OR recipient_id = auth.uid()
    );

CREATE POLICY "Users can send messages" ON messages
    FOR INSERT WITH CHECK (sender_id = auth.uid());

CREATE POLICY "Users can update own sent messages" ON messages
    FOR UPDATE USING (sender_id = auth.uid() OR recipient_id = auth.uid());

-- Moderation reports policies
CREATE POLICY "Users can view own reports" ON moderation_reports
    FOR SELECT USING (reporter_id = auth.uid());

CREATE POLICY "Users can insert reports" ON moderation_reports
    FOR INSERT WITH CHECK (reporter_id = auth.uid());

-- User reviews policies
CREATE POLICY "Users can view all reviews" ON user_reviews
    FOR SELECT USING (is_visible = true);

CREATE POLICY "Users can insert own reviews" ON user_reviews
    FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own reviews" ON user_reviews
    FOR UPDATE USING (user_id = auth.uid());

-- App settings policies (read-only for authenticated users)
CREATE POLICY "Authenticated users can view settings" ON app_settings
    FOR SELECT TO authenticated USING (is_active = true);
