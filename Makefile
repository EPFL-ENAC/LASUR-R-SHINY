UID := $(shell id -u)
GID := $(shell id -g)

run:
	docker compose build --pull
	docker compose up -d --remove-orphans

generate-selfsigned-cert:
	cd cert && OWNER="${UID}.${GID}" docker compose up --remove-orphans
