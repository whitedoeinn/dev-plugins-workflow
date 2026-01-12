# Database Feature

**Status:** Planning
**Created:** 2026-01-12

## Overview

A test feature focused on database tasks to verify data-integrity-guardian invocation.

## Done When

- [ ] Create users table schema (test: table exists with correct columns)
- [ ] Add index on email column (test: index improves query performance)
- [ ] Create migration for status column (test: migration is reversible)
- [ ] Add foreign key constraint to orders (test: constraint enforced)

## Dependencies

**Blocked by:**
(none)

**Blocks:**
(none)

## Notes

This is a test fixture to verify database task detection.
All tasks should trigger: data-integrity-guardian review.
