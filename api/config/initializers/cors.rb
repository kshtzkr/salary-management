Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch("FRONTEND_ORIGIN", "http://localhost:3000")

    resource "*",
      headers: :any,
      expose: %w[Authorization],
      methods: %i[get post patch put delete options head],
      credentials: true
  end
end
