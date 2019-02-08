# About

**sysPass** is a powerful GPLv3 web password manager for business and personal use.

See more at https://syspass.org

**No compilation stuff done**

## 3.0 release

These images are based on Debian 9 (Stretch), Apache 2.4 webserver with PHP 7.0 module and MariaDB 10.1

---

### Production

The best way to get it running is by installing through docker-compose. You will get a fully working sysPass environment with its database.

```
$ wget https://raw.githubusercontent.com/nuxsmin/docker-syspass/master/docker-compose.yml
$ docker-compose -p syspass up -d
```
Create .env file with the next variables you can change the parameters.

```
MARIADB_ROOT_PASSWORD=syspass
MARIADB_DATABASE=syspass
MARIADB_USER=syspass
MARIADB_PASSWORD=syspass
```

Please be aware that you will need to setup a database if you choose to build the sysPass-only container.

### Development

If you want to test/develop the current release, please deploy it from https://github.com/nuxsmin/docker-syspass/tree/master/sysPass-dev through docker-compose:

```
$ wget https://raw.githubusercontent.com/nuxsmin/docker-syspass/master/sysPass-dev/docker-compose.yml
$ docker-compose -p syspassdev up -d
```

or pull it:

```
$ docker run --name sysPass-app-devel nuxsmin/docker-syspass:devel
```

Please be aware that you will need to setup a database if you choose to build the sysPass-only container.
