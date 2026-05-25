FROM debian:bookworm

RUN apt-get update && apt-get install -y mariadb-server

COPY conf/my.conf /etc/mysql/mariadb.conf.d/50-server.conf
COPY tools/init.sh /init.sh

RUN chmod +x /init.sh

EXPOSE 3306

CMD ["/init.sh"]