## ADDED Requirements

### Requirement: Admin vendor intake queue
The system SHALL expose an admin-only intake queue listing all vendors whose status is `pending_review`, including core profile data, uploaded documents, and metadata needed for fraud checks.

#### Scenario: Intake shows full application context
- **WHEN** an admin opens the vendor intake queue
- **THEN** the system SHALL list every `pending_review` vendor ordered by submission time
- **AND** display business details, location, opening hours, and document links without additional navigation
- **AND** surface duplicate or risk flags for the reviewer

### Requirement: Vendor approval decisions
The system SHALL allow authorized reviewers to approve a vendor, which activates the vendor profile, grants the vendor role, and records the decision metadata.

#### Scenario: Vendor approved with audit trail
- **WHEN** an admin chooses Approve on a pending vendor
- **THEN** the system SHALL set vendor status to `approved`, `is_active=true`, and persist `reviewed_by`, `reviewed_at`, and `review_notes`
- **AND** append an entry to the vendor review log capturing reviewer, action, notes, and timestamp
- **AND** trigger a `vendor_application_status` notification directing the vendor to the dashboard
- **AND** sync available roles so the vendor shell becomes accessible only after approval

### Requirement: Vendor rejection and changes requested
The system SHALL support rejecting an application or requesting changes, ensuring applicants see reasons and can resubmit using saved data.

#### Scenario: Rejection with resubmission path
- **WHEN** an admin selects Reject (or Needs Changes) for a pending vendor
- **THEN** the system SHALL set vendor status to `suspended` or `needs_changes`, persist reviewer notes, and keep the vendor inactive
- **AND** notify the applicant with the provided reasons and guidance
- **AND** allow the vendor to reopen onboarding with pre-filled previous data to address feedback

### Requirement: Status notifications and role gating
The system SHALL notify vendors of every status transition and prevent switching into the vendor shell until status is approved/active.

#### Scenario: Pending vendors blocked from dashboard
- **WHEN** a vendor attempts to switch into vendor mode while their status is `pending_review` or `needs_changes`
- **THEN** the system SHALL show an "Awaiting approval" experience instead of the live dashboard
- **AND** offer a "Check application status" entry point summarizing latest reviewer notes

#### Scenario: Approval unlocks vendor experience
- **WHEN** a vendor receives an approval notification
- **AND** opens the app
- **THEN** the system SHALL automatically enable the vendor role, show a celebration/quick-start checklist, and route them to the dashboard

### Requirement: Review auditing and compliance logging
All vendor status changes SHALL be auditable with immutable logs for compliance.

#### Scenario: Complete audit history available
- **WHEN** compliance staff export audit logs for a vendor
- **THEN** the system SHALL provide a chronological record of every review action (submit, approve, reject, needs changes) including reviewer, notes, and timestamps
- **AND** include references to the notification events sent to the vendor
- **AND** ensure logs cannot be modified by non-admin users
