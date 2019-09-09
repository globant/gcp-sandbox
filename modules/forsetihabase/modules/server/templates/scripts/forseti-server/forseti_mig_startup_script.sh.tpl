#!/bin/bash
set -eu

# Env variables
USER=ubuntu
USER_HOME=/home/ubuntu

cd $USER_HOME/forseti-security

# Export variables required by initialize_forseti_services.sh.
${forseti_env}

# Export variables required by run_forseti.sh
${forseti_environment}

# Download server configuration from GCS
gsutil cp gs://${storage_bucket_name}/configs/forseti_conf_server.yaml ${forseti_server_conf_path}
gsutil cp -r gs://${storage_bucket_name}/rules ${forseti_home}/

# Download the Newest Config Validator constraints from GCS
rm -rf ${forseti_home}/policy-library

# Attempt to download the config-validator policy and gracefully handle the absence
# of policy files.  The config-validator is not required for the rest of Forseti
# and should not halt installation.
gsutil cp -r gs://${storage_bucket_name}/policy-library ${forseti_home}/ || echo "No policy available, continuing with Forseti installation"

# Start Forseti service depends on vars defined above.
bash ./install/gcp/scripts/initialize_forseti_services.sh
echo "Starting services."
systemctl start cloudsqlproxy
systemctl start config-validator
sleep 5

echo "Attempting to update database schema, if necessary."
python3 $USER_HOME/forseti-security/install/gcp/upgrade_tools/db_migrator.py

systemctl start forseti
echo "Success! The Forseti API server has been started."

# Create a Forseti env script
FORSETI_ENV="$(cat << EOF
#!/bin/bash

export PATH=$PATH:/usr/local/bin

# Forseti environment variables
${forseti_environment}
EOF
)"
echo "$FORSETI_ENV" > $USER_HOME/forseti_env.sh

USER=ubuntu
# Use flock to prevent rerun of the same cron job when the previous job is still running.
# If the lock file does not exist under the tmp directory, it will create the file and put a lock on top of the file.
# When the previous cron job is not finished and the new one is trying to run, it will attempt to acquire the lock
# to the lock file and fail because the file is already locked by the previous process.
# The -n flag in flock will fail the process right away when the process is not able to acquire the lock so we won't
# queue up the jobs.
# If the cron job failed the acquire lock on the process, it will log a warning message to syslog.
(echo "${forseti_run_frequency} (/usr/bin/flock -n ${forseti_home}/forseti_cron_runner.lock ${forseti_home}/install/gcp/scripts/run_forseti.sh -b ${storage_bucket_name} || echo '[forseti-security] Warning: New Forseti cron job will not be started, because previous Forseti job is still running.') 2>&1 | logger") | crontab -u $USER -
echo "Added the run_forseti.sh to crontab under user $USER"
rm -r /home/ubuntu/config_files
echo "Execution of startup script finished"
