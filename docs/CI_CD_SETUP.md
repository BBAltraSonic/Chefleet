# CI/CD Setup Guide

**Version**: 1.0.0  
**Last Updated**: 2025-11-23  
**Sprint**: 5 - Testing & CI/CD

---

## Quick Start

### 1. Configure GitHub Secrets

Navigate to your GitHub repository → Settings → Secrets and variables → Actions

Add the following secrets:

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
GOOGLE_MAPS_API_KEY=your_google_maps_key_here
CODECOV_TOKEN=your_codecov_token_here (optional)
```

### 2. Enable Branch Protection

Settings → Branches → Add rule for `main`:

- ✅ Require status checks to pass before merging
- ✅ Require branches to be up to date before merging
- ✅ Status checks: `test`, `build-android`, `build-ios`
- ✅ Require pull request reviews before merging (1 reviewer)
- ✅ Dismiss stale pull request approvals when new commits are pushed

### 3. Install Pre-commit Hooks

```bash
# Install pre-commit
pip install pre-commit

# Install hooks
pre-commit install

# Test hooks
pre-commit run --all-files
```

---

## GitHub Actions Workflows

### Test Workflow

**File**: `.github/workflows/test.yml`  
**Triggers**: Push and PR to `main` and `develop`

**Jobs**:
1. Checkout code
2. Setup Flutter (3.35.5)
3. Get dependencies
4. Verify formatting
5. Analyze code
6. Run tests with coverage
7. Upload coverage to Codecov
8. Check coverage threshold (70%)

**Duration**: ~5-7 minutes

### Build Workflow

**File**: `.github/workflows/build.yml`  
**Triggers**: Push to `main`, tags `v*`

**Jobs**:

#### build-android
1. Setup Java 17
2. Setup Flutter
3. Create .env file
4. Build APK
5. Build App Bundle
6. Upload artifacts

**Duration**: ~10-15 minutes

#### build-ios
1. Setup Flutter (macOS)
2. Create .env file
3. Build iOS (no codesign)
4. Upload artifacts

**Duration**: ~15-20 minutes

---

## Pre-commit Hooks

### Configured Hooks

1. **Built-in Hooks**
   - Trailing whitespace removal
   - End-of-file fixer
   - YAML/JSON syntax check
   - Merge conflict detection
   - Large file prevention (1MB limit)
   - Line ending enforcement (LF)

2. **Conventional Commits**
   - Enforces commit message format
   - Allowed types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
   - Optional scopes: flutter, backend, database, ui, api, auth, maps, chat

3. **Dart/Flutter**
   - `dart format` - Auto-format code
   - `dart analyze` - Static analysis
   - `flutter test` - Run tests on changed files

4. **SQL**
   - SQLFluff formatting and linting

5. **JavaScript/TypeScript**
   - ESLint for edge functions

6. **Security**
   - Detect secrets in code

### Usage

```bash
# Run on all files
pre-commit run --all-files

# Run specific hook
pre-commit run dart-format

# Skip hooks (not recommended)
git commit --no-verify

# Update hooks
pre-commit autoupdate
```

---

## Local Development Workflow

### Before Committing

```bash
# 1. Format code
dart format .

# 2. Analyze code
dart analyze --fatal-infos

# 3. Run tests
flutter test

# 4. Check coverage
flutter test --coverage
lcov --summary coverage/lcov.info

# 5. Commit (pre-commit hooks run automatically)
git add .
git commit -m "feat: add new feature"
```

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Examples**:

```bash
# Feature
git commit -m "feat(auth): add guest user conversion"

# Bug fix
git commit -m "fix(map): resolve marker clustering issue"

# Documentation
git commit -m "docs: update testing guide"

# Refactor
git commit -m "refactor(ui): improve glass container performance"

# Test
git commit -m "test(cache): add cache service unit tests"
```

---

## CI/CD Pipeline Flow

### Pull Request Flow

```
Developer → Create PR
    ↓
GitHub Actions → Run test workflow
    ↓
    ├─ Format check
    ├─ Static analysis
    ├─ Unit tests
    └─ Coverage check
    ↓
Status checks pass → Ready for review
    ↓
Code review → Approved
    ↓
Merge to main
```

### Main Branch Flow

```
Merge to main
    ↓
GitHub Actions → Run build workflow
    ↓
    ├─ Build Android APK
    ├─ Build Android AAB
    └─ Build iOS app
    ↓
Upload artifacts
    ↓
Ready for deployment
```

### Tag/Release Flow

```
Create tag (v1.0.0)
    ↓
GitHub Actions → Run build workflow
    ↓
Build all platforms
    ↓
Upload artifacts to release
    ↓
Ready for distribution
```

---

## Troubleshooting

### CI/CD Issues

#### Test Workflow Fails

**Issue**: Tests fail on CI but pass locally

**Solutions**:
1. Check environment variables are set
2. Ensure dependencies are up to date
3. Check for flaky tests
4. Review CI logs for specific errors

```bash
# Run tests in CI mode locally
flutter test --reporter=expanded
```

#### Build Workflow Fails

**Issue**: Build fails on CI

**Solutions**:
1. Verify secrets are configured
2. Check Flutter version matches
3. Ensure .env file is created correctly
4. Review build logs

```bash
# Test build locally
flutter build apk --release
flutter build appbundle --release
```

#### Coverage Check Fails

**Issue**: Coverage below 70%

**Solutions**:
1. Add tests for uncovered code
2. Check coverage report: `coverage/html/index.html`
3. Focus on critical paths first

```bash
# Generate coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Pre-commit Hook Issues

#### Hooks Too Slow

**Issue**: Pre-commit hooks take too long

**Solutions**:
1. Skip non-essential hooks for quick commits
2. Optimize hook configuration
3. Run hooks manually before commit

```bash
# Skip hooks for quick fix
git commit --no-verify -m "fix: quick fix"

# Then run hooks manually
pre-commit run --all-files
```

#### Hook Failures

**Issue**: Pre-commit hook fails

**Solutions**:
1. Read error message carefully
2. Fix the issue
3. Re-run commit

```bash
# Fix formatting issues
dart format .

# Fix analysis issues
dart analyze

# Re-commit
git commit -m "feat: add feature"
```

---

## Best Practices

### 1. Always Run Tests Locally

```bash
# Before pushing
flutter test
```

### 2. Keep Coverage High

```bash
# Check coverage regularly
flutter test --coverage
lcov --summary coverage/lcov.info
```

### 3. Use Conventional Commits

```bash
# Good
git commit -m "feat(auth): add login screen"

# Bad
git commit -m "updates"
```

### 4. Review CI Logs

- Check failed workflows immediately
- Fix issues before merging
- Don't bypass CI checks

### 5. Keep Dependencies Updated

```bash
# Update dependencies
flutter pub upgrade

# Update pre-commit hooks
pre-commit autoupdate
```

---

## Monitoring

### GitHub Actions

- View workflow runs: Repository → Actions
- Check status badges in README
- Review failed runs immediately

### Code Coverage

- View coverage reports in Codecov
- Track coverage trends
- Set coverage goals per module

### Quality Metrics

- Monitor test pass rate
- Track build success rate
- Review pre-commit hook usage

---

## Advanced Configuration

### Custom Workflow

Create `.github/workflows/custom.yml`:

```yaml
name: Custom Workflow

on:
  workflow_dispatch:  # Manual trigger

jobs:
  custom:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.35.5'
      - run: flutter pub get
      - run: # Your custom commands
```

### Custom Pre-commit Hook

Add to `.pre-commit-config.yaml`:

```yaml
- repo: local
  hooks:
    - id: custom-check
      name: Custom Check
      entry: ./scripts/custom-check.sh
      language: system
      pass_filenames: false
```

---

## Resources

### Documentation

- [GitHub Actions](https://docs.github.com/en/actions)
- [Pre-commit](https://pre-commit.com/)
- [Flutter CI/CD](https://docs.flutter.dev/deployment/cd)
- [Conventional Commits](https://www.conventionalcommits.org/)

### Tools

- [Codecov](https://codecov.io/)
- [Act](https://github.com/nektos/act) - Run GitHub Actions locally
- [Pre-commit CI](https://pre-commit.ci/) - Automated pre-commit updates

### Examples

- `.github/workflows/test.yml` - Test workflow
- `.github/workflows/build.yml` - Build workflow
- `.pre-commit-config.yaml` - Pre-commit configuration

---

## Support

### Common Commands

```bash
# CI/CD
gh workflow list                    # List workflows
gh workflow view test              # View workflow
gh run list                        # List workflow runs
gh run view <run-id>              # View run details

# Pre-commit
pre-commit run --all-files        # Run all hooks
pre-commit run <hook-id>          # Run specific hook
pre-commit clean                  # Clean cache
pre-commit autoupdate             # Update hooks

# Testing
flutter test                      # Run tests
flutter test --coverage           # With coverage
flutter test --reporter=expanded  # Verbose output

# Building
flutter build apk                 # Build APK
flutter build appbundle           # Build AAB
flutter build ios                 # Build iOS
```

### Getting Help

- Check workflow logs in GitHub Actions
- Review pre-commit documentation
- Ask in team chat
- Create issue for CI/CD problems

---

**Last Updated**: 2025-11-23  
**Maintained By**: Development Team
