#
# https://syspass.org
# https://doc.syspass.org
#

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

FROM php:7.3-apache-stretch as app

LABEL maintainer=nuxsmin@syspass.org version=3.1.0 php=7.3

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
    unzip \
    ssl-cert \
	&& apt-get clean \
	&& rm -r /var/lib/apt/lists/* \
	&& pecl install xdebug-2.7.1 \
  && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
	&& docker-php-ext-install -j$(nproc) ldap intl gettext pdo_mysql opcache gd \
	&& docker-php-ext-enable ldap xdebug intl pdo_mysql

ENV APACHE_RUN_USER="www-data" \
    SYSPASS_DIR="/var/www/html/sysPass" \
    SYSPASS_UID=9001 \
    SYSPASS_DEV=0

WORKDIR /var/www/html

LABEL build=19081801

# Custom sysPass Apache config with SSL by default
COPY ["syspass.conf", "/etc/apache2/sites-available/"]

# Xdebug module config
COPY xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Custom entrypoint
COPY entrypoint.sh init-functions /usr/local/sbin/

RUN chmod 755 /usr/local/sbin/entrypoint.sh \
  && a2dissite 000-default default-ssl \
  && a2ensite syspass \
  && a2enmod proxy_fcgi setenvif ssl rewrite \
  && ln -sf /dev/stdout ${APACHE_LOG_DIR}/access.log \
  && ln -sf /dev/stderr ${APACHE_LOG_DIR}/error.log

# sysPass dependencies
COPY --from=bootstrap /app/sysPass/ ${SYSPASS_DIR}/

# Composer binary
COPY --from=bootstrap /usr/bin/composer /usr/bin/

EXPOSE 80 443

ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]

CMD ["apache"]
