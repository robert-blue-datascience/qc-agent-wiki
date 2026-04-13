---
title: Guardrails
layout: default
nav_order: 9
---

# Guardrails

The QC Automation Agent includes a set of built-in safety controls called guardrails. These controls protect the cloud platform from excessive load, enforce strict boundaries around operator data, ensure credentials never appear in log files, and prevent the agent from starting in an unsafe or misconfigured state. They run automatically on every execution and cannot be bypassed.

This page explains what each guardrail does, why it exists, and what happens when it activates. For the technical implementation, see the [Guardrails Technical Reference](technical/guardrails).

---

## Why These Controls Exist

The agent runs against a shared production platform. It processes data for multiple operators in sequence, makes requests at scale, and writes persistent output to local disk. Without safety controls, several serious problems could occur:

- A single misconfigured environment variable could silently route run data to a third-party monitoring service, violating the data handling contract
- An overly aggressive request schedule could degrade the platform for every other user sharing it
- A credential value could inadvertently appear in a log file shared for debugging
- Data from one operator could intermingle with data from another in a report or log

The guardrails are designed to make these failures impossible, not merely unlikely. Where a passive warning could be dismissed under time pressure, the guardrails block execution entirely.

---

## The Five Guardrails

### 1. Pre-Run Security Check

Before the agent touches any data or makes any network call, it runs a sequence of startup checks. These verify that the environment is in a safe, known-good state. If any check fails, the agent stops immediately and reports every failed check. There are no partial runs and no override options.

**What is checked:**

**Credentials are present.** The agent requires valid access credentials to retrieve well data and to publish scores. If any required credential is missing or empty, the run cannot proceed.

**Telemetry services are inactive.** Several monitoring and crash-reporting tools automatically send application behavior data to third-party cloud services when their environment variables are set. The agent checks for all known telemetry variables and stops if any are active. The list of blocked services includes crash reporters, performance monitors, and API key trackers.

**Framework tracing is off.** The underlying orchestration framework includes a built-in integration that, when enabled, streams run data to an external cloud service. This is disabled by default but can be re-enabled with a single environment variable. The agent verifies this switch is off before every run.

**Credential files are protected.** The agent's credentials are stored in a local file that must never be committed to version control. The startup check verifies both that the file exists on disk and that the version control system is configured to exclude it from tracking.

When multiple checks fail, all failures are reported at once rather than stopping at the first one. A misconfigured environment reveals every problem in a single output, so the full picture is available without multiple fix-and-retry cycles.

### 2. Rate Limiting

Every request the agent sends to an external service passes through a rate limiter before it is sent. The limiter enforces two constraints simultaneously:

- **Minimum spacing:** A set amount of time must pass between consecutive requests to the same service. This prevents bursts of back-to-back requests that could overwhelm a shared system.
- **Per-minute ceiling:** No more than a set number of requests can be sent within any 60-second rolling window.

Both constraints are evaluated before every request. If either requires a wait, the agent pauses and logs the delay before proceeding. No request is ever skipped or dropped -- it is always sent, just after the appropriate wait.

The rate limits have enforced minimums. If a configuration file specifies values that are too aggressive, the limiter automatically raises them to the safe floor and logs a warning when it does so. No configuration error can disable this behavior or push the limits below their floor.

The platform data API and the score publishing board each have separate request budgets. Activity against one does not consume the other's budget. There is also a fixed cooldown pause between processing consecutive operator groups, allowing platform load to settle before the next batch begins.

### 3. Audit Trail

Every action the agent takes during a run is written to a structured log file in real time. The log covers the full lifecycle:

- The security check result at startup
- Which wells were queued and in what order
- Every data request sent and when
- What each of the 29 checks returned for each well
- Every score calculated
- Every value published to the QC tracking board
- Any unexpected conditions, errors, retries, or waits

Log entries are written to disk as they occur. The agent does not accumulate events in memory and flush them at the end of a run. If the agent is interrupted mid-run, the log reflects everything up to that point.

Early events -- including the startup security check result -- are held in a temporary memory buffer while the run's output folder is being prepared. The moment the folder is established, the buffer is written to the log file in order. No early events are lost.

Log files are stored on the local machine only and are never transmitted anywhere. Each operator processed in a run gets its own log file. Log files from different operators are always written separately and never combined.

### 4. Credential Protection

The audit log is useful for debugging and review, but it must never contain sensitive values. A scrubbing layer intercepts every log entry before it is written to disk. If any entry contains a known credential value -- a login password, an API token, or an authentication token issued during the run -- that value is replaced with the placeholder `[REDACTED]` before the entry is saved.

This is a defense-in-depth measure. Credentials are not expected to appear in log entries, and the code is written to prevent this. But the situations most likely to produce unexpected log content -- authentication failures, unexpected API responses, network errors -- are exactly the hardest paths to test exhaustively. The scrubber acts as a last-resort safety net at the write boundary.

Authentication tokens obtained during the run are registered with the scrubber the moment they are issued. They are covered even though they were not known at startup.

If the scrubber itself encounters an unexpected error, it logs a warning and writes the original entry unchanged rather than silently dropping it. Preserving the log record takes priority over guaranteed redaction in this fallback, though this path has not been triggered in practice.

### 5. Code Scanning

The previous four guardrails protect the running system. The fifth protects the code before it runs.

A static scanner examines the entire source code before any change can be committed. It checks for patterns that would violate the security policy:

- String literals that resemble real credentials (long alphanumeric sequences, known API key formats, embedded bearer tokens)
- Import statements for monitoring, analytics, telemetry, or tracing libraries
- Network connections to services outside the three approved external endpoints
- Hardcoded absolute file paths that would embed the local machine's directory structure in the source
- Example configuration files containing real credential values instead of safe placeholders

The scanner runs across Python source files, configuration files, and repository metadata. It must pass with zero violations before a commit can proceed.

This check catches policy violations at development time, before any misconfigured code can reach a running system. The runtime guardrails provide independent protection against the same classes of risk, so neither layer depends solely on the other.

---

## What Happens When a Guardrail Activates

| Guardrail | What triggers it | What happens |
|---|---|---|
| Pre-run security check | Missing credential, active telemetry variable, framework tracing enabled, unprotected credential file | Agent exits before starting. All failed checks reported in a single message. |
| Rate limiter | Request arriving before minimum interval, or per-minute bucket full | Request waits until the constraint clears. Wait duration and context logged. Run continues. |
| Audit trail | Always active | All events recorded automatically. No action required. |
| Credential protection | Credential value found in a log entry | Value replaced with `[REDACTED]` before writing. Warning logged if scrubber encounters an error. Entry still written. |
| Code scanner | Security pattern found in a source file | Commit blocked. File path, line number, and violation description printed. |

---

## The Safety Contract

The five guardrails together enforce these commitments on every run:

**Read-only access.** The agent never submits, saves, modifies, or deletes anything on the data platform. All requests retrieve data; none write it back.

**Three approved connections.** The agent communicates with exactly three external services during a run. No other outbound connections are made or permitted.

**No third-party data routing.** No telemetry, error reports, performance metrics, or usage data are sent to any external monitoring or analytics service. All output stays on the local machine.

**Operator isolation.** Each operator's data is kept strictly separate throughout the run. Log files, run reports, and published scores are scoped to a single operator at a time. Cross-operator data mixing is structurally prevented.

**No credential exposure.** No password, API token, or authentication token appears in any log file, run report, or output artifact.

See [How It Works](how-it-works) for the full run sequence these guardrails protect, or the [Guardrails Technical Reference](technical/guardrails) for implementation details.
