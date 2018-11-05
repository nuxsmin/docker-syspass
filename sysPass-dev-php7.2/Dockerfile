# Usage:
# docker run -d --name=sysPass-beta -p 80:80 -p 443:443 nuxsmin/docker-syspass:3.0-beta-php7.0
# webroot: /var/www/html/
# Apache2 config: /etc/apache2/

FROM composer:1.7 as bootstrap

ENV SYSPASS_BRANCH="devel-3.0"

RUN git clone --branch ${SYSPASS_BRANCH} https://github.com/nuxsmin/sysPass.git \
  && composer install \
    --ignore-platform-reqs \
    --no-interaction \
    --no-plugins \
    --no-scripts \
    --prefer-dist \
    --optimize-autoloader \
    --working-dir /app/sysPass

FROM php:7.2-apache-stretch as app
LABEL maintainer=nuxsmin@syspass.org version=3.0-beta php=7.2 environment=debug

RUN apt-get update \
	&& apt-get install -y \
    locales \
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

ENV SYSPASS_UID 9001
ENV SYSPASS_DIR "/var/www/html/sysPass"

WORKDIR /var/www/html

LABEL build=18110503

# Mininal HTTP-only Apache config
COPY 000-default.conf /etc/apache2/sites-available/

# Xdebug module config
COPY xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Custom entrypoint
COPY entrypoint.sh init-functions /usr/local/sbin/

RUN chmod 755 /usr/local/sbin/entrypoint.sh

COPY --from=bootstrap /app/sysPass/ ${SYSPASS_DIR}/

COPY --from=bootstrap /usr/bin/composer /usr/bin/

EXPOSE 80 443

ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]

CMD ["apache"]
