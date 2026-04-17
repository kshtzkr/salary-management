class JsonWebToken
  class DecodeError < StandardError; end

  ALGORITHM = "HS256"

  def self.encode(payload = nil, exp: 24.hours.from_now, **extra)
    attributes = payload.to_h.merge(extra)
    JWT.encode(attributes.merge(exp: exp.to_i), secret_key, ALGORITHM)
  end

  def self.decode(token)
    raise DecodeError, "Missing token" if token.blank?

    JWT.decode(token, secret_key, true, algorithm: ALGORITHM).first
  rescue JWT::DecodeError, JWT::ExpiredSignature => error
    raise DecodeError, error.message
  end

  def self.secret_key
    Rails.application.secret_key_base
  end
end
