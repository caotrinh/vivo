#!/usr/bin/env bash

# Update package listings
apt-get update
apt-get install -y software-properties-common python-software-properties

# Install Java
add-apt-repository ppa:openjdk-r/ppa -y
apt-get update

echo "\n----- Installing Apache and Java 8 ------\n"
apt-get -y install apache2 openjdk-8-jdk
update-alternatives --config java

# Apache Tomcat
apt-get -y install tomcat8 tomcat8-admin tomcat8-docs
/bin/su -c "echo 'JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64' >>/etc/default/tomcat8"

# Apache Ant
apt-get install -y ant

#Apache HTTPD
apt-get install -y apache2
if ! [ -L /var/www ]; then
  rm -rf /var/www
  ln -fs /vagrant/apache/www /var/www
  #sed -i '/AllowOverride None/c AllowOverride All' /etc/apache2/sites-available/default

  sudo cp /vagrant/apache/conf/default /etc/apache2/sites-available/000-default.conf

  sudo a2enmod rewrite 2> /dev/null
  sudo a2enmod proxy 2> /dev/null
  sudo apt-get install libapache2-mod-jk
  sudo a2enmod jk 2> /dev/null
  sudo a2enmod authnz_ldap 2> /dev/null
  sudo a2enmod headers 2> /dev/null

  sudo service apache2 restart 2> /dev/null
fi

# MySQL
debconf-set-selections <<< 'mysql-server mysql-server/root_password password password'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password password'
apt-get install -y mysql-server

# Create Tables
mysql --user root --password=password --execute "CREATE DATABASE vivo CHARACTER SET utf8;"
mysql --user root --password=password --execute "GRANT ALL ON vivo.* TO 'vivo'@'localhost' IDENTIFIED BY 'changeme'"
mysql --user vivo --password=changeme vivo < /vagrant/vitro-core/opensocial/shindig_orng_tables.sql
mysql --user vivo --password=changeme vivo < /vagrant/vitro-core/opensocial/shindig_gadgets.sql

# Fix permissions
usermod -a -G tomcat8 ubuntu
mkdir -p /usr/local/vivo/home
mkdir -p /usr/local/vivo/home/shindig/openssl/
mkdir -p /usr/local/vivo/home/shindig/conf/
dd if=/dev/random bs=32 count=1 | openssl base64 > /usr/local/vivo/home/shindig/openssl/securitytokenkey.txt
chmod 777 -R /usr/local/vivo/

# Do a test build
su vagrant
cd /vagrant
cp build.properties.vagrant build.properties
cp /vagrant/config/runtime.properties /usr/local/vivo/home/
cp /vagrant/config/applicationSetup.n3 /usr/local/vivo/home/config/

ant orng

ant all

chown -R tomcat8:tomcat8 /usr/local/vivo/home
#copy setenv.sh script (increases worker thread memory allocation)
sudo cp /vagrant/apache/conf/setenv.sh /usr/share/tomcat8/bin/setenv.sh
sudo chmod 775 /usr/share/tomcat8/bin/setenv.sh

#create link to log directory
sudo ln -s /var/log/tomcat8/ /usr/share/tomcat8/logs
sudo touch /usr/share/tomcat8/logs/solr.log
sudo chmod 777 /var/log/tomcat8/solr.log
sudo touch /usr/share/tomcat8/logs/vivo.all.log
sudo chmod 777 /var/log/tomcat8/vivo.all.log

#Copy tomcat server.xml (contains the ajp13 worker config)
sudo cp /vagrant/apache/conf/server.xml /etc/tomcat8/server.xml
service tomcat8 restart
