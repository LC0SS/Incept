# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: lcosson <lcosson@student.42.fr>            +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/04/27 14:10:35 by lcosson           #+#    #+#              #
#    Updated: 2026/04/27 14:10:54 by lcosson          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

NAME		= inception
LOGIN		= lcosson

COMPOSE		= docker compose -f srcs/docker-compose.yml
DATA_DIR	= /home/$(LOGIN)/data
WP_DIR		= $(DATA_DIR)/wordpress
DB_DIR		= $(DATA_DIR)/mariadb

all: up

prepare:
	mkdir -p $(WP_DIR)
	mkdir -p $(DB_DIR)

up: prepare
	$(COMPOSE) up --build

down:
	$(COMPOSE) down

stop:
	$(COMPOSE) stop

start:
	$(COMPOSE) start

restart: down up

logs:
	$(COMPOSE) logs -f

ps:
	$(COMPOSE) ps

clean:
	$(COMPOSE) down

fclean:
	$(COMPOSE) down -v --rmi all --remove-orphans
	rm -rf $(DATA_DIR)

re: fclean all

.PHONY: all prepare up down stop start restart logs ps clean fclean re