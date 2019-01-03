FROM debian:jessie
LABEL maintainer=nuxsmin@syspass.org from=github version=devel

# Usage:
# docker run -d --name=sysPass-dev -p 80:80 -p 443:443 nuxsmin/docker-syspass:devel
# webroot: /var/www/html/
# Apache2 config: /etc/apache2/

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get update \
	&& apt-get -y install locales \
	apache2 libapache2-mod-php5 php5 php5-curl php5-mysqlnd php5-curl php5-gd \
	php5-json php5-ldap php5-mcrypt wget unzip php5-xdebug vim \
	&& apt-get clean \
	&& rm -r /var/lib/apt/lists/*

ENV APACHE_RUN_USER="www-data" \
		APACHE_RUN_GROUP="www-data" \
		APACHE_LOG_DIR="/var/log/apache2" \
		APACHE_LOCK_DIR="/var/lock/apache2" \
		APACHE_PID_FILE="/var/run/apache2.pid" \
		SYSPASS_BRANCH="2.1" \
		SYSPASS_UID=9001

WORKDIR /var/www/html

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

EXPOSE 80 443

VOLUME ["/var/www/html/sysPass/config", "/var/www/html/sysPass/backup"]

ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]

CMD ["apache"]
