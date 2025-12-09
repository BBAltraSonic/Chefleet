# Change: Implement vendor approval workflow

## Why
Vendor onboarding currently stops at submission, leaving pending vendors without review, admin tooling, or status notifications. We need a governed approval workflow so admins can validate applications, record decisions, and keep applicants informed per the Phase A plan.

## What Changes
- Add vendor approval lifecycle requirements (admin intake list, approval, rejection, resubmission guidance, auditing, notifications).
- Define notification + role sync expectations when status transitions occur.
- Capture rejection reasons and resubmission flow requirements.
- Outline compliance logging expectations for every decision.

## Impact
- Affected specs: `vendor-management` capability (admin workflows + vendor UX states).
- Affected code: Supabase schema (`vendors`, new review log table), admin tooling, notification routing, vendor onboarding UX, RoleBloc sync.
