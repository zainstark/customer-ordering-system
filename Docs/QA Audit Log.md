
# QA Audit Log — Customer Ordering System

## Purpose

This document records QA-driven refinements applied to system requirements and use cases.

The purpose of the audit log is to:
- eliminate vague or non-testable requirements
- replace subjective wording with measurable metrics
- improve verification and validation quality
- strengthen reliability, security, and edge-case handling

---

# QA Refinement Audit Table

| Audit ID | Original Requirement | QA Issue Identified | Refinement Applied | Final Requirement | Related UC / FR | QA Rationale |
|---|---|---|---|---|---|---|
| QA-001 | "System should respond quickly" | "Quickly" is subjective and untestable | Added measurable SLA | System responds within ≤ 2 seconds | NFR1, UC1–UC7 | Enables performance testing |
| QA-002 | "Secure login" | "Secure" is vague | HTTPS enforced + session rules | All authentication requests must use HTTPS | NFR3, UC1 | Makes security verifiable |
| QA-003 | "Prevent brute force attacks" | No threshold defined | Added lockout threshold | Lock account after 5 failed attempts within 10 minutes | EC-UC1-01 | Allows deterministic security testing |
| QA-004 | "Retry payment failures" | Retry behavior undefined | Defined retry limit | Retry payment requests up to 3 times before failure | UC5, EC-UC5-01 | Prevents infinite retry loops |
| QA-005 | "Handle slow menu loading" | No timeout behavior defined | Added loading + timeout thresholds | Show loading indicator within 500ms and timeout message after 2s | EC-UC2-02 | Improves UX consistency |
| QA-006 | "Prevent duplicate orders" | Duplicate behavior unspecified | Added idempotency requirement | Multiple identical requests return same order ID | EC-UC4-02 | Prevents duplicate order creation |
| QA-007 | "Protect payment data" | No transport requirements defined | Enforced HTTPS-only payments | Reject payment requests sent over HTTP | EC-UC5-04 | Prevents insecure payment transmission |
| QA-008 | "Limit excessive tracking requests" | No rate limit defined | Added measurable threshold | Limit tracking endpoint to 30 requests/minute | EC-UC7-05 | Protects server performance |
| QA-009 | "Session timeout" | Timeout duration unspecified | Added timeout duration | Session expires after 30 minutes inactivity | EC-UC1-03 | Allows reproducible session testing |
| QA-010 | "Ensure payment reliability" | Reliability not measurable | Added success metric | Payment success rate must be ≥ 99.5% | NFR2 | Enables operational monitoring |

---

# QA Design Principles Applied

The refinements in this audit log follow these QA principles:

- Measurable metrics over subjective wording
- Explicit retry boundaries
- Deterministic edge-case handling
- Security hardening through enforceable constraints
- Observable failure behavior
- Testable system boundaries

---

# Relationship to Validation

This audit log supports:
- Gherkin scenario creation
- automated testing
- Playwright test generation
- measurable verification criteria
- edge-case validation

The refined requirements are directly traceable to:
- Use Cases
- SSDs
- Activity Diagrams
- Edge Case Analysis