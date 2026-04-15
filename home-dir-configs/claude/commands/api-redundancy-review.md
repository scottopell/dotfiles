---
description: Review PR diff for redundant/duplicate API patterns
---
## Purpose
Analyze a GitHub PR diff for API redundancy code smells—places where multiple ways exist to accomplish the same thing, violating the principle of having one clear path.

## Setup
Capture the full PR diff (terminal output truncates). Write to a temp file, then read it:
```bash
gh pr diff > <tempfile>
```

## Code Smells to Detect

### 1. Wrapper Methods (High Priority)
Methods that exist only to call another method with identical or near-identical signature:
```rust
// SMELL: with_concurrency_limit just calls with_fetcher_and_concurrency
pub fn with_concurrency_limit(fetcher, max) -> Result<Self> {
    Self::with_fetcher_and_concurrency(fetcher, max)
}
```

### 2. Duplicate Getters
Multiple methods returning the same underlying data:
```rust
// SMELL: Two ways to get the same field
pub fn get_config(&self) -> &Config { &self.config }
pub fn config(&self) -> &Config { &self.config }
```

### 3. Redundant Construction Paths
Constructor that accepts params also settable via builder methods:
```rust
// SMELL: new() takes args that with_*() methods also set
pub fn new(url: &str, timeout: Duration) -> Self { ... }
pub fn with_url(mut self, url: &str) -> Self { ... }
pub fn with_timeout(mut self, t: Duration) -> Self { ... }
```

### 4. Overlapping Error Variants
Error enum variants that represent the same failure case:
```rust
// SMELL: NetworkError and ConnectionFailed are the same thing
pub enum Error {
    ConnectionFailed(String),
    NetworkError(String),
}
```

### 5. Trait + Inherent Method Duplication (Context-Dependent)
Inherent method duplicating a trait method. **Only flag if trait is internal** (external traits may require this):
```rust
// SMELL only if Processor is defined in this crate
impl MyService {
    pub fn process(&self, data: &[u8]) -> Result<()> { ... }
}
impl Processor for MyService {
    fn process(&self, data: &[u8]) -> Result<()> { self.process(data) }
}
```

## Review Process
1. Get the full diff (use temp file to avoid truncation)
2. Focus on library/service layer code (src/), not tests or binaries
3. For each smell found, provide:
   - File and line reference
   - Which pattern it matches
   - Suggested fix (usually: remove one, keep the more general one)
4. Ignore: test helpers, backwards-compat shims with deprecation notices, trait impls for external traits

## Output Format
For each finding:
```
**[Pattern Name]** `file.rs:123`
<brief description of the redundancy>
Suggestion: <one-line fix>
```

If no issues found, state: "No API redundancy issues detected in this diff."
