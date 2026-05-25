# User Documentation - Inception

This document explains how to interact with and manage the Inception services.

## Services Provided
The infrastructure provides a fully functional WordPress website served securely:
* **NGINX**: The secure entry point (HTTPS).
* **WordPress**: The content management system.
* **MariaDB**: The database storing all site content.

## How to Start and Stop the Project
All management is done via the `Makefile` at the root of the project:
* **Start**: Run `make` to build and launch all services in the background.
* **Stop**: Run `make clean` to stop and remove the containers.
* **Hard Reset**: Run `make fclean` to remove everything, including volumes and images.

## Accessing the Website
1. Ensure your `/etc/hosts` file contains: `127.0.0.1 <your_login>.42.fr`.
2. Open your browser and go to: `https://<your_login>.42.fr`.
3. To access the admin panel, go to: `https://<your_login>.42.fr/wp-admin` and login with the correct user.

## Credentials and Security
* All sensitive data (passwords, usernames) are stored in the `srcs/.env` file or within the `secrets/` directory.
* **Note**: Never share these files or push them to a public repository.

## Checking Service Status
To verify that all services are running correctly:
* Run `docker ps` to see the status of each container.
* All containers should have a status of "Up".