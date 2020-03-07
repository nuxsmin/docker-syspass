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
    --no-dev \
    --classmap-authoritative \
    --working-dir /app/sysPass

FROM debian:stretch as app

LABEL maintainer=nuxsmin@syspass.org version=3.1.2 php=7.0 environment=production

RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get -y install \
    locales \
    apache2 \
    libapache2-mod-php7.0 \
    php-pear \
    php7.0 \
    php7.0-cgi \
    php7.0-cli \
    php7.0-common \
    php7.0-fpm \
    php7.0-gd \
    php7.0-json \
    php7.0-mysql \
    php7.0-readline \
    php7.0-curl \
    php7.0-intl \
    php7.0-ldap \
    php7.0-mcrypt \
    php7.0-xml \
    php7.0-mbstring \
    git \
    gosu \
    unzip \
  && apt-get clean \
  && rm -r /var/lib/apt/lists/*

ENV APACHE_RUN_USER="www-data" \
    APACHE_RUN_GROUP="www-data" \
    APACHE_LOG_DIR="/var/log/apache2" \
    APACHE_LOCK_DIR="/var/lock/apache2" \
    APACHE_PID_FILE="/var/run/apache2.pid" \
    SYSPASS_DIR="/var/www/html/sysPass" \
    SYSPASS_UID=9001

WORKDIR /var/www/html

LABEL build=19030701

# Custom sysPass Apache config with SSL by default
COPY ["syspass.conf", "/etc/apache2/sites-available/"]

# Custom entrypoint
COPY entrypoint.sh init-functions /usr/local/sbin/

RUN chmod 755 /usr/local/sbin/entrypoint.sh \
  && a2dissite 000-default default-ssl \
  && a2ensite syspass \
  && a2enmod proxy_fcgi setenvif ssl rewrite \
  && a2enconf php7.0-fpm \
  && ln -sf /dev/stdout ${APACHE_LOG_DIR}/access.log \
  && ln -sf /dev/stderr ${APACHE_LOG_DIR}/error.log

# sysPass dependencies
COPY --from=bootstrap /app/sysPass/ ${SYSPASS_DIR}/

# Composer binary
COPY --from=bootstrap /usr/bin/composer /usr/bin/

EXPOSE 80 443

ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]

CMD ["apache"]
