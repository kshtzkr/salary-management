class UserSerializer
  def initialize(user)
    @user = user
  end

  def as_json(*)
    {
      id: user.id,
      email: user.email,
      full_name: user.full_name,
      role: user.role,
      active: user.active,
      last_login_at: user.last_login_at
    }
  end

  private

  attr_reader :user
end
