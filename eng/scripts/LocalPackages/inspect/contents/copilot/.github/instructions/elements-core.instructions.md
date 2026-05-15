---
description: Invariants enforced by Elements.Core in any consuming C# code.
applyTo: "**/*.cs"
---

- Never read wall-clock time directly. `DateTime.UtcNow`, `DateTime.Now`, `DateTimeOffset.UtcNow`, `DateTimeOffset.Now`, and `Stopwatch.GetTimestamp()` (when used as a clock) are forbidden in non-test code. Inject `MyOrg.Elements.Time.IClock` and call `_clock.UtcNow`. Run the `elements-core-iclock-migrate` skill to fix violations.
- Any type derived from `ValueObject` is immutable. Override `GetEqualityComponents()` to yield every field that participates in identity; do not add mutable properties.