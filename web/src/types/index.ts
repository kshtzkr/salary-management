export type Role = "admin" | "hr_manager" | "analyst" | "viewer";

export interface CurrentUser {
  id: number;
  full_name: string;
  email: string;
  role: Role;
  active: boolean;
  last_login_at: string | null;
}
