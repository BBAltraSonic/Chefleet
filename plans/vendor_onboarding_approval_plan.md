# Vendor Onboarding & Approval Implementation Plan

> **Status – Deprecated (Dec 3 2025):** Manual review and approval are no longer required because vendor accounts are auto-approved immediately after onboarding submission. The historical plan below is retained for reference only; no additional work is planned unless the business re-enables manual vetting.

## 1. Current State Recap
- **Routing & Guards:** Vendor routes live under `/vendor/*` with GoRouter shells; `RoleRouteGuard` lets only users with the vendor role access dashboards while onboarding stays open to customers seeking upgrade (@lib/core/router/app_router.dart#60-355, @lib/core/routes/role_route_guard.dart#15-66).
- **Onboarding Flow:** `VendorOnboardingBloc` captures business/location/docs/hours data, autosaves to user metadata, and inserts a vendor row with `status='pending_review'` and `is_active=false`. The success dialog dispatches `GrantVendorRole` so the vendor shell becomes selectable even though the vendor remains pending (@lib/features/vendor/blocs/vendor_onboarding_bloc.dart#37-228, @lib/features/vendor/screens/vendor_onboarding_screen.dart#818-850, @lib/core/blocs/role_bloc.dart#388-434).
- **Persistence:** `vendors` table enforces the status lifecycle via constraint + RLS; submissions are permitted only for the owner (`owner_id = auth.uid()`). Status defaults to `pending_review` (@supabase/migrations/20250120000000_base_schema.sql#41-170, @supabase/migrations/20250130000001_fix_vendor_insert_policy.sql#1-21).
- **Spec Expectations:** OpenSpec vendor-management spec already requires an admin approval queue with notifications before activation (@openspec/changes/implement-vendor-dashboard/specs/vendor-management/spec.md#3-98).

## 2. Target Workflow *(superseded by auto-approval)*
1. **Submission:** Customer completes onboarding wizard; vendor row stored as `pending_review`, documents + opening hours attached (existing).
2. **Admin Intake (New):** Pending vendors appear in an admin review list showing KYC docs, location, and metadata. Duplicate detection + fraud checks happen here.
3. **Decision:**
   - **Approve:** Admin sets `status='approved'`, flips `is_active=true`, records `reviewed_by`, `review_notes`, `reviewed_at`. Notification of type `vendor_application_status` routes the vendor to the dashboard (@lib/core/services/notification_router.dart#241-325).
   - **Reject / Needs Fix:** Admin sets `status='suspended'` (or new `needs_changes`) with notes. Applicant sees rejection reason and can resume onboarding with prefilled data.
4. **Activation:** When status becomes approved/active, role sync ensures `UserRole.vendor` is stored, vendor shell unlocks fully, and quick-tour/analytics become visible.
5. **Auditing:** All transitions logged (who reviewed, timestamps) for compliance.

## 3. Implementation Phases *(deprecated)*
### Phase A – Spec & Change Management
- Draft OpenSpec change (e.g., `implement-vendor-approval-workflow`) covering admin review, notifications, rejection handling.
- Add `tasks.md` with backend, admin UI, app UX, and QA items.

### Phase B – Backend & Database
1. **Schema Enhancements:**
   - Add columns to `vendors`: `reviewed_by UUID`, `reviewed_at TIMESTAMPTZ`, `review_notes TEXT`, optional `status_reason JSONB`.
   - Optional `vendor_review_logs` table for history (vendor_id, reviewer_id, action, notes).
2. **Business Logic:**
   - RPCs or Edge Functions: `approve_vendor`, `reject_vendor`, `request_vendor_changes` that enforce valid transitions and emit notifications.
   - Triggers to auto-notify applicants on status change and to update `users_public.vendor_profile_id` / available roles.
3. **Security:**
   - RLS policies granting update access only to service role/admin role.
   - Ensure applicants cannot escalate their own status.

### Phase C – Admin Tooling
- **MVP:** Supabase SQL playbook + CLI script for manual approvals (short term).
- **Full UI:** Internal admin dashboard listing pending vendors with filters, detail drawer for documents, approve/reject buttons, audit log view.
- **Notifications:** Ability to resend or override notifications from admin UI.

### Phase D – Vendor App UX
1. **Status Awareness:**
   - Onboarding success screen explains review timeline, adds “Check status” entry point.
   - Vendor shell detects pending vendors and shows a dedicated “Awaiting approval” screen instead of the live dashboard.
2. **Resubmission Flow:** If rejected, show notes and CTA to re-open onboarding with stored data.
3. **Approval Celebration:** Once activated, display modal/banner, optionally auto-start quick tour, highlight first tasks (add dishes, set availability).
4. **Role Switching UX:** Prevent accidental switch to vendor role until approval to avoid confusing empty dashboards.

### Phase E – Testing & Automation
- **Unit Tests:** Onboarding bloc validations, new RPC state transitions, notification routing.
- **Integration/E2E:** Simulate submit → admin approval → vendor activation; ensure customer orders can see new vendor only after activation.
- **Regression:** Ensure existing vendor dashboard functionality still works for already active vendors.
- **Monitoring:** Metrics for pending count, approval lead time, rejection reasons.

### Phase F – Rollout & Ops
- Backfill historical pending vendors by running one-time approval script or forcing resubmission.
- Train support/admin staff on new tooling; document SOP for reviewing docs, handling disputes, and enforcing SLAs.
- Feature-flag vendor dashboard gating until approval workflow fully verified in staging.

## 4. Risks & Mitigations
| Risk | Impact | Mitigation |
| --- | --- | --- |
| Admin tooling delay | Pending vendors pile up | Provide interim SQL scripts + runbooks before UI ships |
| Status mismatch between `vendors` and user roles | Vendors see wrong screens | Add transactional RPC updating both vendor row and `users_public` role data atomically |
| Notification failures | Vendors unaware of decisions | Retry strategy + inbox view of application status inside app |
| Duplicate submissions | Data clutter | Add unique constraint on owner_id + enforce single active pending application; provide resume option |

## 5. Next Actions
1. Scaffold OpenSpec change and secure approval.
2. Implement backend RPC + schema changes behind feature flag.
3. Build admin review MVP (either Supabase dashboard instructions or lightweight internal UI) to start processing real applications.
4. Update vendor app screens for status awareness and resubmission.
5. Ship automated tests + monitoring, then roll out gradually.
