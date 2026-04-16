up:
	docker compose up --build

down:
	docker compose down

api-test:
	docker compose run --rm api bash -lc "bundle install && RAILS_ENV=test bundle exec rails db:prepare && bundle exec rspec"

web-test:
	docker compose run --rm web bash -lc "npm install && npm run test"

seed:
	docker compose run --rm api bash -lc "bundle install && bundle exec rails db:seed"
