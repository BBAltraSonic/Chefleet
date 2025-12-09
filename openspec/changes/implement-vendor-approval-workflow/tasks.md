## 1. Specification & Change Management
- [ ] 1.1 Review existing `vendor-management` spec and prior changes for conflicts.
- [ ] 1.2 Author spec delta describing admin review queues, decision logging, and notifications.
- [ ] 1.3 Validate change via `openspec validate implement-vendor-approval-workflow --strict` and circulate for approval.

## 2. Backend & Database
- [ ] 2.1 Extend `vendors` table with review metadata (`reviewed_by`, `reviewed_at`, `review_notes`, `status_reason`).
- [ ] 2.2 Create `vendor_review_logs` table capturing reviewer, action, notes, and timestamps for every transition.
- [ ] 2.3 Implement secure RPC/Edge functions: `approve_vendor`, `reject_vendor`, `request_vendor_changes`, enforcing valid transitions + logging.
- [ ] 2.4 Emit notifications + role sync out of RPCs (update `users_public.vendor_profile_id`, available roles) using transactional logic.
- [ ] 2.5 Update RLS so only admins/service role can change vendor status or insert review logs.

## 3. Admin Tooling
- [ ] 3.1 Ship interim SQL/CLI review scripts (pending vendor list, approve/reject commands with notes).
- [ ] 3.2 Build internal admin UI list with filters, detail drawer (docs, opening hours, owner info).
- [ ] 3.3 Wire approve/reject/needs-changes actions to backend endpoints and display audit history.
- [ ] 3.4 Provide ability to resend vendor status notifications from the admin UI.

## 4. Vendor App UX & Notifications
- [ ] 4.1 Update onboarding success screen with review timeline and link to "Application Status" screen.
- [ ] 4.2 Add pending-state screen inside vendor shell; block dashboard features until status is approved/active.
- [ ] 4.3 Implement rejection/resubmission flow showing review notes and pre-filling previous data.
- [ ] 4.4 Add approval celebration + quick-start checklist once status flips to active.
- [ ] 4.5 Ensure RoleBloc and notification router respond to status updates (switch to vendor role only when approved/active).

## 5. Testing & Monitoring
- [ ] 5.1 Unit tests for RPC state transitions, notification emission, RoleBloc sync, and onboarding bloc status awareness.
- [ ] 5.2 Integration test covering submit → admin approval → vendor activation + customer visibility checks.
- [ ] 5.3 Regression tests for existing active vendors (dashboard, orders) ensuring no regressions.
- [ ] 5.4 Monitoring dashboards: pending counts, review lead time, rejection reasons, notification failures.
