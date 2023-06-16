UID := $(shell id -u)
GID := $(shell id -g)

generate-selfsigned-cert:
	cd cert && OWNER="${UID}.${GID}" docker compose up --remove-orphans

run:
	docker compose build --pull
	docker compose up -d --remove-orphans
