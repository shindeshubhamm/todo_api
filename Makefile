.PHONY: setup db db-migrate dev

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

dev:
	./bin/rails server