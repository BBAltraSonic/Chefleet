# Sprint Tracking - Critical Remediation

**Plan**: [CRITICAL_REMEDIATION_PLAN.md](./CRITICAL_REMEDIATION_PLAN.md)  
**Start Date**: TBD  
**Target Completion**: TBD + 10 business days

---

## Sprint Overview

| Sprint | Status | Start | End | Progress |
|--------|--------|-------|-----|----------|
| Sprint 1: Security & Config | 🔴 Not Started | - | - | 0% |
| Sprint 2: Navigation | 🔴 Not Started | - | - | 0% |
| Sprint 3: Edge Functions | 🔴 Not Started | - | - | 0% |
| Sprint 4: Code Quality | 🔴 Not Started | - | - | 0% |
| Sprint 5: Testing & CI/CD | 🔴 Not Started | - | - | 0% |

---

## Sprint 1: Security & Configuration (1 day)

**Status**: 🔴 Not Started  
**Priority**: CRITICAL  
**Assignee**: TBD

### Tasks

- [ ] **1.1 Secure Supabase Credentials** (4h)
  - [ ] Add `flutter_dotenv` package
  - [ ] Create `.env` and `.env.example` files
  - [ ] Update `.gitignore`
  - [ ] Modify `lib/main.dart` to use environment variables
  - [ ] Update test files to use mock credentials
  - [ ] Clean git history (if needed)
  - [ ] Verify app runs with environment variables

- [ ] **1.2 Configure Google Maps API Key** (2h)
  - [ ] Obtain API key from Google Cloud Console
  - [ ] Add to `.env` file
  - [ ] Configure Android (`AndroidManifest.xml`, `build.gradle`)
  - [ ] Configure iOS (`AppDelegate.swift`)
  - [ ] Verify maps render correctly

- [ ] **1.3 Update Documentation** (2h)
  - [ ] Create `docs/ENVIRONMENT_SETUP.md`
  - [ ] Update `README.md` with quick start
  - [ ] Document API key acquisition
  - [ ] Add troubleshooting section

### Acceptance Criteria
- ✅ No credentials in source code
- ✅ Google Maps API key configured
- ✅ Documentation complete
- ✅ App runs successfully with environment config

### Blockers
- None identified

### Notes
- See [IMMEDIATE_ACTION_CHECKLIST.md](./IMMEDIATE_ACTION_CHECKLIST.md) for step-by-step guide

---

## Sprint 2: Navigation Unification (2.25 days)

**Status**: 🔴 Not Started  
**Priority**: HIGH  
**Assignee**: TBD

### Tasks

- [ ] **2.1 Audit Current Navigation** (2h)
  - [ ] Document all routes
  - [ ] Identify deep link requirements
  - [ ] Map shell behavior to go_router patterns
  - [ ] List navigation BLoC dependencies

- [ ] **2.2 Implement go_router Shell Route** (8h)
  - [ ] Create `ShellRoute` for bottom navigation
  - [ ] Refactor `PersistentNavigationShell`
  - [ ] Implement route guards
  - [ ] Update `main.dart` to use `MaterialApp.router`

- [ ] **2.3 Update All Navigation Calls** (6h)
  - [ ] Replace `Navigator.push()` with `context.go()`
  - [ ] Replace `Navigator.pop()` with `context.pop()`
  - [ ] Update navigation BLoC usage
  - [ ] Test all navigation flows

- [ ] **2.4 Remove Legacy Navigation Code** (2h)
  - [ ] Remove unused navigation BLoC code
  - [ ] Remove old route definitions
  - [ ] Clean up utilities
  - [ ] Update tests

### Acceptance Criteria
- ✅ Single navigation system (go_router only)
- ✅ Deep linking functional
- ✅ All screens accessible
- ✅ Navigation tests passing

### Blockers
- Depends on Sprint 1 completion

### Notes
- High risk of breaking existing flows - test thoroughly
- Consider feature flag for gradual rollout

---

## Sprint 3: Edge Functions & Payment Cleanup (1.5 days)

**Status**: 🔴 Not Started  
**Priority**: MEDIUM  
**Assignee**: TBD

### Tasks

- [ ] **3.1 Consolidate Edge Functions** (4h)
  - [ ] Audit all functions in both directories
  - [ ] Move needed functions to `supabase/functions/`
  - [ ] Delete `edge-functions/` directory
  - [ ] Update function call sites in Dart code
  - [ ] Add `deno.json` for version pinning
  - [ ] Deploy functions to dev environment
  - [ ] Test all function invocations

- [ ] **3.2 Remove Payment Code** (6h)
  - [ ] Identify all payment-related files
  - [ ] Remove `PaymentService` and related code
  - [ ] Remove payment UI components
  - [ ] Update order flow to cash-only
  - [ ] Remove payment database tables (migration)
  - [ ] Update tests

- [ ] **3.3 Update Documentation** (2h)
  - [ ] Document cash-only order flow
  - [ ] Update user documentation
  - [ ] Create vendor cash handling guide
  - [ ] Update API documentation

### Acceptance Criteria
- ✅ Single edge functions directory
- ✅ All payment code removed
- ✅ Cash-only order flow working
- ✅ Documentation updated

### Blockers
- None identified

### Notes
- Search thoroughly for payment references: `grep -r "payment\|stripe" lib/`
- Keep audit trail of removed code (git history)

---

## Sprint 4: Code Quality & Performance (1.75 days)

**Status**: 🔴 Not Started  
**Priority**: MEDIUM  
**Assignee**: TBD

### Tasks

- [ ] **4.1 Fix Lint Warnings** (2h)
  - [ ] Fix dead code in `dish_detail_screen.dart:82`
  - [ ] Remove unnecessary null checks (lines 294, 304, 468)
  - [ ] Run `flutter analyze` and fix remaining issues
  - [ ] Verify no runtime errors

- [ ] **4.2 Optimize Initial Load Performance** (6h)
  - [ ] Profile app startup
  - [ ] Implement lazy loading for BLoCs
  - [ ] Optimize Supabase initialization
  - [ ] Defer Maps initialization
  - [ ] Add progress indicators to splash screen
  - [ ] Measure and verify improvements

- [ ] **4.3 Address ImageReader Buffer Warnings** (3h)
  - [ ] Investigate Google Maps buffer usage
  - [ ] Adjust buffer pool size if needed
  - [ ] Monitor memory usage
  - [ ] Consider reducing map complexity

- [ ] **4.4 Code Cleanup** (3h)
  - [ ] Remove debug print statements
  - [ ] Implement proper logging
  - [ ] Remove commented-out code
  - [ ] Format all files
  - [ ] Run code metrics

### Acceptance Criteria
- ✅ Zero lint warnings
- ✅ Initial load time <500ms
- ✅ Frame drops <10 frames
- ✅ Clean, formatted code
- ✅ Proper logging implemented

### Blockers
- None identified

### Notes
- Use `flutter run --profile --trace-startup` for profiling
- Consider adding `logger` package for structured logging

---

## Sprint 5: Testing & CI/CD (2.75 days)

**Status**: 🔴 Not Started  
**Priority**: HIGH  
**Assignee**: TBD

### Tasks

- [ ] **5.1 Fix Unit Tests** (8h)
  - [ ] Run tests and document failures
  - [ ] Fix test dependencies
  - [ ] Update mocks for API changes
  - [ ] Remove live Supabase calls
  - [ ] Fix undefined symbols
  - [ ] Organize tests by feature
  - [ ] Achieve >70% coverage

- [ ] **5.2 Fix Integration Tests** (6h)
  - [ ] Set up local Supabase for testing
  - [ ] Create test data fixtures
  - [ ] Update tests to use test database
  - [ ] Create test helpers
  - [ ] Document setup process

- [ ] **5.3 Implement CI/CD Pipeline** (6h)
  - [ ] Create GitHub Actions workflow
  - [ ] Add secrets to GitHub
  - [ ] Configure branch protection
  - [ ] Set up automated deployments
  - [ ] Test CI pipeline

- [ ] **5.4 Quality Gates** (2h)
  - [ ] Set up code coverage requirements
  - [ ] Add pre-commit hooks
  - [ ] Document quality standards
  - [ ] Test quality gates

### Acceptance Criteria
- ✅ All tests passing
- ✅ CI/CD pipeline operational
- ✅ Code coverage >70%
- ✅ Automated deployments configured
- ✅ Quality gates enforced

### Blockers
- Depends on all previous sprints

### Notes
- Use `supabase start` for local testing environment
- GitHub Actions free tier should be sufficient

---

## Daily Standup Template

### What did you complete yesterday?
- 

### What will you work on today?
- 

### Any blockers?
- 

---

## Risk Log

| Date | Risk | Impact | Mitigation | Status |
|------|------|--------|------------|--------|
| - | Navigation refactor may break flows | High | Incremental migration, extensive testing | Open |
| - | Payment code may have hidden deps | Medium | Thorough code search, staged removal | Open |
| - | Test fixes may uncover deeper issues | Medium | Fix incrementally, prioritize critical paths | Open |

---

## Change Log

| Date | Sprint | Change | Reason |
|------|--------|--------|--------|
| 2025-11-22 | - | Plan created | Initial assessment complete |

---

## Metrics

### Code Quality
- **Lint Warnings**: 6 (target: 0)
- **Test Coverage**: Unknown (target: >70%)
- **Analyzer Issues**: Unknown (target: 0)

### Performance
- **Initial Load Time**: ~1.3s (target: <500ms)
- **Frame Drops**: 43-50 frames (target: <10)
- **Memory Usage**: 15-36MB (acceptable)

### Security
- **Hard-coded Credentials**: Yes (target: No)
- **API Keys Secured**: No (target: Yes)
- **Git History Clean**: No (target: Yes)

---

## Resources

### Documentation
- [CRITICAL_REMEDIATION_PLAN.md](./CRITICAL_REMEDIATION_PLAN.md) - Full plan
- [IMMEDIATE_ACTION_CHECKLIST.md](./IMMEDIATE_ACTION_CHECKLIST.md) - Day 1 tasks
- [APP_ASSESSMENT_2025-11-22.md](../APP_ASSESSMENT_2025-11-22.md) - Current state

### Tools
- GitHub Actions (CI/CD)
- Codecov (coverage)
- flutter_dotenv (environment)
- go_router (navigation)

### Team Contacts
- Tech Lead: TBD
- Backend: TBD
- QA: TBD
- DevOps: TBD

---

**Last Updated**: 2025-11-22  
**Next Review**: TBD
