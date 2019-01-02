<<<<<<< HEAD
FROM debian:jessie
LABEL maintainer=nuxsmin@syspass.org from=github version=devel

=======
>>>>>>> 3.0
# Usage:
# docker run -d --name=sysPass-beta -p 80:80 -p 443:443 nuxsmin/docker-syspass:3.0-beta-php7.0
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

LABEL maintainer=nuxsmin@syspass.org version=3.0 php=7.0 environment=debug

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
		SYSPASS_BRANCH="devel" \
		SYSPASS_UID=9001

WORKDIR /var/www/html

<<<<<<< HEAD
# Mininal Apache config using provided .conf files
COPY 000-default.conf default-ssl.conf /etc/apache2/sites-available/

# Custom entrypoint to run Apache on foreground
COPY entrypoint.sh /usr/local/sbin/

# Enable SSL site and set entrypoint permissions
RUN a2enmod ssl \
	&& a2ensite default-ssl \
	&& chmod 755 /usr/local/sbin/entrypoint.sh

LABEL build=18061901

# Download and install the latest sysPass stable release from GitHub
RUN wget https://github.com/nuxsmin/sysPass/archive/${SYSPASS_BRANCH}.zip
=======
LABEL build=18122601

# Mininal HTTP-only Apache config
COPY ["000-default.conf", "default-ssl.conf", "/etc/apache2/sites-available/"]

# Xdebug module config
COPY 20-xdebug.ini /etc/php/7.0/apache2/conf.d/20-xdebug.ini

# Custom entrypoint
COPY entrypoint.sh init-functions /usr/local/sbin/

RUN chmod 755 /usr/local/sbin/entrypoint.sh \
  && a2ensite default-ssl
>>>>>>> 3.0

COPY --from=bootstrap /app/sysPass/ ${SYSPASS_DIR}/

<<<<<<< HEAD
VOLUME ["/var/www/html/sysPass/config", "/var/www/html/sysPass/backup"]
=======
COPY --from=bootstrap /usr/bin/composer /usr/bin/

EXPOSE 80 443
>>>>>>> 3.0

ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]

CMD ["apache"]
