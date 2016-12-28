FROM debian:jessie
MAINTAINER nuxsmin nuxsmin@syspass.org

# Basic MySQL container for sysPass
ENV MYSQL_USER=mysql \
    MYSQL_DATA_DIR=/var/lib/mysql \
    MYSQL_RUN_DIR=/run/mysqld \
    MYSQL_LOG_DIR=/var/log/mysql \
    DEBIAN_FRONTEND=noninteractive

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get update \
 && apt-get install -y mysql-server \
 && rm -rf ${MYSQL_DATA_DIR} \
 && rm -rf /var/lib/apt/lists/*

# Entrypoint is needed to setup MySQL database
COPY entrypoint.sh /usr/local/sbin/entrypoint.sh
RUN chmod 755 /usr/local/sbin/entrypoint.sh

EXPOSE 3306/tcp
ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]
CMD ["/usr/bin/mysqld_safe"]
