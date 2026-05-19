_This project has been created as part of the 42 curriculum by lcosson._

# 🐳 Inception - Infrastructure Web System Administration

## 📝 Project Overview
This project consists of setting up a complete infrastructure of tiered services using **Docker Compose**. The entire infrastructure runs on **Debian/Alpine** and follows strict security constraints, specifically the exclusive use of **TLS v1.2/v1.3** protocols.

---

## 🏗️ Service Architecture
The infrastructure is divided into three main services isolated within a private network:

| Service | Base Image | Role | Internal Port |
| :--- | :--- | :--- | :--- |
| **NGINX** | Alpine/Debian | Reverse Proxy & SSL Termination | 443 |
| **WordPress** | PHP-FPM | Website Engine | 9000 |
| **MariaDB** | Alpine/Debian | SQL Database | 3306 |

---

## 🛡️ Security & Networking
* **Network Isolation**: All containers are linked to an internal network named `inception_network`.
* **Restricted Access**: No services are exposed to the host machine except for NGINX on port **443**.
* **Encryption**: External communication is only possible via HTTPS. Port 80 is closed and   unreachable.
* **No Background Processes**: No service runs in the background using `tail -f` or `&`, complying with project rules.
* **Secrets Management**: No sensitive data (passwords, logins) is hardcoded in Dockerfiles. Everything is managed via a `.env` file or in secrets folder with `docker secrets`.

---

## 💾 Data Persistence
To ensure that data is not lost during a reboot or a `make down`, two Docker volumes are used and mounted on the host at `/home/${USER}/data/`:
1. **MariaDB Volume**: Stores SQL databases (`/var/lib/mysql`).
2. **WordPress Volume**: Stores website source files and uploaded media (`/var/www/html`).

---

## 🚀 2. Configuration
Before launching the project, you must:
1. Ensure the data directories exist on your host machine (replace `login` with your 42 login):
   ```bash
   mkdir -p /home/login/data/mariadb
   mkdir -p /home/login/data/wordpress
2. Create a .env file at the root of the srcs folder with your environment variables (e.g.,     DOMAIN_NAME, SQL_USER, SQL_PASSWORD, MYSQL_ROOT_PASSWORD).

## 🛠️ 3. Launching (Usage)

The project is entirely managed via the Makefile located at the root:

    make or make up: Builds the images and starts the containers.

    make stop: Stops the containers without removing them.

    make down: Stops and removes the containers and networks.

    make fclean: Removes containers, images, and volumes for a complete cleanup.

    make re: Forces a full rebuild and restart of the infrastructure.

## 🔍 Useful Commands for Evaluation

    Check the network: docker network ls and docker network inspect inception_network

    Check the volumes: docker volume ls

    Verify SSL Certificate: openssl s_client -connect localhost:443 -tls1_2

    Check for no root login without password: docker exec -it mariadb mysql -u root -p

    Check container status: docker-compose ps

## Resources & AI Usage

### 📚 Resources
The following documentation and tutorials were essential in understanding and building this infrastructure:

- **Docker Official Documentation**: [Dockerfile Reference](https://docs.docker.com/engine/reference/builder/) and [Compose File V3](https://docs.docker.com/compose/compose-file/compose-file-v3/).
- **WordPress CLI (WP-CLI)**: [Official Commands List](https://developer.wordpress.org/cli/commands/) used for automating the installation without a browser.
- **MariaDB Knowledge Base**: [System Tables & Initialization](https://mariadb.com/kb/en/mysql_install_db/) to understand the data directory structure.
- **NGINX Documentation**: [Beginner's Guide](http://nginx.org/en/docs/beginners_guide.html) and [SSL Termination setup](https://nginx.org/en/docs/http/configuring_https_servers.html).
- **Linux FHS (Filesystem Hierarchy Standard)**: Documentation used to justify the choice of directories like `/var/www/html` and `/etc/php/`.

### 🤖 AI Usage Disclosure
Artificial Intelligence (Gemini) was used as a pedagogical assistant during this project. Here is a breakdown of the specific tasks performed with AI:

- **Conceptual Clarification**: Explaining abstract Docker concepts that are often briefly mentioned in documentation, such as the difference between PID 1 and background processes (`daemon off`), and the importance of `exec` in entrypoint scripts.
- **Idempotency Logic**: Brainstorming strategies to ensure scripts can be run multiple times without failure (e.g., using `IF NOT EXISTS` in SQL or file-existence checks for WordPress).


## Project Description

### Overview
The **Inception** project is a practical introduction to virtualization and system administration through the use of **Docker**. The goal is to build a complete, multi-service infrastructure from scratch, ensuring that each service runs in its own isolated container. This project emphasizes the "Infrastructure as Code" (IaC) approach, where the entire setup is reproducible with a single command.

### Why Docker?
In this project, Docker is used to achieve **Process Isolation** and **Environment Consistency**. Unlike traditional deployment where software is installed directly on the host OS (creating a "it works on my machine" problem), Docker packages the application and its dependencies into an **Image**. 
- **Predictability**: The environment inside the container is identical regardless of the host machine.
- **Microservices**: Each component (NGINX, MariaDB, WordPress) is isolated, meaning a failure in one service does not necessarily crash the others.
- **Efficiency**: By sharing the host's Linux Kernel, we avoid the heavy overhead of traditional Virtual Machines.

### Included Sources & Architecture
The project is structured to separate configuration from execution:
- **`srcs/docker-compose.yml`**: The orchestrator that defines how the containers, networks, and volumes interact.
- **`srcs/requirements/`**: This directory contains the "blueprints" for each service:
  - **Dockerfiles**: Scripts that define the build process (OS choice, package installation, configuration copying).
  - **Configs**: Static configuration files (e.g., `nginx.conf`, `www.conf`).
  - **Scripts**: Entrypoint scripts (`setup.sh`) that handle the runtime logic, such as database initialization and WordPress installation via WP-CLI.
- **`srcs/.env`**: Centralized environment variables (passwords, logins, domain names) used by the Compose file and scripts.

### Main Design Choices
1. **Simplified Security**: We implemented a **Bridge Network** to ensure that the MariaDB database is only accessible by the WordPress service and not exposed to the external internet.
2. **Minimalist Images**: We chose **Debian (or Alpine)** to keep the images small and reduce the attack surface.
3. **Data Integrity**: We used **Bind Mounts** to map container directories to `/home/login/data/`, ensuring that even if the containers are deleted, the website's data remains safe and persistent on the host machine.
4. **Idempotency**: All setup scripts are designed to check if the work is already done (e.g., if the DB is already initialized) before running, allowing the infrastructure to be safely restarted at any time.

### 1. Virtual Machines vs Docker
| Feature | Virtual Machines (VM) | Docker Containers |
| :--- | :--- | :--- |
| **Architecture** | Includes a full Guest OS and hardware emulation (Hypervisor). | Shares the Host OS Kernel; isolates processes. |
| **Performance** | High overhead (CPU/RAM) and slow boot times. | Near-native performance and near-instant startup. |
| **Size** | Large (several GBs per VM). | Very small (MBs per image). |
| **Isolation** | Stronger (Kernel-level isolation). | Logical (Namespace/Cgroup isolation). |

### 2. Secrets vs Environment Variables
| Feature | Environment Variables (`.env`) | Docker Secrets |
| :--- | :--- | :--- |
| **Storage** | Stored in the container config (visible via `inspect`). | Stored in encrypted logs or temporary memory (tmpfs). |
| **Visibility** | Visible to any process with access to the environment. | Mounted as files in `/run/secrets/`, accessible only to specific services. |
| **Usage** | Best for non-sensitive config (Site Title, Port). | **Mandatory** for sensitive data (Passwords, Private Keys). |

### 3. Docker Network vs Host Network
| Feature | Host Network | Docker Network (Bridge) |
| :--- | :--- | :--- |
| **Isolation** | No isolation. The container shares the host's IP/Ports. | Full isolation. Containers live in a private virtual subnet. |
| **Security** | High risk (all ports are exposed to the host). | High security. Only specified ports (e.g., 443) are exposed. |
| **Resolution** | Must use IP addresses or localhost. | Supports **Docker DNS**, allowing services to talk via names (e.g., `mariadb`). |

### 4. Docker Volumes vs Bind Mounts
| Feature | Docker Volumes | Bind Mounts |
| :--- | :--- | :--- |
| **Management** | Managed entirely by Docker (`/var/lib/docker/volumes`). | Managed by the User. Maps to a specific path on the Host. |
| **Portability** | High (easy to backup and move via Docker API). | Low (tied to the host's specific file structure). |
| **Project Choice** | Not used here to respect the mandatory path requirement. | Used to map `/home/login/data` to ensure data persistence on the VM. |