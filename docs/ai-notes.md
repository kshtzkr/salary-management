# AI Usage Notes

AI was used as an implementation accelerator, not as an authority.

## What it helped with

- drafting the initial architecture plan
- scaffolding Rails and Next.js app structures
- outlining RBAC, employee CRUD, and insights flows
- generating repetitive but reviewable code structure for controllers, services, route handlers, and tests
- surfacing verification gaps quickly during iteration

## What was still validated manually

- database portability after switching from Postgres to SQLite
- JWT behavior under Ruby 3 keyword argument rules
- Rails spec failures and frontend test/build failures
- final route shape, permission boundaries, and seed behavior

## Notable corrections during implementation

- switched local persistence from Postgres to SQLite
- removed Postgres-specific SQL and schema details
- fixed JWT helper signature for Ruby 3 keyword semantics
- fixed frontend test environment issues caused by JSX handling in Vitest
- widened employee draft typing so edit mode matches production data
