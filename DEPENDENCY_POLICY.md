# Dependency Management Policy

This document outlines the policy for managing dependencies in the Chefleet project to ensure security, stability, and maintainability.

## Overview

Dependencies are managed separately for different parts of the project:
- **Flutter/Dart packages** managed via `pubspec.yaml`
- **Node.js packages** for Edge Functions managed via `package.json`
- **GitHub Actions** managed via workflow files
- **System dependencies** managed via documentation

## Principles

1. **Security First**: All dependencies must pass security scanning
2. **Stability**: Prefer stable, well-maintained packages
3. **Minimal Dependencies**: Only include dependencies that are absolutely necessary
4. **Version Pinning**: Use exact versions when possible
5. **Regular Updates**: Keep dependencies up-to-date with automated tools
6. **License Compliance**: Ensure all dependencies have compatible licenses

## Flutter/Dart Dependencies

### Package Selection Criteria

- **Active Maintenance**: Package must be updated within last 6 months
- **Community Support**: Good GitHub stars, issues response rate
- **Flutter Compatibility**: Compatible with current Flutter version
- **Documentation**: Clear documentation and examples
- **License**: MIT, BSD, Apache 2.0 preferred

### Version Management

```yaml
# pubspec.yaml
dependencies:
  # Use exact versions for critical dependencies
  flutter_bloc: ^8.1.3  # Caret for compatible updates
  google_maps_flutter: ^2.5.0

  # Use path versions for pre-release
  some_package:
    git:
      url: https://github.com/author/repo.git
      ref: main
```

### Dependency Categories

1. **Core Dependencies**: Essential for app functionality
   - Minimum versions strictly enforced
   - Manual review before updates

2. **Development Dependencies**: Tools for development and testing
   - Automated updates via Dependabot
   - Regular security scanning

3. **Optional Dependencies**: Feature-specific packages
   - Careful evaluation before inclusion
   - Consider bundle size impact

### Update Process

```bash
# Check for outdated packages
flutter pub outdated

# Update packages (interactive)
flutter pub upgrade

# Update specific package
flutter pub add package_name:^version

# Update all packages
flutter pub upgrade --major-versions
```

## Node.js Dependencies (Edge Functions)

### Package Selection

- **Minimal Footprint**: Small, focused packages
- **Security**: No known vulnerabilities
- **TypeScript Support**: Prefer typed packages
- **Maintenance**: Active development and support

### Security Scanning

```bash
# Audit dependencies
npm audit

# Fix vulnerabilities
npm audit fix

# Check for known vulnerabilities
npm audit --audit-level=moderate
```

### Update Strategy

- **Patch Updates**: Automatic via Dependabot
- **Minor Updates**: Review before merge
- **Major Updates**: Manual migration plan required

## License Compliance

### Approved Licenses

- **MIT**: Fully approved
- **BSD 2-Clause**: Fully approved
- **BSD 3-Clause**: Fully approved
- **Apache 2.0**: Fully approved
- **ISC**: Fully approved

### License Review Process

1. **Check License**: Review package license
2. **Compatibility**: Ensure compatibility with project license
3. **Attribution**: Note attribution requirements
4. **Documentation**: Document license decisions

```bash
# Check Flutter package licenses
flutter pub deps --style=tree

# Check Node.js package licenses
npx license-checker --onlyAllow 'MIT;Apache-2.0;BSD-2-Clause;BSD-3-Clause;ISC'
```

## Security Management

### Automated Scanning

1. **Dependabot**: Automated vulnerability detection
2. **GitHub Security**: Code scanning alerts
3. **Snyk Integration**: Enhanced vulnerability detection
4. **Custom Scripts**: Additional security checks

### Security Response Process

1. **Alert Received**: Automatic vulnerability notification
2. **Assessment**: Evaluate impact and severity
3. **Prioritization**: High severity > Medium > Low
4. **Resolution**: Update or replace vulnerable package
5. **Verification**: Test and validate fixes
6. **Documentation**: Record resolution process

### Security Checklist

- [ ] No known critical vulnerabilities
- [ ] All dependencies have compatible licenses
- [ ] Dependency versions are pinned
- [ ] Security scanning passes
- [ ] Regular dependency reviews scheduled

## Quality Assurance

### Dependency Reviews

**Quarterly Reviews**:
- Package usage and necessity
- Alternative package evaluation
- Bundle size impact
- Performance impact

**Monthly Reviews**:
- Update available packages
- Security vulnerability assessment
- License compliance check

### Testing

```bash
# Flutter tests
flutter test
flutter test --coverage

# Edge Functions tests
npm test
npm run test:coverage
```

### Performance Monitoring

- Bundle size tracking
- Startup performance impact
- Memory usage monitoring
- Network request optimization

## Documentation Requirements

### Package Documentation

For each new dependency, document:
1. **Purpose**: Why this package is needed
2. **Alternatives considered**: Other options evaluated
3. **License**: License type and compliance
4. **Maintenance**: Package maintenance status
5. **Security**: Known security considerations

### Change Documentation

Document all dependency changes in:
- PR descriptions
- CHANGELOG.md
- Release notes

## Tools and Automation

### Automated Tools

1. **Dependabot**: Automated dependency updates
2. **GitHub Security**: Vulnerability scanning
3. **Pre-commit hooks**: Code quality checks
4. **CI/CD Pipeline**: Automated testing

### Scripts

```bash
# scripts/check-dependencies.sh
#!/bin/bash
echo "Checking Flutter dependencies..."
flutter pub deps --style=tree

echo "Checking Node.js dependencies..."
cd functions && npm audit && cd ..

echo "Checking licenses..."
flutter pub deps | grep -E "(MIT|Apache|BSD|ISC)"

echo "Dependency check complete."
```

```bash
# scripts/update-dependencies.sh
#!/bin/bash
echo "Updating Flutter dependencies..."
flutter pub upgrade

echo "Updating Node.js dependencies..."
cd functions && npm update && cd ..

echo "Running tests..."
flutter test
cd functions && npm test && cd ..

echo "Dependency update complete."
```

## Rollback Procedures

### Emergency Rollback

If a dependency update causes issues:

1. **Identify Problem**: Pinpoint problematic dependency
2. **Revert Changes**: Rollback to previous version
3. **Test**: Verify functionality restored
4. **Document**: Record issue and resolution
5. **Report**: Alert team about dependency issue

### Rollback Commands

```bash
# Flutter
flutter pub add package_name:previous_version

# Node.js
cd functions
npm install package_name@previous_version
```

## Contact and Support

### Team Responsibilities

- **@flutter-team**: Flutter dependency management
- **@backend-team**: Edge Functions dependency management
- **@devops-team**: GitHub Actions and infrastructure dependencies
- **@team-leads**: License compliance and security review

### Escalation

1. **Security Vulnerabilities**: Immediate escalation to security team
2. **License Issues**: Legal team consultation
3. **Breaking Changes**: Architecture team review
4. **Performance Impact**: Performance team evaluation

## Review Schedule

- **Weekly**: Automated dependency updates
- **Monthly**: Security vulnerability review
- **Quarterly**: Comprehensive dependency audit
- **Annually**: License compliance review

This policy should be reviewed and updated annually or as project needs change.