MAKEFILE="${1:-Makefile}"

cat << 'EOF' >> $MAKEFILE

.PHONY: db db_start db_stop test

# Environment variable can be set using -e VARIABLE_NAME=VALUE

CONTAINER ?= shell_test
DB_VERSION ?= postgres
DB_USER ?= test
DB_PASS ?= test
DB_NAME ?= test
NEW_DB_SQL ?= $(shell cat new_db.sql)
RUN_SQL ?= $(shell cat run.sql)
LSB_RELEASE ?= $(shell lsb_release -cs)

db:
# Add docker repository
	apt-get install apt-transport-https ca-certificates curl software-properties-common
	curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
	add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(LSB_RELEASE) stable"
# Install docker
	apt-get install docker-ce
# Download container
	docker pull $(DB_VERSION)
# Run container
	docker run -d --name=$(CONTAINER) -e POSTGRES_USER=$(DB_USER) -e POSTGRES_PASSWORD=$(DB_PASS) -e POSTGRES_DB=$(DB_NAME) -e PGDATA=/var/db -v /var/db:/var/db library/postgres
# Wait for container starts
	sleep 1
# Crete new DB from config file
	docker exec -it $(CONTAINER)  psql -U docker -c "$(NEW_DB_SQL)"
# Run custom SQL
	docker exec -it $(CONTAINER)  psql -U docker -c "$(RUN_SQL)"

start:
# Start container
	docker start $(CONTAINER)

stop:
# Start container
	docker stop $(CONTAINER)

rm:
# Remove container
	docker stop $(CONTAINER)
	docker rm $(CONTAINER)
EOF
