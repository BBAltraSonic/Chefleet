# Release Procedure Documentation

This document outlines the complete release process for the Chefleet project, including automated and manual procedures.

## Overview

The release process follows **semantic versioning** based on conventional commits and includes:

1. **Automated Quality Checks**: Code analysis, tests, security scanning
2. **Multi-Platform Builds**: Android APK/AAB, Web, iOS (manual)
3. **Staging Deployment**: Database migrations and Edge Functions
4. **Release Creation**: GitHub releases with changelog and assets
5. **Team Notifications**: Slack notifications for release status

## Release Types

### Automated Releases
- **Trigger**: Push to `main` branch
- **Process**: Full automated pipeline
- **Frequency**: Continuous deployment ready

### Manual Releases
- **Trigger**: Manual workflow dispatch
- **Process**: Interactive release with version selection
- **Use Cases**: Hotfixes, feature releases, major updates

## Pre-Release Checklist

### Code Quality
- [ ] All tests passing locally
- [ ] Code analysis shows no critical issues
- [ ] Security scan passes
- [ ] Documentation is updated
- [ ] CHANGELOG.md is updated

### Environment Readiness
- [ ] Staging environment is healthy
- [ ] Database backups are current
- [ ] Rollback procedures are tested
- [ ] Team is notified of upcoming release

### Feature Readiness
- [ ] Features are feature-flagged if needed
- [ ] A/B tests are configured
- [ ] Monitoring and alerts are set up
- [ ] Performance benchmarks are established

## Automated Release Process

### 1. Quality Checks (`quality-checks` job)

```yaml
# Runs automatically on every push to main
- Flutter code analysis
- Unit and widget tests with coverage
- Edge Functions tests
- Security vulnerability scanning
- Dependency security audit
```

**Commands for local testing:**
```bash
# Replicate quality checks locally
flutter analyze --fatal-infos
flutter test --coverage
cd functions && npm test && npm audit --audit-level=moderate && cd ..
```

### 2. Build and Test (`build-and-test` job)

```yaml
# Builds for multiple platforms
- Android APK and App Bundle
- Web build
# Future: iOS builds (requires macOS runners)
```

**Local build verification:**
```bash
# Build Android
flutter build apk --release
flutter build appbundle --release

# Build Web
flutter build web --release
```

### 3. Semantic Versioning (`semantic-release` job)

Uses conventional commits to determine version:
- `feat:` → Minor version increment
- `fix:` → Patch version increment
- `BREAKING CHANGE:` → Major version increment

**Commit message examples:**
```bash
feat(auth): add user registration functionality
fix(map): resolve marker clustering issue
docs(api): update authentication documentation
BREAKING CHANGE: migrate from v1 to v2 API
```

### 4. GitHub Release Creation (`create-release` job)

- Generates changelog from commit history
- Creates GitHub release with version tag
- Uploads build artifacts (APK, AAB, Web)
- Includes installation instructions

### 5. Staging Deployment (`deploy-staging` job)

- Deploys database migrations to staging
- Deploys Edge Functions to staging
- Verifies deployment health

### 6. Team Notification (`notify-release` job)

- Sends success notifications to Slack
- Notifies team of new release availability
- Provides download links and installation instructions

## Manual Release Process

### Trigger Manual Release

1. **Navigate to GitHub Actions**: Repository → Actions
2. **Select Release Workflow**: Choose "Release" workflow
3. **Run Workflow**: Click "Run workflow" button
4. **Select Version**: Choose patch/minor/major version
5. **Monitor Progress**: Watch workflow execution

### Manual Release Steps

```bash
# 1. Prepare release branch
git checkout main
git pull origin main
git checkout -b release/v1.2.3

# 2. Update version numbers (if needed)
# Update pubspec.yaml version
# Update any hardcoded version strings

# 3. Run local tests
flutter test
flutter analyze
flutter build apk --release

# 4. Commit and push
git commit -m "chore(release): prepare v1.2.3 release"
git push origin release/v1.2.3

# 5. Create pull request to main
# PR title: "chore(release): v1.2.3"
# Include release notes and testing results

# 6. Merge PR to trigger release
```

## Release Environment Configuration

### Required Secrets

Configure these in GitHub repository settings:

```yaml
# Supabase Integration
SUPABASE_ACCESS_TOKEN: "your-supabase-access-token"
STAGING_PROJECT_ID: "your-staging-project-id"
PRODUCTION_PROJECT_ID: "your-production-project-id"

# Notifications
SLACK_WEBHOOK_URL: "your-slack-webhook-url"

# App Store Connect (for iOS releases)
APPLE_APPSTORE_CONNECT_KEY_ID: "your-key-id"
APPLE_APPSTORE_CONNECT_ISSUER_ID: "your-issuer-id"
APPLE_APPSTORE_CONNECT_PRIVATE_KEY: "your-private-key"

# Google Play Console (for Android releases)
GOOGLE_PLAY_SERVICE_ACCOUNT_JSON: "your-service-account-json"
```

### Environment Variables

```yaml
FLUTTER_VERSION: "3.16.0"
NODE_VERSION: "18"
```

## Rollback Procedures

### Automated Rollback

1. **Failed Quality Checks**: Pipeline stops automatically
2. **Build Failures**: No release created, investigate build issues
3. **Deployment Failures**: Staging deployment rolls back automatically

### Manual Rollback

#### Database Rollback
```bash
# Identify problematic migration
supabase migration list

# Rollback to previous migration
supabase migration down <migration-name>

# Verify database state
supabase db diff --schema public
```

#### App Rollback
```bash
# Tag previous version as rollback
git tag -a v1.2.2-rollback HEAD~1 -m "Rollback release v1.2.3"
git push origin v1.2.2-rollback

# Create rollback release
# (Manual process through GitHub UI)
```

#### Edge Functions Rollback
```bash
# Deploy previous function version
supabase functions deploy --version <previous-version>

# Or rollback all functions
supabase functions deploy --rollback
```

## Post-Release Tasks

### Verification Checklist

- [ ] Release assets are downloadable
- [ ] App installs successfully on target platforms
- [ ] Key functionality works in new version
- [ ] No performance regressions detected
- [ ] Error rates are within acceptable limits
- [ ] User feedback is monitored

### Monitoring

1. **Performance Metrics**
   - App startup time
   - Memory usage
   - Network request latency
   - Crash rates

2. **Business Metrics**
   - User engagement
   - Conversion rates
   - Feature adoption
   - User satisfaction

3. **Technical Metrics**
   - API response times
   - Database query performance
   - Error logs
   - System resource usage

### Documentation Updates

- [ ] Update CHANGELOG.md with user-facing changes
- [ ] Update API documentation if applicable
- [ ] Update README.md with new features
- [ ] Create release blog post (optional)
- [ ] Update user guides and tutorials

## Release Communication

### Internal Communication

1. **Pre-Release Notification**
   - Send release announcement to team
   - Include feature summary and testing status
   - Schedule release window

2. **Release Day Notification**
   - Announce successful release
   - Provide download links
   - Include known issues and workarounds

3. **Post-Release Summary**
   - Share release metrics
   - Report on any issues encountered
   - Plan next release cycle

### External Communication

1. **GitHub Release Notes**
   - Automatically generated changelog
   - Installation instructions
   - Known issues and limitations

2. **User Communication**
   - App store release notes (iOS/Android)
   - Email announcements (for major releases)
   - Social media updates (optional)

## Troubleshooting

### Common Issues

1. **Build Failures**
   ```bash
   # Check Flutter version compatibility
   flutter doctor -v

   # Clean and rebuild
   flutter clean
   flutter pub get
   flutter build apk --release
   ```

2. **Test Failures**
   ```bash
   # Run specific failing test
   flutter test test/specific_test.dart

   # Check test dependencies
   flutter pub deps
   ```

3. **Deployment Failures**
   ```bash
   # Check Supabase CLI authentication
   supabase status

   # Verify project linking
   supabase projects list
   ```

4. **Release Creation Failures**
   ```bash
   # Check GitHub token permissions
   # Ensure proper repository access
   # Verify workflow permissions
   ```

### Getting Help

1. **Check GitHub Actions Logs**: Detailed error messages
2. **Review Workflow Runs**: Compare with successful releases
3. **Consult Team**: Ask in team channels for assistance
4. **Documentation**: Review this and other project documentation

## Release Schedule

### Regular Releases
- **Weekly**: Regular feature releases
- **Bi-weekly**: Major feature releases
- **Monthly**: Comprehensive updates

### Emergency Releases
- **Hotfixes**: As needed for critical bugs
- **Security patches**: Immediately for vulnerabilities
- **Performance issues**: Based on user impact

### Release Planning
- **Sprint Planning**: Plan releases 2-3 sprints ahead
- **Feature Freeze**: 1 week before planned release
- **Testing Window**: 3-5 days before release
- **Release Day**: Tuesday or Wednesday (optimal user engagement)

This release procedure ensures consistent, reliable releases with proper testing, deployment, and rollback capabilities.