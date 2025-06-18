# 使用基础镜像
FROM quay.io/jupyterhub/jupyterhub:5.2.1
LABEL maintainer="moweng<changtao86@163.com>"

# 安装系统级别的依赖
RUN apt-get update && \
    apt-get install -y vim sqlite3 tzdata python3-dev build-essential libopenblas-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 配置时区为 Asia/Shanghai
RUN echo 'Asia/Shanghai' > /etc/timezone && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata

# 复制 TA-Lib 源码
COPY ta-lib-0.6.4-src.tar.gz /tmp/

# 编译并安装 TA-Lib
WORKDIR /tmp
RUN tar -xzf ta-lib-0.6.4-src.tar.gz && \
    cd ta-lib-0.6.4 && \
    ./configure --prefix=/usr && \
    make && \
    make install && \
    cd .. && \
    rm -rf ta-lib-0.6.4 ta-lib-0.6.4-src.tar.gz

# 设置环境变量
ENV TA_INCLUDE_PATH=/usr/include
ENV TA_LIBRARY_PATH=/usr/lib

# 将requirements.txt复制到容器中，并创建一个标记文件以强制刷新缓存
COPY requirements.txt /tmp/requirements.txt
RUN touch /tmp/.force-reinstall

# 安装所有Python包
RUN pip install -i https://mirrors.aliyun.com/pypi/simple/ -r /tmp/requirements.txt && \
    rm /tmp/requirements.txt

# 生成默认的jupyterhub配置文件
RUN mkdir -p /srv/jupyterhub && \
    jupyterhub --generate-config -f /srv/jupyterhub/jupyterhub_config.py

WORKDIR /srv/jupyterhub

# 复制准备好的额外配置文件，并追加到生成的配置文件中
COPY jupyterhub_config.txt /tmp/jupyterhub_config.txt
RUN cat /tmp/jupyterhub_config.txt >> /srv/jupyterhub/jupyterhub_config.py && \
    rm /tmp/jupyterhub_config.txt

# 复制事先准备好的/start.sh脚本并设置可执行权限
COPY start.sh /start.sh
RUN chmod +x /start.sh

# 暴露必要的端口
EXPOSE 8000 

# 设置容器启动时执行/start.sh脚本
CMD ["/start.sh"]
