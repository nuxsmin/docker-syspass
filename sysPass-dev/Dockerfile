FROM debian:jessie
MAINTAINER nuxsmin nuxsmin@syspass.org
LABEL from=github version=devel

# Usage:
# docker run -d --name=sysPass-dev -p 80:80 -p 443:443 nuxsmin/docker-syspass:devel
# webroot: /var/www/html/
# Apache2 config: /etc/apache2/

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get update \
	&& apt-get -y install locales \
	apache2 libapache2-mod-php5 php5 php5-curl php5-mysqlnd php5-curl php5-gd php5-json php5-ldap php5-mcrypt wget unzip \
	php5-xdebug \
	&& apt-get clean \
	&& rm -r /var/lib/apt/lists/*

WORKDIR /var/www/html

LABEL version=1.3.0.16122901

# Upgrade packages on every build
RUN apt-get update && apt-get -y upgrade

# Mininal HTTP-only Apache config
COPY 000-default.conf /etc/apache2/sites-available/

# Xdebug module config
COPY 20-xdebug.ini /etc/php5/apache2/conf.d/20-xdebug.ini

# Cutom entrypoint to run Apache on foreground
COPY entrypoint.sh /usr/local/sbin/
RUN chmod 755 /usr/local/sbin/entrypoint.sh

RUN pwd && wget https://github.com/nuxsmin/sysPass/archive/devel.zip \
	&& unzip devel.zip \
	&& mv sysPass-devel sysPass \
	&& mkdir sysPass/backup \
	&& chmod 750 sysPass/config sysPass/backup \
	&& chown www-data -R sysPass/

EXPOSE 80 443

VOLUME ["/var/log/apache2", "/var/www/html/sysPass"]

ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]
