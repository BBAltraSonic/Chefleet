# Database Schema Design

## Context
Chefleet requires a comprehensive database schema to support a mobile food marketplace with real-time capabilities. The schema must handle user management, vendor listings, order processing, messaging, and moderation while maintaining data integrity and performance.

## Goals / Non-Goals
**Goals:**
- Complete relational schema for all app functionality
- Performance-optimized with proper indexes and constraints
- Geospatial support for location-based features
- Audit trail for compliance and debugging
- Extensible design for future features

**Non-Goals:**
- Payment processing schema (placeholder only)
- Advanced analytics/reporting tables
- Multi-tenant support

## Decisions

### Data Architecture
- **PostgreSQL with Supabase**: Leverages built-in auth, real-time, and RLS
- **PostGIS**: Geographic data types and spatial indexing for vendor locations
- **Price Storage**: Integer cents for precision and consistency
- **Idempotency Keys**: Prevent duplicate order processing
- **Soft Deletes**: Status-based deletion for audit trails

### Schema Organization
- **users_public**: Public user profiles (separate from auth.users)
- **vendors**: Business information with geospatial data
- **orders**: Order lifecycle management with status tracking
- **messages**: Real-time chat with order scoping
- **audit_logs**: Change tracking for compliance

### Security Model
- **Row Level Security (RLS)**: Per-table access controls
- **UUID Primary Keys**: Prevent enumeration attacks
- **Timestamps**: Created/updated for auditability
- **Status Constraints**: Enforce proper state transitions

## Risks / Trade-offs

### Performance
- **Complex JOINs**: Indexed foreign keys mitigate query cost
- **Geospatial Queries**: PostGIS indexing required for scalability
- **Real-time Load**: Proper indexing critical for subscription performance

### Data Integrity
- **Constraints**: Foreign keys ensure referential integrity
- **Idempotency**: Prevents duplicate order processing
- **Status Enums**: Enforce business rule compliance

### Migration Complexity
- **Multi-phase Rollout**: Schema changes deployed incrementally
- **Backwards Compatibility**: Careful migration planning required
- **Data Validation**: Extensive testing before production rollout

## Migration Plan

### Phase 1: Core Schema
1. Create base tables (users_public, vendors, addresses)
2. Add primary keys and basic constraints
3. Create initial indexes

### Phase 2: Business Logic
1. Add orders and related tables
2. Implement status enums and constraints
3. Add messaging and notifications

### Phase 3: Advanced Features
1. Add moderation and audit tables
2. Implement PostGIS and spatial indexing
3. Add performance optimizations

### Phase 4: Production Readiness
1. Add RLS policies
2. Implement data validation
3. Performance testing and optimization

## Open Questions
- Should we use PostGIS geography or geometry for vendor locations?
- How will we handle timezone consistency across users?
- Do we need to implement data archiving strategy?