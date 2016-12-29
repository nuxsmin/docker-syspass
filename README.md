**sysPass** is a powerful GPLv3 web password manager for business and personal use. See more at http://syspass.org

These images are based on Debian 8 (Jessie), Apache 2.4 webserver with PHP 5.6 module and MySQL 5.5. **No compilation stuff done**.

### Stable
The best way to get it running is by installing through docker-compose. You will get a fully working sysPass container with its database. You can get the compose file from https://github.com/nuxsmin/docker-syspass and then...

    wget https://raw.githubusercontent.com/nuxsmin/docker-syspass/master/docker-compose.yml
    docker-compose -p syspass up -d

Please take into account that you will need to setup a database if you choose to build the sysPass-only container.

### Development

If you want to test/develop the latest sysPass development, please deploy it from https://github.com/nuxsmin/docker-syspass/master/sysPass-dev through docker-compose ``docker-compose -p syspassdev up -d`` or pull it ``docker run --name sysPass-app-devel nuxsmin/docker-syspass:devel``. **Don't forget to setup a database if you pulled it.**
