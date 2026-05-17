# CI/CD Deployment Guide

This document describes the CI/CD pipelines configured for Iconic Studio Pro and how to set up the necessary credentials and secrets.

## Table of Contents
- [Overview](#overview)
- [CI Workflow](#ci-workflow)
- [Staging Deployment](#staging-deployment)
- [Production Deployment](#production-deployment)
- [Required Secrets](#required-secrets)
- [Security Scanning](#security-scanning)
- [Monitoring and Alerts](#monitoring-and-alerts)
- [Rollback Procedures](#rollback-procedures)

## Overview

The project uses three GitHub Actions workflows:

1. **CI (ci.yml)** - Runs on all pushes and PRs
2. **Staging (staging.yml)** - Deploys to testing environments on develop/staging branch
3. **Production (production.yml)** - Deploys to production on version tags or manual trigger

## CI Workflow

**Triggers:** Push to any branch, Pull Requests

**Jobs:**
- **Analyze**: Static code analysis with `flutter analyze --fatal-infos`
- **Test**: Run widget tests with coverage reporting
  - Uploads coverage to Codecov
  - Enforces 60% minimum coverage threshold
- **Build**: Matrix build for Android, iOS, and Web
  - Uploads build artifacts (APK, IPA, web build)
  - Artifacts retained for 30 days

**Features:**
- Pub cache dependency caching for faster builds
- Parallel builds across platforms
- Automated artifact uploads

## Staging Deployment

**Triggers:**
- Push to `develop` or `staging` branch
- Manual workflow dispatch

**Platforms:**

### Android (Staging)
- Builds signed App Bundle (AAB)
- Deploys to Google Play Internal Testing track
- Version format: `1.0.0-staging+<build_number>`

### iOS (Staging)
- Builds signed IPA
- Deploys to TestFlight
- Version format: `1.0.0-staging+<build_number>`

### Web (Staging)
- Builds production web bundle with staging environment variables
- Deploys to Firebase Hosting staging channel
- Fallback: GitHub Pages (gh-pages-staging branch)

## Production Deployment

**Triggers:**
- Git tags matching `v*.*.*` (e.g., `v1.0.0`, `v1.2.3`)
- Manual workflow dispatch with version input

**Platforms:**

### Android (Production)
- Builds signed App Bundle (AAB) and APK
- Deploys to Google Play beta or production track
- Includes ProGuard mapping file
- Artifacts retained for 90 days

### iOS (Production)
- Builds signed IPA
- Deploys to TestFlight → App Store
- Artifacts retained for 90 days

### Web (Production)
- Builds production web bundle
- Deploys to Firebase Hosting live channel
- Uses production environment variables

**Release Process:**
1. Automated release notes generation from commit history
2. GitHub Release created with attached artifacts
3. Deployment status summary

## Required Secrets

Configure these secrets in **Settings → Secrets and variables → Actions**:

### Android Secrets

| Secret Name | Description | How to Generate |
|------------|-------------|-----------------|
| `ANDROID_KEYSTORE_BASE64` | Base64-encoded release keystore | `base64 -i keystore.jks` |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password | From keystore creation |
| `ANDROID_KEY_ALIAS` | Key alias | From keystore creation |
| `ANDROID_KEY_PASSWORD` | Key password | From keystore creation |
| `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` | Service account JSON for Play Console API | [Play Console → API Access](https://play.google.com/console/developers/api-access) |

**Generate Android Keystore:**
```bash
keytool -genkey -v -keystore keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias release
# Then encode it:
base64 -i keystore.jks > keystore.base64.txt
```

### iOS Secrets

| Secret Name | Description | How to Generate |
|------------|-------------|-----------------|
| `IOS_CERTIFICATE_BASE64` | Base64-encoded .p12 certificate | Export from Keychain Access |
| `IOS_CERTIFICATE_PASSWORD` | Certificate password | From certificate export |
| `IOS_KEYCHAIN_PASSWORD` | Temporary keychain password | Choose a strong password |
| `IOS_PROVISIONING_PROFILE_BASE64` | Base64-encoded provisioning profile | Download from Apple Developer |
| `APP_STORE_CONNECT_API_KEY_ID` | App Store Connect API Key ID | [App Store Connect → Users and Access → Keys](https://appstoreconnect.apple.com/access/api) |
| `APP_STORE_CONNECT_ISSUER_ID` | App Store Connect Issuer ID | From App Store Connect API Keys page |

**Generate iOS Certificate:**
```bash
# Export certificate from Keychain Access as .p12
# Then encode it:
base64 -i Certificate.p12 > certificate.base64.txt

# Encode provisioning profile:
base64 -i profile.mobileprovision > profile.base64.txt
```

### Firebase Secrets

| Secret Name | Description | How to Generate |
|------------|-------------|-----------------|
| `FIREBASE_SERVICE_ACCOUNT` | Firebase service account JSON | [Firebase Console → Project Settings → Service Accounts](https://console.firebase.google.com/) |
| `FIREBASE_PROJECT_ID` | Firebase project ID | From Firebase Console |

### Optional Secrets

| Secret Name | Description | Purpose |
|------------|-------------|---------|
| `CODECOV_TOKEN` | Codecov upload token | Enhanced coverage reporting |
| `SLACK_WEBHOOK_URL` | Slack webhook for notifications | Deployment notifications |
| `DISCORD_WEBHOOK_URL` | Discord webhook for notifications | Deployment notifications |

## Security Scanning

### Automated Security Scanning

The repository includes a comprehensive `security.yml` workflow that runs:
- **CodeQL Analysis** - Static code analysis for security vulnerabilities
- **Dependency Vulnerability Scan** - Checks for known vulnerabilities in dependencies
- **License Compliance Check** - Ensures all dependencies use compatible licenses
- **Secret Detection** - Scans for accidentally committed secrets using TruffleHog

This workflow runs:
- On every push to `main` and `develop` branches
- On pull requests to `main` and `develop`
- Weekly on Mondays (scheduled scan)
- On-demand via workflow dispatch

### Viewing Security Results

1. Navigate to the **Security** tab in your repository
2. Click **Code scanning alerts** to view CodeQL findings
3. Click **Dependabot alerts** to view dependency vulnerabilities  
4. Check the **Actions** tab → **Security Scanning** workflow for detailed reports

### Additional Security Tools (Optional)

To enable additional security features:
   - Go to **Settings → Security → Code security and analysis**
   - Enable Dependabot alerts
   - Enable Dependabot security updates

## Monitoring and Alerts

### Deployment Status Monitoring

Each workflow generates a deployment summary accessible via:
- **Actions** tab → Select workflow run → View summary

### Setting up Slack Notifications (Phase 4)

Add this step to the `notify` job in each workflow:

```yaml
- name: Notify Slack
  if: always()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    text: |
      Deployment ${{ job.status }}
      Version: ${{ steps.version.outputs.version }}
      Workflow: ${{ github.workflow }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK_URL }}
    fields: repo,commit,author,action,eventName,ref,workflow
```

### Setting up Discord Notifications (Phase 4)

```yaml
- name: Notify Discord
  if: always()
  uses: sarisia/actions-status-discord@v1
  with:
    webhook: ${{ secrets.DISCORD_WEBHOOK_URL }}
    status: ${{ job.status }}
    title: "${{ github.workflow }}"
    description: "Build for version ${{ steps.version.outputs.version }}"
```

## Rollback Procedures

### Android Rollback

**Via Google Play Console:**
1. Navigate to [Play Console](https://play.google.com/console)
2. Select your app → Production → Manage track
3. Click **Create new release**
4. Select a previous APK/AAB from the library
5. Roll out to percentage or full

**Via GitHub Actions:**
1. Find the previous successful production workflow run
2. Download the AAB artifact
3. Manually upload to Play Console

### iOS Rollback

**Via App Store Connect:**
1. Navigate to [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app → TestFlight
3. Promote a previous build to production
4. Submit for review if needed

### Web Rollback

**Firebase Hosting:**
```bash
# List previous deployments
firebase hosting:channel:list --project <project-id>

# Rollback to previous deployment
firebase hosting:rollback --project <project-id>
```

**GitHub Pages:**
```bash
# Checkout previous commit
git checkout <previous-commit-hash> -- build/web

# Force push to gh-pages
git add build/web
git commit -m "Rollback to <version>"
git push origin gh-pages --force
```

### Emergency Rollback

If you need to quickly rollback all platforms:

1. **Create rollback tag:**
   ```bash
   git tag -a v1.0.0-rollback -m "Emergency rollback"
   git push origin v1.0.0-rollback
   ```

2. **Manually trigger production workflow:**
   - Go to **Actions** → **Production Release**
   - Click **Run workflow**
   - Enter the previous stable version
   - Select deployment track

## Best Practices

1. **Always test in staging first** - Deploy to staging and test thoroughly
2. **Use semantic versioning** - Follow `v<major>.<minor>.<patch>` format
3. **Keep secrets secure** - Never commit secrets to repository
4. **Monitor deployments** - Check workflow summaries and logs
5. **Gradual rollouts** - Use staged rollouts in Play Console (10% → 50% → 100%)
6. **Version bumping** - Update `version` in `pubspec.yaml` before releases
7. **Release notes** - Add meaningful commit messages for automated release notes

## Troubleshooting

### Build Failures

**Android keystore issues:**
- Verify base64 encoding: `base64 -d <<< "$ANDROID_KEYSTORE_BASE64" > test.jks`
- Check password correctness
- Ensure key alias exists: `keytool -list -keystore keystore.jks`

**iOS signing issues:**
- Verify certificate validity: `security find-identity -v -p codesigning`
- Check provisioning profile matches bundle ID
- Ensure certificate is not expired

**Coverage threshold failures:**
- Review failing tests
- Add more test coverage
- Adjust threshold in ci.yml if appropriate

### Deployment Failures

**Google Play upload failures:**
- Verify service account has "Release Manager" role
- Ensure version code is incrementing
- Check for Play Console policy violations

**TestFlight upload failures:**
- Verify App Store Connect API key permissions
- Check certificate expiration
- Ensure bundle ID matches App Store Connect

**Firebase deployment failures:**
- Verify service account has "Firebase Hosting Admin" role
- Check Firebase project ID
- Ensure firebase.json is configured correctly

## Additional Resources

- [Flutter CI/CD Best Practices](https://docs.flutter.dev/deployment/cd)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Google Play Upload Action](https://github.com/r0adkll/upload-google-play)
- [Firebase Hosting Deploy Action](https://github.com/FirebaseExtended/action-hosting-deploy)
- [Fastlane Documentation](https://docs.fastlane.tools/)

## Support

For questions or issues with CI/CD:
1. Check workflow logs in the Actions tab
2. Review this documentation
3. Open an issue in the repository
