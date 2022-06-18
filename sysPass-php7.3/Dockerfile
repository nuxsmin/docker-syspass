#
# https://syspass.org
# https://doc.syspass.org
#
FROM composer:2.0 as bootstrap

ENV SYSPASS_BRANCH="3.2.8"

RUN git clone --depth 1 --branch ${SYSPASS_BRANCH} https://github.com/nuxsmin/sysPass.git \
  && composer install \
    --ignore-platform-reqs \
    --no-interaction \
    --no-plugins \
    --no-scripts \
    --prefer-dist \
    --no-dev \
    --classmap-authoritative \
    --working-dir /app/sysPass

FROM debian:buster as app

LABEL maintainer=nuxsmin@syspass.org version=3.2.8 php=7.3 environment=production

RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get -y install \
    locales \
    locales-all \
    apache2 \
    libapache2-mod-php7.3 \
    php-pear \
    php7.3 \
    php7.3-cgi \
    php7.3-cli \
    php7.3-common \
    php7.3-curl \
    php7.3-fpm \
    php7.3-gd \
    php7.3-intl \
    php7.3-json \
    php7.3-mbstring \
    php7.3-mysql \
    php7.3-opcache \
    php7.3-readline \
    php7.3-ldap \
    php7.3-xml \
    php7.3-zip \
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

LABEL build=22061802

# Custom sysPass Apache config with SSL by default
COPY ["syspass.conf", "/etc/apache2/sites-available/"]

# Custom entrypoint
COPY entrypoint.sh common_fn.sh /usr/local/sbin/

RUN chmod 755 /usr/local/sbin/entrypoint.sh \
  && a2dissite 000-default default-ssl \
  && a2ensite syspass \
  && a2enmod proxy_fcgi setenvif ssl rewrite \
  && a2enconf php7.3-fpm \
  && ln -sf /dev/stdout ${APACHE_LOG_DIR}/access.log \
  && ln -sf /dev/stderr ${APACHE_LOG_DIR}/error.log

# sysPass dependencies
COPY --from=bootstrap /app/sysPass/ ${SYSPASS_DIR}/

# Composer binary
COPY --from=bootstrap /usr/bin/composer /usr/bin/

EXPOSE 80 443

ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]

CMD ["apache"]
