FROM nuxsmin/apache-php
MAINTAINER nuxsmin nuxsmin@syspass.org
LABEL from=github version=devel

# Usage:
# docker run -d --name=syspass-devel nuxsmin/syspass:devel

RUN apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get -y install \
	php5-curl \
	php5-gd \
	php5-json \
	php5-ldap \
	php5-mcrypt \
	php5-xdebug \
	wget \
	unzip \
	&& apt-get clean \
	&& rm -r /var/lib/apt/lists/*

COPY 20-xdebug.ini /etc/php5/apache2/conf.d/20-xdebug.ini

WORKDIR /var/www/html

RUN pwd && wget https://github.com/nuxsmin/sysPass/archive/devel.zip \
	&& unzip devel.zip \
	&& mv sysPass-devel sysPass \
	&& chown www-data -R sysPass/ \
	&& chmod 750 sysPass/config \
	&& mkdir sysPass/backup \
	&& chmod 750 sysPass/backup

VOLUME ["/var/log/apache2"]

COPY entrypoint.sh /usr/local/sbin/

RUN chmod 755 /usr/local/sbin/entrypoint.sh

ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]


