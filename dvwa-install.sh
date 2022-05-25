#!/bin/bash

# Bold High Intensty colors
RED_BHI="\e[1;91m"
GREEN_BHI="\e[1;92m"
YELLOW_BHI="\e[1;93m"

# escape ANSI code
ESC="\e[0m"

# success & error message:
SUCC="${GREEN_BHI}\tSucceed!${ESC}\n==============================================\n"
ERR="${RED_BHI}\tFailed!${ESC}\n=============================================\n"

# print output
printout() {
  printf "$@" 1>&2
}

# check if script running on root privileges or not
check_root() {
  printout "${YELLOW_BHI}- Checking for root privileges:"
  if [ "$(id -u)" != "0" ]; then
    printout "${ERR}"
    exit 1
  fi
  printout "${SUCC}"
}

#check the connection
check_net() {
  printout "${YELLOW_BHI}- Checking for connection:"
  if ping -q -c 1 -W 1 google.com >/dev/null; then
    printout "${SUCC}"
  else
    printout "${ERR}" 
    exit 1
  fi

}

# install requirements
requirements() {
  printout "${YELLOW_BHI}- Installing requirements:"
  apt-get update -y && apt-get install -y php \
    mariadb-server \
    git \
    apache2 \
    php-mysqli \
    php-gd \
    libapache2-mod-php &&
    printout "${SUCC}"
}

# configuring something
config() {
  printout "${YELLOW_BHI}- Configuring PHP & Apache:"
  PHP_INI=$(find / -type f -name php.ini 2>/dev/null | grep apache2)
  sed -i 's,allow_url_include = Off,allow_url_include = On,g' $PHP_INI
  printout "${SUCC}"
  printout "${YELLOW_BHI}- Configuring MariaDB:"
  systemctl enable --now mariadb apache2
  mysql -u root <<_EOF_
    UPDATE mysql.global_priv SET priv=json_set(priv, '$.plugin', 'mysql_native_password', '$.authentication_string', PASSWORD('toor')) WHERE User='root';
    DELETE FROM mysql.global_priv WHERE User='';
    DELETE FROM mysql.global_priv WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
    DROP DATABASE IF EXISTS test;
    DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
    FLUSH PRIVILEGES;
_EOF_
  printout "$SUCC"
}

# install dvwa
dvwa() {
  printout "${YELLOW_BHI}- Installing DVWA:"
  mysql -u root <<_EOF_
    create database dvwa;
    create user dvwa@localhost identified by 'p@ssw0rd';
    grant all on dvwa.* to dvwa@localhost;
    flush privileges;
_EOF_
  rm -rf /var/www/html && mkdir /var/www/html
  git clone https://github.com/digininja/DVWA.git /var/www/html
  mv /var/www/html/config/config.inc.php.dist /var/www/html/config/config.inc.php
  chmod a+w /var/www/html/hackable/uploads/ \
    /var/www/html/external/phpids/0.6/lib/IDS/tmp/phpids_log.txt
  printout "${SUCC}"
}

setup() {
  check_root &&
  check_net &&
  requirements &&
  config &&
  dvwa &&
  printout "${GREEN_BHI}Done! Now you can go to http://localhost/ (Ctrl + Click to open) to access to DVWA with credential: admin/password\n"
  printout "Your default MariaDB's root password is 'toor'.${ESC}"
}

setup >/dev/null && exit 0
exit 1