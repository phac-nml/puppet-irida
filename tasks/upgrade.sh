#!/bin/bash

set -e

. /irida_upgrade.config

echo "Stopping services..."
systemctl stop puppet
systemctl stop tomcat

echo "Dumping database..."
echo $db_password | su tomcat -c $tomcat_user mysqldump -h $db_host -u $db_user $db_name > ~tomcat/irida.dbbackup
chmod 0600 ~tomcat/irida.dbbackup
chown $tomcat_user:$tomcat_group ~tomcat/irida.dbbackup
mv ~tomcat/irida.dbbackup ~tomcat/irida-$(date  +"%y-%m-%d-%T").dbbackup

echo "Replacing WAR file..."
sudo -u $tomcat_user rm $tomcat_location/webapps/irida.war
sudo -u $tomcat_user curl -o $tomcat_location/webapps/irida.war $war_url

echo "Starting services..."
systemctl start tomcat
systemctl start puppet

echo "done"
