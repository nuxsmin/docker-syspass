sysPass is a powerful GPLv3 web password manager for business and personal use. See more at http://syspass.org

These images are based on Debian 8 (Jessie) and Apache web server with PHP module. No compilation stuff done.

The best way to get it running is by installing through docker-compose. You will get a fully working sysPass container with its database. You can get the compose file from https://github.com/nuxsmin/docker-syspass and then...

docker-compose up -d
