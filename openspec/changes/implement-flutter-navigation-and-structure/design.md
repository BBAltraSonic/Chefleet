## Context

This change establishes the foundational architecture for the Chefleet mobile app, implementing a map-driven food marketplace with persistent navigation and modular structure. The design must support real-time order coordination, geospatial queries, and smooth UI interactions while maintaining performance.

## Goals / Non-Goals

**Goals:**
- Create scalable, maintainable architecture using Flutter BLoC pattern
- Implement persistent map widget for smooth user experience
- Establish modular structure for team development
- Deliver liquid glass UI with smooth animations
- Support real-time features with proper state management

**Non-Goals:**
- Implementing specific business logic (handled in separate changes)
- Database schema design (handled in backend changes)
- API integration details (handled in service-specific changes)

## Decisions

### Navigation Architecture
- **Decision**: Use `PersistentTabController` with custom `TabBar` for navigation persistence
- **Rationale**: Provides built-in state preservation and smooth tab switching animations
- **Alternatives considered**:
  - `BottomNavigationBar` (limited customization)
  - Custom `PageView` implementation (more boilerplate, no built-in persistence)

### Map Persistence Strategy
- **Decision**: Use `IndexedStack` with `AutomaticKeepAliveClientMixin` for map persistence
- **Rationale**: Keeps map widget mounted while allowing tab switching, maintains map state
- **Alternatives considered**:
  - `PageView` with `KeepAlive` (complex state management)
  - Singleton map widget (global state issues)

### State Management
- **Decision**: BLoC pattern with `flutter_bloc` for reactive state management
- **Rationale**: Clear separation of business logic from UI, testable, scalable for complex features
- **Alternatives considered**:
  - `Provider` (simpler but less structured)
  - `Riverpod` (modern but less established in codebase)

### Folder Structure
- **Decision**: Feature-based modular structure with `screens/`, `blocs/`, `repositories/`, `models/` per module
- **Rationale**: Clear separation of concerns, scalable for team development, easy to locate related code
- **Alternatives considered**:
  - Layered structure (all screens together, all blocs together) - harder to navigate
  - Domain-driven design (over-engineering for current scope)

## Risks / Trade-offs

- **Risk**: Map memory usage with `AutomaticKeepAliveClientMixin`
  - **Mitigation**: Implement proper lifecycle management and resource cleanup
- **Trade-off**: Complex navigation setup vs long-term maintainability
  - **Acceptance**: Initial complexity pays off in scalability and feature development
- **Risk**: BLoC boilerplate overhead
  - **Mitigation**: Use code generation tools and establish patterns early

## Migration Plan

1. **Phase 1**: Setup project structure and core dependencies
2. **Phase 2**: Implement navigation shell and BLoC architecture
3. **Phase 3**: Create map persistence and basic feature modules
4. **Phase 4**: Add liquid glass styling and animations
5. **Phase 5**: Integration testing and performance optimization

## Open Questions

- Specific map provider integration details (Google Maps vs alternative)
- Custom animation timing and easing functions for glass morphism effects
- Deep linking strategy for navigation state restoration