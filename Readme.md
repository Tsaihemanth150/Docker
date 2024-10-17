# Secure File Transfer Using Docker

This guide explains how to securely transfer files between Windows and Linux using a Docker container. We will create a Docker container running Ubuntu with SSH enabled to facilitate file transfers via SCP (Secure Copy Protocol).

## Prerequisites
- Docker installed on your system
- Basic knowledge of command line operations
- A text editor to create the Dockerfile

## Steps for Setting Up Secure File Transfer

### 1. Pull the Ubuntu Image
First, pull the latest Ubuntu image from Docker Hub:

```bash
docker pull ubuntu


# commands :
docker run -it -p 2222:22 --name scptest my_ubuntu_ssh 
