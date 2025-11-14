# Change: Fix Critical Codebase Errors

## Why
The codebase has 721+ Flutter analysis issues and critical compilation errors that prevent the app from building and running. These errors span missing dependencies, syntax errors, model mismatches, and missing imports that completely block development and testing.

## What Changes
- Fix model constructor mismatches (Dish missing `price`, Vendor missing `dishCount`)
- Complete CacheService implementation with missing methods and properties
- Fix QuadTree removeWhere method returning void instead of bool
- Resolve ClusterManager import conflicts and async BitmapDescriptor handling
- Fix missing imports and dependencies (intl package, missing BLoC files)
- Complete syntax errors in test files (unclosed groups, malformed brackets)
- Fix missing constants and undefined variables in core services

## Impact
- Affected specs: None (this is a bug fix to restore functionality)
- Affected code: Core services, models, utilities, tests across the entire codebase
- **CRITICAL**: This is a prerequisite for any other development work