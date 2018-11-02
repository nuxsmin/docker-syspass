FROM php:7.1-apache-stretch
LABEL maintainer=nuxsmin@syspass.org version=3.0-beta php=7.1 environment=debug

# Usage:
# docker run -d --name=sysPass-beta -p 80:80 -p 443:443 nuxsmin/docker-syspass:3.0-beta-php7.1
# webroot: /var/www/html/
# Apache2 config: /etc/apache2/

RUN apt-get update \
	&& apt-get install -y \
    locales \
    wget \
    unzip \
    git \
    gosu \
    libicu-dev \
    libldb-dev \
    libldap2-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
	&& apt-get clean \
	&& rm -r /var/lib/apt/lists/* \
	&& pecl install xdebug-2.6.0 \
  && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
	&& docker-php-ext-install -j$(nproc) ldap intl gettext pdo_mysql opcache gd \
	&& docker-php-ext-enable ldap xdebug intl pdo_mysql

ENV APACHE_RUN_USER="www-data" \
	APACHE_RUN_GROUP="www-data" \
  SYSPASS_BRANCH="devel-3.0" \
	SYSPASS_UID=9001

WORKDIR /var/www/html

LABEL build=18110201

# Mininal HTTP-only Apache config
COPY 000-default.conf /etc/apache2/sites-available/

# Xdebug module config
COPY xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Custom entrypoint
COPY entrypoint.sh init-functions /usr/local/sbin/

RUN wget https://github.com/nuxsmin/sysPass/archive/${SYSPASS_BRANCH}.zip \
	&& chmod 755 /usr/local/sbin/entrypoint.sh

EXPOSE 80 443

ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]

CMD ["apache"]
