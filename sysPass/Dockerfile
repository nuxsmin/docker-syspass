# Usage:
# docker run -d --name=sysPass-beta -p 80:80 -p 443:443 nuxsmin/docker-syspass:3.0-beta
# webroot: /var/www/html/
# Apache2 config: /etc/apache2/

FROM composer:1.7 as bootstrap

ENV SYSPASS_BRANCH="3.0"

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

LABEL maintainer=nuxsmin@syspass.org version=3.0-rc5 php=7.0 environment=production

RUN apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get -y install locales \
	apache2 libapache2-mod-php7.0 php-pear php7.0 php7.0-cgi php7.0-cli \
	php7.0-common php7.0-fpm php7.0-gd php7.0-json php7.0-mysql php7.0-readline \
	php7.0-curl php7.0-intl php7.0-ldap php7.0-mcrypt php7.0-xml php7.0-mbstring \
  git gosu unzip \
	&& apt-get clean \
	&& rm -r /var/lib/apt/lists/* \
	&& a2enmod proxy_fcgi setenvif \
	&& a2enconf php7.0-fpm

ENV SYSPASS_UID 9001
ENV SYSPASS_DIR "/var/www/html/sysPass"

WORKDIR /var/www/html

LABEL build=18112601

# Mininal HTTP-only Apache config
COPY 000-default.conf /etc/apache2/sites-available/

# Custom entrypoint
COPY entrypoint.sh init-functions /usr/local/sbin/

RUN chmod 755 /usr/local/sbin/entrypoint.sh

COPY --from=bootstrap /app/sysPass/ ${SYSPASS_DIR}/

COPY --from=bootstrap /usr/bin/composer /usr/bin/

EXPOSE 80 443

ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]

CMD ["apache"]
