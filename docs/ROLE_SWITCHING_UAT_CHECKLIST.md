# Role Switching UAT Checklist

## Overview

This checklist ensures the role switching feature is production-ready. Complete all sections before releasing to users.

**Target Completion:** Sprint 5  
**Last Updated:** 2025-01-24  
**Status:** 🔄 In Progress

---

## ✅ Functional Requirements

### Core Role Switching

- [ ] **RS-001**: Users can switch roles from Profile screen with one tap
  - [ ] Role switcher visible only for multi-role users
  - [ ] Current role displayed prominently
  - [ ] Toggle/segmented control works correctly
  - [ ] Confirmation dialog appears before switch

- [ ] **RS-002**: App behavior changes immediately without logout
  - [ ] UI updates within 500ms
  - [ ] No loading screen required
  - [ ] No app restart needed
  - [ ] User remains authenticated

- [ ] **RS-003**: Each role has isolated navigation and screens
  - [ ] Customer shell shows: Feed, Orders, Chat, Profile
  - [ ] Vendor shell shows: Dashboard, Orders, Dishes, Profile
  - [ ] Navigation history preserved when switching back
  - [ ] Bottom nav items correct for each role

- [ ] **RS-004**: Active role persists across app restarts
  - [ ] Kill app, reopen → same role active
  - [ ] Role restored within 1 second
  - [ ] No flicker or role change on startup
  - [ ] Works offline

- [ ] **RS-005**: Role syncs with Supabase backend
  - [ ] Local change syncs to database
  - [ ] Backend change reflects in app
  - [ ] Conflicts resolved (backend wins)
  - [ ] Retry logic works when offline

- [ ] **RS-006**: Realtime subscriptions update on role change
  - [ ] Customer subscriptions active in customer mode
  - [ ] Vendor subscriptions active in vendor mode
  - [ ] Old subscriptions cleaned up
  - [ ] No memory leaks

### Vendor Onboarding

- [ ] **VO-001**: New users can become vendors
  - [ ] "Become a Vendor" option in profile
  - [ ] Multi-step onboarding form works
  - [ ] All required fields validated
  - [ ] Map picker for business location works

- [ ] **VO-002**: Vendor profile created successfully
  - [ ] Business name saved
  - [ ] Business description saved
  - [ ] Location coordinates saved
  - [ ] Cuisine types saved
  - [ ] Operating hours saved

- [ ] **VO-003**: Vendor role granted after onboarding
  - [ ] `vendor` added to `availableRoles`
  - [ ] Vendor profile ID linked
  - [ ] Auto-switch to vendor mode
  - [ ] Can switch back to customer

### Role Indicator

- [ ] **RI-001**: Role indicator visible in app bar
  - [ ] Blue badge for customer mode
  - [ ] Orange badge for vendor mode
  - [ ] Tooltip shows on long press
  - [ ] Updates immediately on role switch

### Route Guards

- [ ] **RG-001**: Customer routes protected
  - [ ] Vendor cannot access `/customer/*` routes
  - [ ] Redirects to vendor dashboard
  - [ ] No error messages shown
  - [ ] Deep links handled correctly

- [ ] **RG-002**: Vendor routes protected
  - [ ] Customer cannot access `/vendor/*` routes
  - [ ] Redirects to customer feed
  - [ ] No error messages shown
  - [ ] Deep links handled correctly

- [ ] **RG-003**: Shared routes accessible
  - [ ] Profile accessible from both roles
  - [ ] Settings accessible from both roles
  - [ ] Auth screens accessible
  - [ ] Onboarding accessible

---

## ⚡ Performance Requirements

### Speed

- [ ] **PERF-001**: Role switch completes in <500ms
  - [ ] Measured with performance test
  - [ ] Consistent across devices
  - [ ] No blocking operations
  - [ ] Optimistic updates work

- [ ] **PERF-002**: No UI flicker during role switch
  - [ ] Smooth transition
  - [ ] No white screen flash
  - [ ] No layout shifts
  - [ ] 60fps maintained

- [ ] **PERF-003**: App startup with role restoration <1s
  - [ ] Cold start <3s total
  - [ ] Warm start <1s total
  - [ ] Role loaded from cache
  - [ ] Background sync doesn't block

### Memory

- [ ] **PERF-004**: Memory usage stable
  - [ ] No leaks after 10+ switches
  - [ ] IndexedStack doesn't cause bloat
  - [ ] Subscriptions cleaned up
  - [ ] Image caches managed

- [ ] **PERF-005**: Navigation state preserved
  - [ ] Switch to vendor, back to customer → history intact
  - [ ] Form data retained
  - [ ] Scroll positions preserved
  - [ ] BLoC states maintained

---

## 🧪 Testing Coverage

### Unit Tests

- [ ] **TEST-001**: RoleBloc tests pass
  - [ ] All events tested
  - [ ] All states tested
  - [ ] Error handling tested
  - [ ] >80% coverage

- [ ] **TEST-002**: RoleService tests pass
  - [ ] getActiveRole tested
  - [ ] switchRole tested
  - [ ] getAvailableRoles tested
  - [ ] roleChanges stream tested

- [ ] **TEST-003**: Storage service tests pass
  - [ ] Save/read tested
  - [ ] Cache tested
  - [ ] Clear tested
  - [ ] Error handling tested

### Widget Tests

- [ ] **TEST-004**: Role switcher widget tests pass
  - [ ] Shows for multi-role users
  - [ ] Hides for single-role users
  - [ ] Switch triggers event
  - [ ] Loading state displays

- [ ] **TEST-005**: Role indicator tests pass
  - [ ] Correct color for each role
  - [ ] Tooltip works
  - [ ] Updates on role change

### Integration Tests

- [ ] **TEST-006**: Complete flow tests pass
  - [ ] Login → switch → navigate → switch back
  - [ ] Vendor onboarding flow
  - [ ] Realtime subscription updates
  - [ ] Offline/online scenarios

### Performance Tests

- [ ] **TEST-007**: Performance benchmarks pass
  - [ ] Role switch <500ms
  - [ ] Storage ops <100ms
  - [ ] UI updates <16ms
  - [ ] Cache hits <10ms

---

## 🔐 Security

### Backend Validation

- [ ] **SEC-001**: RLS policies enforce role access
  - [ ] Customer can only see own data
  - [ ] Vendor can only see own data
  - [ ] Cross-role access blocked
  - [ ] Admin policies tested

- [ ] **SEC-002**: Database functions validate role
  - [ ] `switch_user_role()` checks available roles
  - [ ] `grant_vendor_role()` requires auth
  - [ ] No SQL injection vulnerabilities
  - [ ] Proper error messages

### Client-Side

- [ ] **SEC-003**: Route guards prevent unauthorized access
  - [ ] Cannot bypass with deep links
  - [ ] Cannot bypass with manual navigation
  - [ ] Cannot bypass with state manipulation
  - [ ] Logs unauthorized attempts

- [ ] **SEC-004**: Secure storage works
  - [ ] Role encrypted at rest
  - [ ] Cannot be read by other apps
  - [ ] Cleared on logout
  - [ ] Cleared on uninstall

---

## ♿ Accessibility

- [ ] **A11Y-001**: Role switcher accessible
  - [ ] Screen reader announces current role
  - [ ] Switch button has semantic label
  - [ ] Focus order logical
  - [ ] Tap target ≥48x48dp

- [ ] **A11Y-002**: Role indicator accessible
  - [ ] Semantic label describes role
  - [ ] Color not only indicator
  - [ ] Tooltip readable by screen reader

- [ ] **A11Y-003**: Confirmation dialog accessible
  - [ ] Title announced
  - [ ] Message readable
  - [ ] Buttons have labels
  - [ ] Dismissible with back button

---

## 📱 Platform Compatibility

### Android

- [ ] **PLAT-001**: Works on Android 8.0+ (API 26+)
  - [ ] Secure storage works
  - [ ] Navigation works
  - [ ] Realtime works
  - [ ] No crashes

- [ ] **PLAT-002**: Works on different screen sizes
  - [ ] Phone (small, normal, large)
  - [ ] Tablet (7", 10")
  - [ ] Foldable devices
  - [ ] Landscape orientation

### iOS (Future)

- [ ] **PLAT-003**: iOS compatibility verified
  - [ ] Secure storage works
  - [ ] Navigation works
  - [ ] Realtime works
  - [ ] No crashes

---

## 🌐 Network Scenarios

### Online

- [ ] **NET-001**: Role switch works online
  - [ ] Syncs to backend immediately
  - [ ] Realtime updates work
  - [ ] No errors

### Offline

- [ ] **NET-002**: Role switch works offline
  - [ ] Saves to local storage
  - [ ] UI updates immediately
  - [ ] Syncs when online again
  - [ ] No data loss

### Poor Connection

- [ ] **NET-003**: Handles slow/unstable network
  - [ ] Doesn't block UI
  - [ ] Shows appropriate loading states
  - [ ] Retries failed syncs
  - [ ] Timeout handling

---

## 📊 Data Integrity

### Persistence

- [ ] **DATA-001**: Role persists correctly
  - [ ] Survives app restart
  - [ ] Survives device restart
  - [ ] Survives app update
  - [ ] Survives cache clear

- [ ] **DATA-002**: Available roles persist
  - [ ] Vendor role retained after grant
  - [ ] Cannot lose roles
  - [ ] Syncs from backend on conflict

### Migration

- [ ] **DATA-003**: Existing users migrated
  - [ ] Default to customer role
  - [ ] Vendor users get vendor role
  - [ ] No data loss
  - [ ] No errors

---

## 🎨 UI/UX

### Visual Design

- [ ] **UI-001**: Role switcher matches design
  - [ ] Glass morphic style
  - [ ] Correct colors
  - [ ] Correct typography
  - [ ] Animations smooth

- [ ] **UI-002**: Role indicator matches design
  - [ ] Badge style correct
  - [ ] Colors correct
  - [ ] Size appropriate
  - [ ] Position correct

### User Feedback

- [ ] **UX-001**: Clear feedback on role switch
  - [ ] Loading indicator shown
  - [ ] Success message displayed
  - [ ] Error messages helpful
  - [ ] Confirmation dialog clear

- [ ] **UX-002**: Intuitive navigation
  - [ ] Easy to find role switcher
  - [ ] Easy to understand current role
  - [ ] Easy to switch roles
  - [ ] Easy to understand what changed

---

## 📖 Documentation

- [ ] **DOC-001**: User documentation complete
  - [ ] Role Switching Guide written
  - [ ] Screenshots included
  - [ ] FAQ answered
  - [ ] Troubleshooting section

- [ ] **DOC-002**: Developer documentation complete
  - [ ] Developer Guide written
  - [ ] Code examples provided
  - [ ] API reference complete
  - [ ] Architecture diagrams

- [ ] **DOC-003**: Inline documentation complete
  - [ ] All public APIs documented
  - [ ] DartDoc comments added
  - [ ] Examples in comments
  - [ ] Edge cases noted

- [ ] **DOC-004**: README updated
  - [ ] Role switching section added
  - [ ] Links to guides added
  - [ ] Project structure updated
  - [ ] Features list updated

---

## 🚀 Deployment Readiness

### Database

- [ ] **DEPLOY-001**: Migrations applied
  - [ ] `20250124000000_user_roles.sql` applied
  - [ ] No errors
  - [ ] Rollback tested
  - [ ] Backup created

- [ ] **DEPLOY-002**: RLS policies active
  - [ ] All tables have policies
  - [ ] Policies tested
  - [ ] No security gaps
  - [ ] Performance acceptable

### Backend

- [ ] **DEPLOY-003**: Edge functions deployed
  - [ ] All functions deployed
  - [ ] Environment variables set
  - [ ] Logs monitored
  - [ ] Error handling tested

### Frontend

- [ ] **DEPLOY-004**: App builds successfully
  - [ ] No compilation errors
  - [ ] No analyzer warnings (critical)
  - [ ] APK/AAB builds
  - [ ] Release mode tested

---

## 🐛 Known Issues

### Blockers (Must Fix)

- [ ] None identified

### Non-Blockers (Can Defer)

- [ ] None identified

### Future Enhancements

- [ ] Multi-vendor support (v2.0)
- [ ] Role permissions (v2.0)
- [ ] Role analytics (v2.0)
- [ ] Quick switch FAB (v2.0)
- [ ] Role scheduling (v2.0)

---

## ✅ Sign-Off

### Development Team

- [ ] **Developer**: Feature complete and tested
  - Name: ________________
  - Date: ________________
  - Signature: ________________

- [ ] **QA Engineer**: All tests pass
  - Name: ________________
  - Date: ________________
  - Signature: ________________

### Stakeholders

- [ ] **Product Owner**: Accepts feature
  - Name: ________________
  - Date: ________________
  - Signature: ________________

- [ ] **Technical Lead**: Approves architecture
  - Name: ________________
  - Date: ________________
  - Signature: ________________

---

## 📝 Notes

### Testing Environment

- **Device**: ________________
- **OS Version**: ________________
- **App Version**: ________________
- **Test Date**: ________________

### Issues Found

| ID | Description | Severity | Status | Notes |
|----|-------------|----------|--------|-------|
|    |             |          |        |       |

### Performance Metrics

| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Role switch time | <500ms | ___ms | ☐ Pass ☐ Fail |
| Storage save | <100ms | ___ms | ☐ Pass ☐ Fail |
| Storage read | <100ms | ___ms | ☐ Pass ☐ Fail |
| UI update | <16ms | ___ms | ☐ Pass ☐ Fail |
| App startup | <1s | ___ms | ☐ Pass ☐ Fail |

---

## 🎯 Success Criteria

**Feature is ready for release when:**

1. ✅ All functional requirements met (100%)
2. ✅ All performance requirements met (100%)
3. ✅ Test coverage >80%
4. ✅ All security checks pass
5. ✅ Accessibility compliance (WCAG AA)
6. ✅ Platform compatibility verified
7. ✅ Documentation complete
8. ✅ Stakeholder sign-off obtained
9. ✅ Zero critical bugs
10. ✅ Production deployment successful

---

**Status Legend:**
- ☐ Not Started
- 🔄 In Progress
- ✅ Complete
- ❌ Failed
- ⏸️ Blocked

**Last Updated:** 2025-01-24  
**Next Review:** ________________
