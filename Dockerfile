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

# Enable fail2ban service to protect SSH
RUN systemctl enable fail2ban

# Expose the SSH port
EXPOSE 22

# Start SSHD service in the foreground
CMD ["/usr/sbin/sshd", "-D"]