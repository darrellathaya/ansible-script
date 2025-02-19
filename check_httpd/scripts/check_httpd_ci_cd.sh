#!/bin/bash

# Run the Ansible playbook
ansible-playbook -i hosts.ini check_httpd.yml

# Check the exit status of the playbook
if [ $? -eq 0 ]; then
  echo "HTTPD status check completed successfully."
else
  echo "HTTPD status check failed!"
  exit 1
fi