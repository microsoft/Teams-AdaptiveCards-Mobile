# Proxy Branch Workflow

## Overview

The `proxy/integration` branch on `hggzm/Teams-AdaptiveCards-Mobile` serves as a
**staging area** where changes are validated before being proposed to the upstream
`microsoft/Teams-AdaptiveCards-Mobile` repository.

### Why a Proxy Branch?

1. **Gate validation**  Every push to `proxy/**` triggers the Agent Validation Gate
   (unit tests, visual regression, parity checks) *before* touching upstream.
2. **Safe iteration**  Agents (and humans) can push experimental work, iterate on
   failures, and only propose upstream PRs once the gate is green.
3. **PR tracking**  Changes merged into `proxy/integration` are tracked in
   `docs/PROXY_PR_LOG.md` until they are replicated as PRs on `microsoft/Teams-AdaptiveCards-Mobile`.

---

## Repositories

| Role | Repo | URL |
|------|------|-----|
| **Upstream** (production) | `microsoft/Teams-AdaptiveCards-Mobile` | https://github.com/microsoft/Teams-AdaptiveCards-Mobile |
| **Fork** (our work) | `hggzm/Teams-AdaptiveCards-Mobile` | https://github.com/hggzm/Teams-AdaptiveCards-Mobile |

### Local Remotes

```
origin    git@github.com:hggzm/Teams-AdaptiveCards-Mobile.git   (push to fork)
upstream  https://github.com/microsoft/Teams-AdaptiveCards-Mobile.git  (read-only)
```

---

## Workflow: Making a Change

### Step 1: Create a Feature Branch

```bash
cd ~/code/Teams-AdaptiveCards-Mobile
git checkout proxy/integration
git pull origin proxy/integration
git checkout -b proxy/my-feature
```

### Step 2: Make Changes and Push

```bash
# ... edit files ...
git add -A
git commit -m "feat: describe your change"
git push origin proxy/my-feature
```

### Step 3: Open a PR Against `proxy/integration`

```bash
gh pr create \
  --repo hggzm/Teams-AdaptiveCards-Mobile \
  --base proxy/integration \
  --head proxy/my-feature \
  --title "feat: describe your change" \
  --body "Description of the change."
```

The Agent Validation Gate will automatically run on the PR.

### Step 4: Merge the PR

Once the gate passes, merge the PR into `proxy/integration`.

```bash
gh pr merge <PR_NUMBER> --repo hggzm/Teams-AdaptiveCards-Mobile --squash
```

### Step 5: Log it for Upstream Replication

Add an entry to `docs/PROXY_PR_LOG.md`:

```markdown
| <proxy_pr_number> | <date> | <title> | <commit_hash> | pending |  |
```

### Step 6: Replicate to Upstream

Create the same change as a PR on `microsoft/Teams-AdaptiveCards-Mobile`:

```bash
# Create branch from upstream/main
git fetch upstream
git checkout -b upstream/my-feature upstream/main

# Cherry-pick or re-apply the change
git cherry-pick <commit_hash>  # or manually apply

# Push to fork (PRs to microsoft/ come from the fork)
git push origin upstream/my-feature

# Open PR against upstream
gh pr create \
  --repo microsoft/Teams-AdaptiveCards-Mobile \
  --base main \
  --head hggzm:upstream/my-feature \
  --title "feat: describe your change" \
  --body "Cherry-picked from proxy/integration (hggzm PR #<proxy_pr_number>)."
```

### Step 7: Update the Log

Once the upstream PR is merged, update `docs/PROXY_PR_LOG.md`:

```markdown
| <proxy_pr_number> | <date> | <title> | <commit_hash> | merged | <upstream_pr_url> |
```

---

## Agent Validation Gate (E2E)

**Workflow file:** `.github/workflows/agent-gate.yml`

Triggers on every push to `proxy/**` or `main`, and on PRs targeting those branches.

### Jobs (9 total)

| # | Job | Runner | Blocking | Description |
|---|-----|--------|----------|-------------|
| 1a | Structure + JSON Validation | ubuntu | Yes | Repo structure, test card JSON syntax |
| 2a | iOS SPM Build + Test | macOS 15 | Yes | `swift build` + `swift test --filter AdaptiveCardsTest` |
| 2b | iOS Xcode Build + Unit Tests | macOS 15 | No | xcworkspace build + AdaptiveCardsTests via xcodebuild |
| 2c | Android Build | ubuntu | Yes | `./gradlew :adaptivecards:assembleDebug` |
| 2d | Android Unit Tests | ubuntu | No | `./gradlew :adaptivecards:testDebugUnitTest` |
| 3a | iOS Visual Regression | macOS 15 | No | ADCIOSVisualizer card rendering + xcresult |
| 3b | Android Visual Regression | ubuntu | No | Full build + rendering test output |
| 4 | Cross-Platform Parity | ubuntu | No | Source file counts, test card inventory |
|  | **GATE VERDICT** | ubuntu |  | Aggregates results; fails if any blocking job fails |

### Checking Gate Status

```bash
# Latest run conclusion
gh run list --repo hggzm/Teams-AdaptiveCards-Mobile \
  --workflow agent-gate.yml --limit 1 --json conclusion

# Detailed job breakdown
gh run view <RUN_ID> --repo hggzm/Teams-AdaptiveCards-Mobile
```

### Artifacts Produced

| Artifact | Contents |
|----------|----------|
| `ios-unit-test-logs` | xcodebuild test output |
| `ios-visual-test-results` | HTML report + test log from ADCIOSVisualizer |
| `ios-visual-xcresult` | Xcode result bundle |
| `android-unit-test-reports` | JUnit XML + HTML test reports |
| `android-visual-test-results` | HTML report + test log |
| `android-test-reports-visual` | JUnit XML from rendering tests |

### Recording Visual Baselines

Use the manual trigger with `record_baselines: true`:

```bash
gh workflow run agent-gate.yml \
  --repo hggzm/Teams-AdaptiveCards-Mobile \
  --ref proxy/integration \
  -f record_baselines=true
```

---

## Syncing with Upstream

### Pulling upstream changes into proxy/integration

```bash
git fetch upstream
git checkout proxy/integration

# Merge upstream changes
git merge upstream/main --no-edit

# Resolve any conflicts, then push
git push origin proxy/integration
```

### Keeping proxy/integration up to date

Run this periodically (or after major upstream merges):

```bash
git fetch upstream
git log --oneline proxy/integration..upstream/main  # see what's new
git checkout proxy/integration
git merge upstream/main
git push origin proxy/integration
```

---

## Dashboard Tracking

The autonomy engine monitors this fork via two jobs:

| Job ID | What it does | Interval |
|--------|-------------|----------|
| `github-issues-sync-prod-fork` | Syncs issues from the fork | 600s |
| `github-work-state-tracker-prod-fork` | Tracks work state on the fork | 300s |

---

## Key Paths

| Path | Description |
|------|-------------|
| `.github/workflows/agent-gate.yml` | Agent validation gate (E2E) |
| `docs/PROXY_BRANCH_WORKFLOW.md` | This document |
| `docs/PROXY_PR_LOG.md` | PR tracking log (proxy -> upstream) |
| `docs/PROXY_BRANCH_TRACKER.md` | Legacy tracker (initial setup notes) |
| `Package.swift` | SPM package manifest (iOS) |
| `source/ios/AdaptiveCards/AdaptiveCards.xcworkspace` | Xcode workspace |
| `source/android/build.gradle` | Top-level Gradle build |
| `source/shared/cpp/ObjectModel/` | Shared C++ object model |

## Build Systems

### iOS
- **SPM** (`Package.swift`): ObjectModel (C++17) + AdaptiveCards (ObjC/Swift) + AdaptiveCardsTest. iOS 13+.
- **Xcode** (`AdaptiveCards.xcworkspace`): CocoaPods (FluentUI, SVGKit). iOS 15+.

### Android
- Gradle 8.10, AGP 8.5.2, Kotlin 1.9.24, JDK 17, NDK 28.0.13004108
- CMake builds `adaptivecards-native-lib` shared library from `source/shared/cpp/ObjectModel/*.cpp`
