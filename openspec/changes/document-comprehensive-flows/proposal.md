# Change: Document Comprehensive User Flows and Navigation

## Why
Chefleet needs complete documentation of all screens, navigation patterns, and user flows to guide implementation and ensure consistent UX across Buyer, Vendor, and Admin roles. Currently, flows are implicit in scattered documentation without a single source of truth for navigation architecture.

## What Changes
- **Add comprehensive flow definitions**: Document all user journeys for Buyer onboarding, dish discovery, ordering, vendor management, chat, and admin moderation
- **Add navigation architecture**: Define screen IDs, navigation types (push, modal, bottom tab, FAB, drawer), and transitions
- **Add data flow mapping**: Document inputs (order_id, vendor_id), Supabase queries, and state dependencies for each screen
- **Add structured JSON schema**: Create machine-readable flow definitions for tooling and code generation
- **Add visual navigation map**: Markdown documentation with ASCII flow diagrams for quick reference

## Impact
- **Affected specs**: user-flows (new capability)
- **Affected code**: All UI implementation files (lib/screens/*, lib/navigation/*)
- **Dependencies**: Database schema from implement-database-schema, Flutter navigation patterns
- **Migration**: None - this is documentation-only, establishing design specs before implementation
