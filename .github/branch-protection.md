# Branch Protection Rules

This document outlines the branch protection rules that should be configured for the Chefleet repository.

## Main Branch Protection

The `main` branch is protected with the following rules:

### Required Status Checks
- [x] **Require status checks to pass before merging**
- [x] **Require branches to be up to date before merging**

### Required Checks
- `ci/ci` (or equivalent CI pipeline)
- `format/lint` (code formatting and linting)
- `test/unit` (unit tests)
- `test/integration` (integration tests)

### Enforcement Rules
- [x] **Require pull request reviews before merging**
- [x] **Require approval from PR reviewers**
- [x] **Dismiss stale PR approvals when new commits are pushed**
- [x] **Require review from Code Owners**
- [x] **Restrict pushes that create matching branches**
- [x] **Allow force pushes** (disabled)
- [x] **Allow deletions** (disabled)

### Review Requirements
- **Required approving reviewers**: 1
- **Require approval of the most recent review**
- **Require code owner review** (for files with CODEOWNERS)

### Branch Restrictions
- **Who can push**: Nobody (require PRs only)
- **Who can merge**: Users with write access
- **Include administrators** (enforce rules on admins too)

## Implementation

### GitHub Settings
To configure these rules in GitHub:
1. Go to Repository Settings > Branches
2. Add branch protection rule for `main`
3. Configure all the settings listed above

### GitHub Actions
These rules are enforced through:
- Branch protection settings
- Required status checks from GitHub Actions
- CODEOWNERS file for code ownership

### Automation
- Automatic branch cleanup after merge
- Stale bot for inactive PRs
- Dependency updates via Dependabot

## Feature Branch Guidelines

### Naming Conventions
- `feature/description` - New features
- `fix/description` - Bug fixes
- `refactor/description` - Code refactoring
- `docs/description` - Documentation changes
- `test/description` - Test additions/modifications
- `chore/description` - Maintenance tasks

### Branch Deletion
- Feature branches are automatically deleted after successful merge
- Stale branches (> 30 days) are automatically deleted
- Protected branches require explicit deletion

### Branch Permissions
- All team members can create feature branches
- Only maintainers can push to `main` (via PR merge)
- No force pushes allowed to any branch