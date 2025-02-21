

    /check_httpd
        ├── check_httpd.yml
        ├── hosts.ini

# Add User or Group Permissions
## 1. Edit the Sudoers File
  Login on the managed node
  
    sudo visudo
    
  Add this on the last line to give username full sudo privileges
  
    <username> ALL=(ALL) NOPASSWD: ALL

  For group full sudo privileges, add

    %admin ALL=(ALL) NOPASSWD: ALL

  To check the changes

    su <username>
    sudo whoami

# Setup Ansible
## 2. Setup Inventory File
  Create an inventory file named hosts.ini

    [webservers]
    <server_name1> ansible_host=<IP_ADDRESS_1> ansible_user=<user_name1>
    <server_name2> ansible_host=<IP_ADDRESS_2> ansible_user=<user_name2>

## 3. Create Playbook
   Create a playbook named check_httpd.yml
    
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
