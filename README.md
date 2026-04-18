# Salary Management Tool

Minimal end-to-end salary management software for an HR manager operating a 10,000-employee organization.

## Stack

- Backend: Ruby on Rails 7.1 API
- Database: SQLite
- Frontend: Next.js 14 App Router + Material UI
- Charts: Recharts
- Auth: JWT stored in a secure HTTP-only cookie by the Next.js layer
- Tests: RSpec + Vitest

## Features

- Role-based access for `admin`, `hr_manager`, `analyst`, and `viewer`
- Employee CRUD with soft delete and restore
- Salary insights by country:
  - minimum, maximum, average salary
  - median salary
  - total payroll
  - active employee count
  - headcount by status
  - average salary by job title
- Admin-only user management
- Deterministic seed script for 10,000 synthetic employees

## Local Run

```bash
docker compose up --build
```

Applications:

- Web: `http://localhost:3000`
- API: `http://localhost:3001`

Default demo password for seeded users:

```text
Password123!
```

Demo users:

- `admin@salary.local`
- `hr@salary.local`
- `analyst@salary.local`
- `viewer@salary.local`

## Database Setup

The API uses SQLite for local simplicity and deterministic evaluation. On first boot, Rails prepares the database automatically.

To reseed:

```bash
make seed
```

## Tests

Backend:

```bash
make api-test
```

Frontend:

```bash
make web-test
```

Verified during implementation:

- Rails specs passing on SQLite
- Vitest passing in Docker
- `next build` passing in Docker

## Project Layout

- `api/` Rails API, auth, RBAC, employees, insights, seeds, RSpec
- `web/` Next.js UI, secure session proxy routes, dashboard pages, Vitest
- `docs/` architecture notes, AI notes, and demo checklist

## Deployment Notes

The repo is Docker-ready. For an interview deployment, the simplest production path is:

1. deploy the Rails API container with a persisted disk for `db/production.sqlite3`
2. deploy the Next.js container with `INTERNAL_API_BASE_URL` and `NEXT_PUBLIC_API_BASE_URL`
3. set a strong `JWT_SECRET`

## Important Tradeoffs

- SQLite replaces Postgres in this implementation to reduce local setup friction and make evaluation faster in a single-workspace environment.
- Salary is stored in minor units (`annual_salary_cents`) to avoid floating-point errors.
- Insights are country-scoped to avoid mixing currencies.
