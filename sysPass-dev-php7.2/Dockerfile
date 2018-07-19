FROM php:7.2-apache-stretch
LABEL maintainer=nuxsmin@syspass.org version=3.0-beta php=7.2 environment=debug

# Usage:
# docker run -d --name=sysPass-beta -p 80:80 -p 443:443 nuxsmin/docker-syspass:3.0-beta-php7.2
# webroot: /var/www/html/
# Apache2 config: /etc/apache2/

RUN apt-get update \
	&& DEBIAN_FRONTEND=noninteractive \
	&& apt-get -y install locales wget unzip git gosu libicu-dev libldb-dev libldap2-dev \
	&& apt-get clean \
	&& rm -r /var/lib/apt/lists/* \
	&& pecl install xdebug \
	&& docker-php-ext-install -j$(nproc) ldap intl gettext pdo_mysql \
	&& docker-php-ext-enable ldap xdebug intl pdo_mysql

ENV SYSPASS_BRANCH="devel-3.0" \
	SYSPASS_UID=9001

WORKDIR /var/www/html

LABEL build=2018062801

# Mininal HTTP-only Apache config
COPY 000-default.conf /etc/apache2/sites-available/

# Xdebug module config
COPY xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Custom entrypoint
COPY entrypoint.sh /usr/local/sbin/

RUN wget https://github.com/nuxsmin/sysPass/archive/${SYSPASS_BRANCH}.zip \
	&& chmod 755 /usr/local/sbin/entrypoint.sh

EXPOSE 80 443

ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]

CMD ["apache"]
