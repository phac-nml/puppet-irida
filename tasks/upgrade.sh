#!/bin/bash

set -e

. /etc/irida/irida_upgrade.config

echo "Stopping services..."
systemctl stop puppet
systemctl stop tomcat

echo "Dumping database..."
#Root user
mysqldump  $db_name > /tmp/irida.dbbackup
chmod 0600 /tmp/irida.dbbackup
chown $tomcat_user:$tomcat_group /tmp/irida.dbbackup
#######

#execute move as user to ensure permission are preserved if location is on NFS
sudo -u $tomcat_user mv /tmp/irida.dbbackup $db_backup_location/irida-$(date  +"%y-%m-%d-%T").dbbackup

echo "Replacing WAR file..."
sudo -u $tomcat_user rm $tomcat_location/webapps/irida.war
sudo -u $tomcat_user curl -o $tomcat_location/webapps/irida.war $war_url

echo "Starting services..."
systemctl start puppet

echo "done"
