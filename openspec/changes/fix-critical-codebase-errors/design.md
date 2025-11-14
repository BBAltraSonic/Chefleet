## Context
The codebase has accumulated 721+ Flutter analysis issues and critical compilation errors that completely prevent the application from building. These errors span multiple layers: data models, core services, utilities, tests, and dependencies. The errors indicate rapid development without proper validation checkpoints.

## Goals / Non-Goals
- Goals: Restore codebase to compilable state, enable testing, fix critical runtime errors
- Non-Goals: Performance optimizations, new features, architectural changes

## Decisions
- **Model Constructor Fixes**: Add missing fields rather than removing references to maintain API compatibility
- **CacheService Completion**: Implement missing methods based on usage patterns in tests
- **Dependency Resolution**: Add missing packages (intl) and create stub implementations for missing BLoC files
- **Import Conflicts**: Use prefix imports to distinguish between google_maps_flutter and custom cluster manager types

## Risks / Trade-offs
- **Breaking Changes**: Model constructor changes require updating all instantiations
- **Missing Implementation**: Some BLoC files will need minimal implementation to satisfy imports
- **Version Compatibility**: Need to ensure google_maps_flutter compatibility with cluster manager changes

## Migration Plan
1. Fix models first to enable other components to compile
2. Complete core services (CacheService, QuadTree)
3. Resolve import conflicts and dependencies
4. Fix test syntax errors last
5. Validate with incremental builds

## Open Questions
- Should we implement full BLoC functionality or minimal stub implementations?
- Are there specific version constraints for google_maps_flutter that affect cluster manager?
- What is the expected behavior for missing CacheService methods?