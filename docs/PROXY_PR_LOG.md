# Proxy  Upstream PR Tracking Log

Track every PR merged into `proxy/integration` that needs replication to
`microsoft/Teams-AdaptiveCards-Mobile` main.

## Status Legend

| Status | Meaning |
|--------|---------|
| `pending` | Merged to proxy; not yet proposed upstream |
| `upstream-pr` | PR opened against upstream |
| `merged` | Upstream PR merged |
| `skipped` | Proxy-only (CI config, docs)  no upstream PR needed |

## Tracking Table

| # | Proxy PR | Date | Title | Commit | Status | Upstream PR |
|---|----------|------|-------|--------|--------|-------------|
| 1 |  | 2025-01-18 | ci: add agent validation gate | `04ff142d` | skipped | CI-only, not applicable to upstream |
| 2 |  | 2025-01-18 | ci: skip invalid test JSON files | `b4c4ef0b` | skipped | CI-only |
| 3 |  | 2025-01-18 | docs: add proxy branch tracker | `6117dc06` | skipped | Docs-only |
| 4 |  | 2025-01-18 | ci: upgrade gate with visual regression | `3eb25eee` | skipped | CI-only |
| 5 |  | 2026-03-01 | docs: add proxy workflow guide + PR log | `d798b829` | skipped | Docs-only |
| 6 | #14 | 2026-03-01 | docs: add descriptive comment to SharedAdaptiveCard.cpp | `7bd23944` | upstream-pr | [#508](https://github.com/microsoft/Teams-AdaptiveCards-Mobile/pull/508) |

---

## How to Add an Entry

When a PR is merged into `proxy/integration`, add a new row:

```markdown
| <next_#> | #<pr_number> | YYYY-MM-DD | <title> | `<short_hash>` | upstream-pr | [#508](https://github.com/microsoft/Teams-AdaptiveCards-Mobile/pull/508) |
```

When the upstream PR is created:

```markdown
| <#> | #<pr_number> | YYYY-MM-DD | <title> | `<short_hash>` | upstream-pr | [#NNN](https://github.com/microsoft/Teams-AdaptiveCards-Mobile/pull/NNN) |
```

When merged upstream:

```markdown
| <#> | #<pr_number> | YYYY-MM-DD | <title> | `<short_hash>` | merged | [#NNN](https://github.com/microsoft/Teams-AdaptiveCards-Mobile/pull/NNN) |
```
