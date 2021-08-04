#!/bin/bash

set -e

. /etc/irida/irida_upgrade.config

if [[ -z "${tomcat_location}" ]]; then
  echo "tomcat_location not defined. Please ensure set in /etc/irida/irida_upgrade.config."
  exit 1
fi

if [[ -z "${irida_url_path}" ]]; then
  echo "irida_url_path not defined. Please ensure set in /etc/irida/irida_upgrade.config."
  exit 1
fi

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
#removing both expanded folder and war file itself
sudo -u $tomcat_user rm -rf $tomcat_location/webapps/$irida_url_path
sudo -u $tomcat_user rm $tomcat_location/webapps/$irida_url_path'.war'
#downloading newer version
sudo -u $tomcat_user curl -L -o $tomcat_location/webapps/$irida_url_path'.war' $war_url

echo "Starting services..."
#only restarting puppet since it will start tomcat for us
#want to avoid a potential race condition
systemctl start puppet

echo "done"
