# Secure File Transfer Using Docker

This repository provides a Docker setup for securely transferring files between Windows and Linux (or any Docker host) using an Ubuntu container with SSH enabled. You can use `scp` (Secure Copy Protocol) to push and pull files through the container’s SSH server.

---

## 📋 Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed on your system  
- Basic familiarity with the command line (PowerShell, Bash, etc.)  
- A text editor to review or modify the Dockerfile  

---

## 🛠️ Dockerfile Overview

```dockerfile
# Use the official Ubuntu image as the base
FROM ubuntu:latest

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Update the package list and install necessary packages
RUN apt-get update && \
    apt-get install -y \
      openssh-server \
      nano \
      vim \
      net-tools \
      curl \
      wget \
      fail2ban && \
    mkdir /var/run/sshd && \
    echo 'root:root' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Enable fail2ban service to protect SSH (requires systemd; see notes below)
RUN systemctl enable fail2ban

# Expose the SSH port
EXPOSE 22

# Start SSHD in the foreground
CMD ["/usr/sbin/sshd", "-D"]
```

- **Base image**: `ubuntu:latest`  
- **SSH server**: Installed and configured to allow root login with password  
- **Fail2Ban**: Enabled to protect against brute‑force attacks  
- **Exposed port**: `22` for SSH  

---

## 🚀 Build and Run

1. **Build the Docker image**  
   ```bash
   docker build -t my_ubuntu_ssh .
   ```

2. **Run the container**  
   ```bash
   docker run -d \
     --name scptest \
     -p 2222:22 \
     my_ubuntu_ssh
   ```

   - Maps host port **2222** → container port **22**  
   - Root password is set to `root` (see Security Notes)  

3. **Verify SSH is running**  
   ```bash
   docker ps
   # Should show your scptest container listening on 0.0.0.0:2222->22/tcp
   ```

---

## 🔐 Security Notes

- **Root login**: Enabled for demonstration. In production, create a non‑root user with SSH keys.  
- **Passwords**: The root password is `root`. Change it in the Dockerfile (`echo 'root:<your-password>'`) or use key-based auth.  
- **Fail2Ban**: Requires `systemd` to run properly inside container; you may need a workaround or external firewall rules.  

---

## 📂 Transferring Files with SCP

From your **host machine** (Windows PowerShell, Git Bash, or Linux shell):

- **Upload a file** to the container:
  ```bash
  scp -P 2222 path/to/local/file.txt root@localhost:/root/
  ```
- **Download a file** from the container:
  ```bash
  scp -P 2222 root@localhost:/root/file.txt path/to/local/destination/
  ```

> Replace `path/to/...` with your actual file paths.

---

## 🔄 Persisting Files

To persist files between container restarts, mount a host directory:

```bash
docker run -d \
  --name scptest \
  -p 2222:22 \
  -v /path/on/host:/root/transfer \
  my_ubuntu_ssh
```

- Files uploaded to `/root/transfer` inside the container will live on your host at `/path/on/host`.

---

## 🧹 Cleanup

- **Stop & remove** container:
  ```bash
  docker stop scptest
  docker rm scptest
  ```
- **Remove** image:
  ```bash
  docker rmi my_ubuntu_ssh
  ```

---

## 📖 Further Reading

- [Docker Documentation](https://docs.docker.com/)  
- [OpenSSH Man Page](https://man.openbsd.org/ssh)  
- [Fail2Ban Documentation](https://www.fail2ban.org/wiki/index.php/Main_Page)  

---

## 📄 License

This project is released under the MIT License. Feel free to use, modify, and distribute!
