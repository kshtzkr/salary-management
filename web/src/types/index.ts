export type Role = "admin" | "hr_manager" | "analyst" | "viewer";

export interface CurrentUser {
  id: number;
  full_name: string;
  email: string;
  role: Role;
  active: boolean;
  last_login_at: string | null;
}

export interface Employee {
  id: number;
  employee_code: string;
  full_name: string;
  work_email: string;
  job_title: string;
  department: string;
  country_code: string;
  currency_code: string;
  annual_salary_cents: number;
  employment_status: string;
  hired_on: string;
  archived: boolean;
}

export interface UserRecord extends CurrentUser {
  created_at: string;
  updated_at: string;
}
