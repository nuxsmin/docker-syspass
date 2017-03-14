FROM debian:jessie
MAINTAINER nuxsmin nuxsmin@syspass.org
LABEL from=github version=devel php=7.0

# Usage:
# docker run -d --name=sysPass-dev -p 80:80 -p 443:443 nuxsmin/docker-syspass:devel
# webroot: /var/www/html/
# Apache2 config: /etc/apache2/

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

COPY dotdeb.gpg /tmp/dotdeb.gpg

RUN	echo 'deb http://packages.dotdeb.org jessie all' >> /etc/apt/sources.list \
	&& echo 'deb-src http://packages.dotdeb.org jessie all' >> /etc/apt/sources.list \
	&& apt-key add /tmp/dotdeb.gpg

RUN apt-get update \
	&& apt-get -y install locales \
	apache2 libapache2-mod-php7.0 php-pear php7.0 php7.0-cgi php7.0-cli \
	php7.0-common php7.0-fpm php7.0-gd php7.0-json php7.0-mysql php7.0-readline \
	php7.0-curl php7.0-intl php7.0-ldap php7.0-mcrypt php7.0-xml php7.0-mbstring\
	php7.0-xdebug wget unzip vim \
	&& apt-get clean \
	&& rm -r /var/lib/apt/lists/* \
	&& a2enmod proxy_fcgi setenvif \
	&& a2enconf php7.0-fpm

WORKDIR /var/www/html

LABEL version=2.1.2.17031401

# Mininal HTTP-only Apache config
COPY 000-default.conf /etc/apache2/sites-available/

# Xdebug module config
COPY 20-xdebug.ini /etc/php/7.0/apache2/conf.d/20-xdebug.ini

# Cutom entrypoint to run Apache on foreground
COPY entrypoint.sh /usr/local/sbin/
RUN chmod 755 /usr/local/sbin/entrypoint.sh

RUN pwd && wget https://github.com/nuxsmin/sysPass/archive/devel.zip \
	&& unzip devel.zip \
	&& mv sysPass-devel sysPass \
	&& chmod 750 sysPass/config sysPass/backup \
	&& chown www-data -R sysPass/

EXPOSE 80 443

VOLUME ["/var/log/apache2", "/var/www/html/sysPass"]

ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]
