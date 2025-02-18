# Add User or Group Permissions
## 1. Edit the Sudoers File
  1.1 Login on the managed node
  
    sudo visudo
    
  1.2 Add this on the last line to give username full sudo privileges
  
    <username> ALL=(ALL) NOPASSWD: ALL

  1.3 For group full sudo privileges, add

    %admin ALL=(ALL) NOPASSWD: ALL

 1.4 To check the changes

    su <username>
    sudo whoami

# Setup Ansible
## 2. Setup Inventory File
  2.1 Create an inventory file named hosts.ini

    [webservers]
    <server_name1> ansible_host=<IP_ADDRESS_1> ansible_user=<user_name1>
    <server_name2> ansible_host=<IP_ADDRESS_2> ansible_user=<user_name2>

## 3. Create Playbook
   3.1 Create a playbook named check_httpd.yml
    
    ---
    - name: Check httpd service status
      hosts: web_servers
      become: true
      tasks:
        - name: Check if httpd is running
          service:
            name: httpd
            state: started
          register: httpd_status
    
        - name: Display httpd status
          debug:
            msg: "HTTPD is {{ 'running' if httpd_status.state == 'started' else 'stopped' }}"

## 4. Create CI/CD Pipeline Script
  4.1 Create Shell Script automation 
    
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

4.2 Make the script executable

    chmod +x check_httpd_ci_cd.sh

4.3 Run the pipeline
    
    ./check_httpd_ci_cd.sh

# Integrate with CI/CD Platform
## 5. Github Actions Workflow
  5.1 Create the workflow on /ansible-script/.github/workflows/ansible-ci-cd.yml
    
    name: Ansible HTTPD Status Check

    on:
      push:
        branches:
          - main
    
    jobs:
      check-httpd-status:
        runs-on: ubuntu-latest

    steps:
    - name: Checkout repository
      uses: actions/checkout@v3

    - name: Set up Python for Ansible
      uses: actions/setup-python@v4
      with:
        python-version: '3.x'

    - name: Install Ansible
      run: |
        python -m pip install --upgrade pip
        pip install ansible

    - name: Install SSH dependencies
      run: |
        sudo apt-get install -y openssh-client

    - name: Configure SSH keys for authentication
      run: |
        mkdir -p ~/.ssh
        echo "$SSH_PRIVATE_KEY" > ~/.ssh/id_rsa
        chmod 600 ~/.ssh/id_rsa
        ssh-keyscan -H <server1_ip> >> ~/.ssh/known_hosts
        ssh-keyscan -H <server2_ip> >> ~/.ssh/known_hosts

    - name: Run Ansible Playbook to Check HTTPD
      run: |
        ansible-playbook -i hosts.ini check_httpd.yml

  5.2 Add SSH Key to Github to access Github secrets
    
    ssh-keygen -t rsa -b 4096 -C "<your_email@com>"

  5.3 Commit and Push changes to Github
    Go to ansible-script directory, execute these line below
    
    git add .
    git commit -m "Add GitHub Actions for Ansible HTTPD check"
    git push origin main

  5.4 Using Github Secrets for Server IPs
    To avoid hardcoding the server IPs in the workflow, store it in Github Secrets
    
    ssh-keyscan -H $SERVER1_IP >> ~/.ssh/known_hosts
    ssh-keyscan -H $SERVER2_IP >> ~/.ssh/known_hosts

