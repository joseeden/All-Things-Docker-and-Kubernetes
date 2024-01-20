

# SSH Hardening 

Best practices: 


1. **Limit SSH Access**
   - Restrict SSH access to only those who require it for administrative purposes.

        ```bash
        ## /etc/ssh/sshd_config
        AllowUsers username1 username2 
        ```   
   - Avoid using a common key pair for all users; instead, use individual user accounts.

2. **Use SSH Keys for Authentication**
   - Prefer public-key authentication over password authentication for increased security.

        ```bash
        ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa 
        ```
   - Disable password authentication if possible.

        ```bash
        ## /etc/ssh/sshd_config
        PasswordAuthentication no
        ```   

   - Regularly rotate SSH key pairs, especially for administrative accounts.

3. **Key Management**
   - Properly manage and secure SSH private keys.
   - Use tools like `ssh-keygen` to generate strong key pairs.
   - Consider the use of hardware-based security tokens for storing SSH keys.

4. **Disable Root Login**
   - Disable direct root login via SSH.

        ```bash
        ## /etc/ssh/sshd_config 
        PermitRootLogin  no
        ```    
   - Use non-root user accounts and sudo for administrative tasks.

5. **Change Default SSH Port**
   - Change the default SSH port (typically 22) to a non-standard port.

        ```bash
        ## /etc/ssh/sshd_config 
        Port 2222  # Use a port of your choice
        ```    

   - This can help mitigate automated attacks targeting the default port.

6. **IP Whitelisting**
   - Limit SSH access to specific IP addresses or ranges using firewall rules or Kubernetes Network Policies.
   - Whitelist only the necessary IP addresses for administrative access.

7. **SSH Banner**
   - Display a banner or message during SSH login to notify users of the system's policies.
   - Modify the `/etc/issue` file or use the `Banner` directive in the SSH server configuration.

8. **Use Strong Encryption**
   - Configure SSH to use strong cryptographic algorithms for key exchange, encryption, and MAC.
   - Disable weaker algorithms and protocols in the SSH server configuration.

9. **Implement Idle Timeout**
   - Set an idle timeout to automatically disconnect idle SSH sessions.

        ```bash
        ## /etc/ssh/sshd_config 
        ClientAliveInterval 300
        ClientAliveCountMax 0
        ```       
   - Reduces the risk of unauthorized access if a user forgets to log out.

10. **Logging and Auditing**
    - Enable SSH logging to monitor and audit SSH access.
    - Regularly review SSH logs for suspicious activities.
    - Integrate with system logging mechanisms.

        ```bash
        ## /etc/ssh/sshd_config 
        LogLevel VERBOSE
        ```    

11. **Two-Factor Authentication (2FA)**
    - Consider implementing two-factor authentication for SSH access.
    - Tools like Google Authenticator or Duo Security can be integrated for additional authentication factors.

12. **Regular Security Audits**
    - Conduct regular security audits of SSH configurations and access controls.
    - Test the effectiveness of access controls and authentication mechanisms.

13. **Containerized SSH Access**
    - Avoid SSH access directly into containers in a production environment.
    - Prefer using Kubernetes-native tools like `kubectl exec` for accessing containers.

14. **SSH Hardening for Hosts**
    - Apply general host hardening practices to the Kubernetes nodes to ensure the underlying operating system is secure.
    - This includes regular software updates, using minimal installations, and disabling unnecessary services.

15. **Use Bastion Hosts**
    - Employ a bastion host or jump server for accessing Kubernetes nodes.
    - Limit direct SSH access to nodes from external networks.


<br>

[Back to first page](../../README.md#kubernetes-security)
