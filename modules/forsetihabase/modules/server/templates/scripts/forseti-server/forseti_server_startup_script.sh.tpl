#!/bin/bash
set -eu

# Env variables
USER=ubuntu
USER_HOME=/home/ubuntu

# forseti_conf_server digest: ${forseti_conf_server_checksum}
# This digest is included in the startup script to rebuild the Forseti server VM
# whenever the server configuration changes.

# Ubuntu update.
sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
sudo apt-get update -y
sudo apt-get --assume-yes install google-cloud-sdk git unzip

if ! [ -e "/usr/sbin/google-fluentd" ]; then
    cd $USER_HOME
    curl -sSO https://dl.google.com/cloudagents/install-logging-agent.sh
    bash install-logging-agent.sh
fi

# Check whether Cloud SQL proxy is installed.
if [ -z "$(which cloud_sql_proxy)" ]; then
      cd $USER_HOME
      wget https://dl.google.com/cloudsql/cloud_sql_proxy.${cloudsql_proxy_arch}
      sudo mv cloud_sql_proxy.${cloudsql_proxy_arch} /usr/local/bin/cloud_sql_proxy
      chmod +x /usr/local/bin/cloud_sql_proxy
fi

# Install Forseti Security.
cd $USER_HOME
rm -rf *forseti*

# Download Forseti source code
git clone ${forseti_repo_url}
cd forseti-security
git fetch --all
git checkout ${forseti_version}

# Forseti host dependencies
sudo apt-get install -y $(cat install/dependencies/apt_packages.txt | grep -v "#" | xargs)

# Forseti dependencies
python3 -m pip install -q --upgrade setuptools wheel
python3 -m pip install -q --upgrade -r requirements.txt

# Setup Forseti logging
touch /var/log/forseti.log
chown ubuntu:root /var/log/forseti.log
cp ${forseti_home}/configs/logging/fluentd/forseti.conf /etc/google-fluentd/config.d/forseti.conf
cp ${forseti_home}/configs/logging/logrotate/forseti /etc/logrotate.d/forseti
chmod 644 /etc/logrotate.d/forseti
service google-fluentd restart
logrotate /etc/logrotate.conf

# Change the access level of configs/ rules/ and run_forseti.sh
chmod -R ug+rwx ${forseti_home}/configs ${forseti_home}/rules ${forseti_home}/install/gcp/scripts/run_forseti.sh

# Install Forseti
echo "Installing Forseti"
python3 setup.py install

# Export variables required by initialize_forseti_services.sh.
${forseti_env}

# Export variables required by run_forseti.sh
${forseti_environment}

# Store the variables in /etc/profile.d/forseti_environment.sh
# so all the users will have access to them
echo "${forseti_environment}" > /etc/profile.d/forseti_environment.sh | sudo sh
