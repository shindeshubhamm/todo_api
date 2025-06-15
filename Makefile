.PHONY: setup db db-migrate dev redis lint test

setup:
	./bin/bundle install

db:
	docker run -it --rm -d \
		--name postgres \
		-e POSTGRES_DB=todo_api_development \
		-e POSTGRES_USER=postgres \
		-e POSTGRES_PASSWORD=postgres \
		-p 5432:5432 \
		-v ./storage/db:/var/lib/postgresql/data \
		postgres:16-alpine

db-migrate:
	./bin/rails db:migrate

redis:
	mkdir -p ./storage/redis
	docker run -it --rm -d \
		--name redis \
		-p 6379:6379 \
		-v ./storage/redis:/data \
		redis:7-alpine redis-server --appendonly yes

dev:
	./bin/rails server

lint:
	./bin/bundle exec rubocop -A

test:
	./bin/bundle exec rspec