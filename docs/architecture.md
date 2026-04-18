# Architecture and Tradeoffs

## Shape

- `web` owns the user session cookie and proxies authenticated requests to `api`
- `api` owns domain logic, persistence, authorization, seeding, and insight calculations
- employee insights are read-only aggregates computed from active, non-archived employees

## Auth

- Rails returns a JWT on login
- Next route handlers store that JWT in a secure HTTP-only cookie
- all UI data calls go through `/api/backend/[...path]`, which injects the bearer token server-side

This keeps the browser free of raw JWT handling while avoiding a heavier full-session store.

## RBAC

- `admin`: full app access including user management
- `hr_manager`: employee CRUD + insights
- `analyst`: insights only
- `viewer`: employee directory read-only

Permissions are encoded in the Rails `User` model and enforced in controllers.

## Employee Data Model

Stored fields:

- employee code
- full name
- work email
- job title
- department
- country code
- currency code
- annual salary in minor units
- employment status
- hired date
- soft-delete timestamp

This is the smallest set that still supports realistic HR workflows and useful salary analysis.

## SQLite Choice

The original plan targeted Postgres. The implementation was switched to SQLite after discussion to simplify local execution and verification in this environment.

Changes required for that shift:

- `pg` -> `sqlite3`
- Postgres-only query fragments replaced with portable SQL/Ruby logic
- `jsonb` audit metadata replaced with `json`
- Docker Compose no longer needs a separate database service

For an interview submission, SQLite keeps the software relational and fully functional while cutting setup complexity.

## Seed Performance

- loads first and last name files once
- uses deterministic `Random.new`
- bulk inserts in batches of 1,000
- replaces only synthetic employee rows on rerun

That makes repeated seeding fast, deterministic, and idempotent enough for regular engineering use.
