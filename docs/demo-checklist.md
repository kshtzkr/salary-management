# Demo Checklist

## Suggested Demo Flow

1. Open `/login`
2. Sign in as `admin@salary.local`
3. Show the employee directory:
   - search
   - country and department filters
   - employee detail dialog
4. Add a new employee
5. Edit that employee
6. Archive and restore an employee
7. Open the insights page:
   - switch countries
   - review min, avg, median, max, payroll
   - show the job-title salary chart
8. Open user management:
   - create a new viewer account
   - deactivate a non-admin user
9. Sign out
10. Sign in as `analyst@salary.local` and show that only insights are available
11. Sign in as `viewer@salary.local` and show that only employee directory access is available

## Optional Terminal Verification

- `make api-test`
- `make web-test`
- `docker run --rm -v /Users/thrillophilia/interview/test_interview:/workspace -w /workspace/web node:20 bash -lc 'npm run build'`
