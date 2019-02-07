# Usage:
# docker run -d --name=sysPass-dev -p 80:80 -p 443:443 nuxsmin/docker-syspass:3.0-dev
# webroot: /var/www/html/
# Apache2 config: /etc/apache2/

FROM composer:1.7 as bootstrap

ENV SYSPASS_BRANCH="master"

RUN git clone --branch ${SYSPASS_BRANCH} https://github.com/nuxsmin/sysPass.git \
  && composer install \
    --ignore-platform-reqs \
    --no-interaction \
    --no-plugins \
    --no-scripts \
    --prefer-dist \
    --optimize-autoloader \
    --working-dir /app/sysPass

FROM debian:stretch as app

LABEL maintainer=nuxsmin@syspass.org version=3.0.5 php=7.0 environment=debug

RUN apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get -y install locales \
	apache2 libapache2-mod-php7.0 php-pear php7.0 php7.0-cgi php7.0-cli \
	php7.0-common php7.0-fpm php7.0-gd php7.0-json php7.0-mysql php7.0-readline \
	php7.0-curl php7.0-intl php7.0-ldap php7.0-mcrypt php7.0-xml php7.0-mbstring \
	php7.0-xdebug git gosu unzip \
	&& apt-get clean \
	&& rm -r /var/lib/apt/lists/* \
	&& a2enmod proxy_fcgi setenvif ssl \
	&& a2enconf php7.0-fpm

ENV SYSPASS_UID 9001
ENV SYSPASS_DIR "/var/www/html/sysPass"

ENV APACHE_RUN_USER="www-data" \
		APACHE_RUN_GROUP="www-data" \
		APACHE_LOG_DIR="/var/log/apache2" \
		APACHE_LOCK_DIR="/var/lock/apache2" \
		APACHE_PID_FILE="/var/run/apache2.pid" \
		SYSPASS_BRANCH="master" \
		SYSPASS_UID=9001

WORKDIR /var/www/html

LABEL build=19020701

# Mininal HTTP-only Apache config
COPY ["000-default.conf", "default-ssl.conf", "/etc/apache2/sites-available/"]

# Xdebug module config
COPY 20-xdebug.ini /etc/php/7.0/apache2/conf.d/20-xdebug.ini

# Custom entrypoint
COPY entrypoint.sh init-functions /usr/local/sbin/

RUN chmod 755 /usr/local/sbin/entrypoint.sh \
  && a2ensite default-ssl

COPY --from=bootstrap /app/sysPass/ ${SYSPASS_DIR}/

COPY --from=bootstrap /usr/bin/composer /usr/bin/

EXPOSE 80 443

ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]

CMD ["apache"]
