_This project has been created as part of the 42 curriculum by lcosson._

# Developer Documentation - Inception

This document describes the technical architecture and setup for developers.

## Environment Setup
* **Host OS**: The project must run on a Virtual Machine.
* **Prerequisites**: Docker, Docker Compose, and GNU Make installed.
* **Configuration**: All source files are located in the `srcs/` folder.

## Project Structure
The project follows a modular "one service per container" rule:
* **srcs/requirements/nginx**: Dockerfile and TLS configuration.
* **srcs/requirements/wordpress**: Dockerfile and PHP-FPM setup.
* **srcs/requirements/mariadb**: Dockerfile and database initialization.

## Building and Launching
The `Makefile` automates the `docker-compose` commands:
* `docker-compose.yml` orchestrates the build of custom images (pulling ready-made images is forbidden, except for base Alpine/Debian).

## Data Persistence and Storage
* Two **named volumes** are used for persistence.
* Data is stored on the host at: `/home/<login>/data/`.
* WordPress files: `wordpress_vol` -> `/var/www/html`.
* Database files: `mariadb_vol` -> `/var/lib/mysql`.

## Network Architecture
* A dedicated **docker-network** allows communication between containers.
* NGINX is the only service exposing a port (443) to the host.
* PHP-FPM (9000) and MariaDB (3306) are only accessible within the internal network.

## Management Commands
* **Shell access**: `docker exec -it <container_name> sh` to inspect the internal state.
* **Database access**: `docker exec -it mariadb mariadb -u root -p` to inspect the database.