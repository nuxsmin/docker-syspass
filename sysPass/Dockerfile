FROM debian:jessie
MAINTAINER nuxsmin nuxsmin@syspass.org
LABEL from=github version=stable-master

# Usage:
# docker run -d --name=sysPass -p 80:80 -p 443:443 nuxsmin/docker-syspass
# webroot: /var/www/html/
# Apache2 config: /etc/apache2/

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get update \
	&& apt-get -y install locales \
	apache2 libapache2-mod-php5 php5 php5-curl php5-mysqlnd php5-gd \
	php5-json php5-ldap php5-mcrypt wget unzip vim \
	&& apt-get clean \
	&& rm -r /var/lib/apt/lists/*

WORKDIR /var/www/html

# Mininal Apache config using provided .conf files
COPY 000-default.conf default-ssl.conf /etc/apache2/sites-available/

# Custom entrypoint to run Apache on foreground
COPY entrypoint.sh /usr/local/sbin/

# Enable SSL site and set entrypoint permissions
RUN a2enmod ssl \
	&& a2ensite default-ssl \
	&& chmod 755 /usr/local/sbin/entrypoint.sh

LABEL version=2.1.11.17061503

# Download and install the latest sysPass stable release from GitHub
RUN wget https://github.com/nuxsmin/sysPass/archive/master.zip \
	&& unzip master.zip \
	&& mv sysPass-master sysPass \
	&& chmod 750 sysPass/config sysPass/backup \
	&& chown www-data -R sysPass/

EXPOSE 80 443

VOLUME ["/var/www/html/sysPass/config", "/var/www/html/sysPass/backup"]

ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]
