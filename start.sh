#!/bin/bash

# 创建管理员用户admin，密码设置为123456
useradd -m admin && echo "admin:$(openssl passwd -6 123456)" | chpasswd -e

# 启动JupyterHub
jupyterhub -f /srv/jupyterhub/jupyterhub_config.py
