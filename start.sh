#!/bin/bash

# 定义日志文件路径
LOG_FILE="/home/start.log"

# 将标准输出和标准错误重定向到日志文件
exec > >(tee -a "$LOG_FILE") 2>&1

# 创建管理员用户admin，密码设置为123456
echo "创建管理员用户admin，初始密码设置为123456，请及时修改..."
useradd -m admin && echo "admin:$(openssl passwd -6 123456)" | chpasswd -e

# 启动 JupyterHub 或其他服务
echo "启动JupyterHub..."
jupyterhub -f /srv/jupyterhub/jupyterhub_config.py
