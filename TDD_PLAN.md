# TDD Rewrite Plan

This branch (`tdd-rewrite`) reconstructs the salary management tool incrementally,
one Red → Green → (Refactor) cycle at a time. Each cycle produces between
one and three commits with a short, scoped message:

- `red(scope): <behaviour>` — adds **only** the new failing test
- `green(scope): <minimum impl>` — the smallest production change that turns the test green
- `refactor(scope): <change>` — non-behavioural cleanup, all tests still green

The end state is functionally identical to the original `main` branch; the
goal is to make the *thinking* visible in the history.

## Style notes

- Outside-in (London School): start with request/component specs, drive units inward
- Production code never appears before the test that demanded it
- Refactor commits exist only when warranted
- One behaviour per cycle — small, reviewable diffs

## Backend cycle list

### Setup
- S1. Install RSpec + factory_bot scaffolding (`api/.rspec`, `spec/spec_helper.rb`, `spec/rails_helper.rb`)
- S2. Switch ActiveRecord adapter to SQLite for the demo

### User model
- B1. `red`: User without email is invalid → `green`: add `email` + presence
- B2. `red`: duplicate email is invalid → `green`: uniqueness validation + DB index
- B3. `red`: invalid email format is rejected → `green`: format validator
- B4. `red`: email is normalised to lowercase → `green`: `normalizes` callback
- B5. `red`: full_name is required → `green`: presence validator
- B6. `red`: password is securely hashed and `authenticate` works → `green`: `has_secure_password` + bcrypt + migration column
- B7. `red`: password must be ≥ 10 chars → `green`: length validator
- B8. `red`: role enum + default → `green`: enum + ROLES constant
- B9. `red`: role permission predicates (`can_view_employees?` etc) → `green`: predicates + `role_in?`
- B10. `red`: `User.active` scope → `green`: `active` boolean column + scope

### JWT service
- B11. `red`: encode/decode round-trip → `green`: `JsonWebToken.encode/decode`
- B12. `red`: expired token raises `DecodeError` → `green`: expiry handling
- B13. `red`: tampered token raises `DecodeError` → `green`: signature verification
- `refactor`: extract `secret_key` to ENV/secret_key_base

### Auth controller
- B14. `red`: `POST /api/v1/auth/login` returns 200 + token + user payload (happy path) → `green`: minimal controller
- B15. `red`: invalid email returns 401 → `green`: rescue path
- B16. `red`: invalid password returns 401 → `green`: branch
- B17. `red`: missing params returns 422 → `green`: rescue ParameterMissing
- B18. `red`: `last_login_at` is updated on successful login → `green`: update + migration
- B19. `red`: `GET /api/v1/auth/me` returns current user → `green`: `show` action + `authenticate_user!`
- B20. `red`: `DELETE /api/v1/auth/logout` returns 204 → `green`: `destroy` action
- `refactor`: extract `UserSerializer`

### Application controller / RBAC plumbing
- B21. `red`: protected endpoint without token returns 401 → `green`: `authenticate_user!` before_action
- B22. `red`: protected endpoint with bad token returns 401 → `green`: rescue `JsonWebToken::DecodeError`
- B23. `red`: `authorize_roles!` blocks unauthorized roles with 403 → `green`: `authorize_roles!` helper
- B24. `red`: `RecordNotFound` renders 404 → `green`: `rescue_from` handler

### Employee model
- B25. `red`: required attributes (`employee_code`, `full_name`, `work_email`, `job_title`, `department`, `country_code`, `currency_code`, `hired_on`) → `green`: presence validators + migration
- B26. `red`: `annual_salary_cents` is positive integer → `green`: numericality validator
- B27. `red`: `employee_code` and `work_email` are unique → `green`: uniqueness + DB indexes
- B28. `red`: country_code is 2 chars, currency_code is 3 → `green`: length validators
- B29. `red`: country_code/currency_code/work_email normalised → `green`: `normalizes` callbacks
- B30. `red`: `employment_status` enum → `green`: enum + EMPLOYMENT_STATUSES constant
- B31. `red`: `kept` and `archived` scopes → `green`: scopes + `deleted_at` column
- B32. `red`: `soft_delete!` and `restore!` → `green`: instance methods

### Employee endpoints (request specs drive controller)
- B33. `red`: `GET /employees` requires auth → `green`: before_action
- B34. `red`: `GET /employees` returns kept employees, paginated → `green`: index action + pagination_params helper
- B35. `red`: `GET /employees/:id` returns one → `green`: show action + set_employee
- B36. `red`: `POST /employees` creates with valid payload (admin/hr) → `green`: create action + employee_params + serializer
- B37. `red`: `POST /employees` rejects unauthorised roles with 403 → `green`: authorize_manage_access!
- B38. `red`: `POST /employees` returns 422 on invalid payload → `green`: error branch
- B39. `red`: `PATCH /employees/:id` updates → `green`: update action
- B40. `red`: `DELETE /employees/:id` soft-deletes → `green`: destroy action
- B41. `red`: `POST /employees/:id/restore` restores → `green`: restore action + archived scope lookup
- B42. `red`: `GET /employees?include_archived=true` returns archived too → `green`: scope branch
- B43. `red`: viewer role cannot manage but can read → `green`: authorize_read_access!
- `refactor`: extract `EmployeeSerializer`

### EmployeeSearch service
- B44. `red`: returns scope unchanged when no params → `green`: minimal `call`
- B45. `red`: filters by `query` term across name/email/title/dept → `green`: by_search
- B46. `red`: filters by country/job_title/department/status → `green`: respective filters
- B47. `red`: sorts by allowed field + direction, falls back when invalid → `green`: sort_field/sort_direction
- B48. `red`: `include_archived=true` returns archived rows → `green`: by_archived
- `refactor`: extract `truthy?` helper

### SalaryInsights service
- B49. `red`: scoped to country only, kept employees only → `green`: constructor
- B50. `red`: minimum/maximum/total → `green`: aggregate methods
- B51. `red`: average rounded → `green`: average_salary_cents
- B52. `red`: median for odd count → `green`: median_salary_cents
- B53. `red`: median for even count averages middle two → `green`: even branch
- B54. `red`: employee_count_by_status grouped → `green`: group(:employment_status).count
- B55. `red`: top job titles ordered by count desc, then alpha → `green`: job_title_breakdown

### Insights endpoints
- B56. `red`: `GET /insights/overview` requires `country` → `green`: require_country!
- B57. `red`: `GET /insights/overview` returns SalaryInsights#overview → `green`: action wires service
- B58. `red`: viewer role is denied (only analyst/hr/admin allowed) → `green`: authorize_read_access!
- B59. `red`: `GET /insights/job_titles` returns SalaryInsights#job_titles → `green`: action

### Users endpoints (admin only)
- B60. `red`: non-admin returns 403 on every users action → `green`: before_action authorize_roles!(:admin)
- B61. `red`: `GET /users` lists users → `green`: index
- B62. `red`: `POST /users` creates user → `green`: create + user_params
- B63. `red`: `PATCH /users/:id` updates user → `green`: update
- B64. `red`: blank password is dropped from params → `green`: user_params filter
- B65. `red`: `DELETE /users/:id` deactivates → `green`: destroy + active=false
- B66. `red`: cannot deactivate self → `green`: self-check branch

### Audit logging
- B67. `red`: AuditLog has actor, action, subject, changeset → `green`: model + migration
- B68. `red`: `AuditLogger.log!` records on employee_created/updated/archived/restored → `green`: service + controller wiring

### Seed
- B69. `red`: seed produces N deterministic employees with valid data → `green`: db/seeds.rb + name files

## Frontend cycle list

### Setup
- W1. Install Vitest + RTL config (`vitest.config.ts`, `src/test/setup.ts`)
- W2. Add MUI/Emotion provider scaffolding

### LoginForm
- W3. `red`: renders email + password fields → `green`: form skeleton
- W4. `red`: submit calls `/api/auth/login` with credentials → `green`: onSubmit handler
- W5. `red`: shows error message on failure → `green`: error state

### AuthContext / session
- W6. `red`: provides current user from `/api/auth/me` → `green`: provider + fetch
- W7. `red`: logout hits `/api/auth/logout` and clears state → `green`: logout()

### Next API session proxy
- W8. `red`: `POST /api/auth/login` sets HTTP-only cookie on success → `green`: route handler
- W9. `red`: `GET /api/auth/me` proxies bearer token → `green`: route handler
- W10. `red`: `POST /api/auth/logout` clears cookie → `green`: route handler
- W11. `red`: `[...path]` proxy injects bearer token to api → `green`: catch-all route

### Middleware
- W12. `red`: unauthenticated visitor redirected to /login → `green`: middleware

### DashboardShell
- W13. `red`: shows nav items by role → `green`: conditional render
- W14. `red`: shows user identity & logout → `green`: header

### Employees page
- W15. `red`: lists employees from API → `green`: data fetch + table
- W16. `red`: search input updates query → `green`: controlled input + debounce
- W17. `red`: filter selects update query → `green`: filter handlers
- W18. `red`: pagination controls work → `green`: page state
- W19. `red`: create dialog submits valid payload → `green`: dialog + form
- W20. `red`: edit dialog updates row → `green`: edit form
- W21. `red`: delete archives the row → `green`: delete handler
- W22. `red`: restore brings back archived → `green`: restore handler
- W23. `red`: viewer role cannot see action buttons → `green`: role gating

### Insights page
- W24. `red`: country selector loads insights on change → `green`: fetch
- W25. `red`: KPI cards render correct values → `green`: stat cards
- W26. `red`: chart renders job title breakdown → `green`: recharts wiring

### Users page (admin only)
- W27. `red`: lists users for admin → `green`: data fetch + table
- W28. `red`: create user form → `green`: form
- W29. `red`: deactivate disables row → `green`: handler

### Empty states / formatting
- W30. `red`: EmptyState renders headline + body → `green`: component
- W31. `red`: SectionHeader renders title and actions → `green`: component
- W32. `red`: format.ts formats currency in minor units → `green`: helpers

## Conventions

- Commit prefix is one of `setup`, `red`, `green`, `refactor`, `chore`, `docs`
- Each `red` commit MUST include a failing spec (and nothing else)
- Each `green` commit MUST keep the diff to the smallest production change that satisfies the new test
- Each `refactor` commit MUST keep the entire suite green and change behaviour-equivalent code only
