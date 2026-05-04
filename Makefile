# Variable to store the docker-compose command with the specific path to the YML file
# Using 'docker compose' (V2) instead of the older 'docker-compose'
DOCKER_COMPOSE := docker compose -f srcs/docker-compose.yml

# -----------------
# CORE COMMANDS
# -----------------

# Default target: executes the 'up' rule
all: up

# 'up' rule: prepares the environment and launches the containers
up:
	# Create physical host directories for persistent data volumes
	# $(USER) ensures the paths are correct regardless of the current 42 session
	@echo "Checking and creating volume directories in /home/$(USER)/data/..."
	@mkdir -p /home/$(USER)/data/mariadb
	@mkdir -p /home/$(USER)/data/wordpress
	
	# Build images if they don't exist and start containers in detached mode (-d)
	# --build ensures images are updated if Dockerfiles or configs changed
	$(DOCKER_COMPOSE) up -d --build

# 'down' rule: stops and removes containers and networks
# Note: This keeps the volumes (data) intact for persistence
down:
	$(DOCKER_COMPOSE) down

stop:
	$(DOCKER_COMPOSE) stop

start:
	$(DOCKER_COMPOSE) start

fclean:
	@echo "Stopping containers and removing images/volumes..."
	$(DOCKER_COMPOSE) down --rmi all -v
	@echo "Removing physical data..."
	sudo rm -rf /home/$(USER)/data/mariadb/*
	sudo rm -rf /home/$(USER)/data/wordpress/*
	@# Cleanup dangling images to save space
	@if [ -n "$$(docker images -f "dangling=true" -q)" ]; then \
		docker rmi $$(docker images -f "dangling=true" -q); \
	fi

# 're' rule: full restart cycle without deleting permanent data
re: down up

.PHONY: all up down fclean re start stop