FROM debian:jessie
MAINTAINER nuxsmin nuxsmin@syspass.org
LABEL from=github version=stable-master

# Usage:
# docker run -d --name=sysPass -p 80:80 -p 443:443 nuxsmin/docker-syspass
# webroot: /var/www/html/
# Apache2 config: /etc/apache2/

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get update && \
	apt-get -y install \
	apache2 libapache2-mod-php5 php5 php5-curl php5-mysqlnd php5-curl php5-gd php5-json php5-ldap php5-mcrypt wget unzip \
	&& apt-get clean \
	&& rm -r /var/lib/apt/lists/*

WORKDIR /var/www/html

LABEL version=1.2.0.21

# Upgrade packages on every build
RUN apt-get update && apt-get -y upgrade

# Mininal HTTP-only Apache cnfig
COPY 000-default.conf /etc/apache2/sites-available/

# Cutom entrypoint to run Apache on foreground
COPY entrypoint.sh /usr/local/sbin/
RUN chmod 755 /usr/local/sbin/entrypoint.sh

# Download and install the latest sysPass release from GitHub
RUN wget https://github.com/nuxsmin/sysPass/archive/master.zip \
	&& unzip master.zip \
	&& mv sysPass-master sysPass \
	&& mkdir sysPass/backup \
	&& chmod 750 sysPass/config sysPass/backup \
	&& chown www-data -R sysPass/

EXPOSE 80 443

VOLUME /etc/apache2/sites-available/

ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]
