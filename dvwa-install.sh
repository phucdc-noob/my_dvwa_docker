#!/bin/bash

# check if script running on root privileges or not
check_root() {
  if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2
    exit 1
  fi
}

#check the connection
check_net() {
  if ping -q -c 1 -W 1 google.com >/dev/null; then
    echo "The network is up"
  else
    echo "The network is down"
  fi

}

# install requirements
requirements() {
  apt-get update -y && apt-get install -y php \
    mariadb-server \
    git \
    apache2 \
    php-mysqli \
    php-gd \
    libapache2-mod-php
}

# configuring something
config() {
  PHP_INI=$(find / -type f -name php.ini 2>/dev/null | grep apache2)
  sed -i 's,allow_url_include = Off,allow_url_include = On,g' $PHP_INI
  systemctl enable --now mariadb apache2
  mysql -u root <<_EOF_
    UPDATE mysql.global_priv SET priv=json_set(priv, '$.plugin', 'mysql_native_password', '$.authentication_string', PASSWORD('toor')) WHERE User='root';
    DELETE FROM mysql.global_priv WHERE User='';
    DELETE FROM mysql.global_priv WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
    DROP DATABASE IF EXISTS test;
    DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'
    FLUSH PRIVILEGES;
_EOF_
  echo "MariaDB's root password is 'toor'"
}

# install dvwa
dvwa() {
  mysql -u root <<_EOF_
    create database dvwa;
    create user dvwa@localhost identified by 'p@ssw0rd';
    grant all on dvwa.* to dvwa@localhost;
    flush privileges;
_EOF_
  git clone https://github.com/digininja/DVWA.git /var/www/html
  mv /var/www/html/config/config.inc.php.dist /var/www/html/config/config.inc.php
  chmod a+w /var/www/html/hackable/uploads/ \
    /var/www/html/external/phpids/0.6/lib/IDS/tmp/phpids_log.txt
}

setup() {
  check_root &&
  check_net &&
  requirements &&
  config &&
  dvwa
}

setup >/dev/null && echo "Done!" && exit 0
echo "Exiting..." && exit 1
