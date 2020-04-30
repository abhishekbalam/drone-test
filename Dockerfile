FROM ubuntu:bionic

MAINTAINER Abhishek Balam <abhishek@frappe.io>

ENV MYSQL_ROOT_PASSWORD=root

# Basic Requirements
RUN apt update && apt -y upgrade && \
	apt -y install git vim curl sudo wget \
	python3-pip python3-dev python3-setuptools virtualenv \
	python-pip python-dev python-setuptools \
	software-properties-common redis-server libcups2-dev \
	mysql-client postgresql-client

RUN apt -y install locales

# Nonroot Sudo User
RUN adduser --disabled-password --gecos '' frappe
RUN adduser frappe sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Nodejs 
RUN curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
RUN apt-get install -y nodejs
RUN npm install -g yarn

# Wkhtmltopdf
RUN wget -O /tmp/wkhtmltox.tar.xz https://github.com/frappe/wkhtmltopdf/raw/master/wkhtmltox-0.12.3_linux-generic-amd64.tar.xz
RUN tar -xf /tmp/wkhtmltox.tar.xz -C /tmp
RUN mv /tmp/wkhtmltox/bin/wkhtmltopdf /usr/local/bin/wkhtmltopdf
RUN chmod o+x /usr/local/bin/wkhtmltopdf

# Coverage
RUN pip3 install coverage==4.5.4 python-coveralls

# Locales
ENV LC_ALL=C.UTF-8 
ENV LANG=C.UTF-8

USER frappe

WORKDIR /home/frappe

# For Event Streaming
RUN mkdir -p site_configs

RUN wget "https://raw.githubusercontent.com/abhishekbalam/frappe/develop/.travis/consumer_db/mariadb.json" -P /home/frappe/site_configs/consumer_db/ && \
	wget "https://raw.githubusercontent.com/abhishekbalam/frappe/develop/.travis/consumer_db/postgres.json" -P /home/frappe/site_configs/consumer_db/
RUN wget "https://raw.githubusercontent.com/abhishekbalam/frappe/develop/.travis/producer_db/mariadb.json" -P /home/frappe/site_configs/producer_db/ && \
	wget "https://raw.githubusercontent.com/abhishekbalam/frappe/develop/.travis/producer_db/postgres.json" -P /home/frappe/site_configs/producer_db/


# Bench Install
RUN git clone https://github.com/frappe/bench --depth 1
RUN pip3 install -e ./bench

RUN sudo cp /home/frappe/.local/bin/bench /usr/bin

# Bench Init
# RUN bench init frappe-bench --skip-assets --python $(which python3) 
# RUN echo '"db_host": "127.0.0.1"' >> sites/common_site_config.json
# RUN sed -i 's/watch:/# watch:/g' Procfile && sed -i 's/schedule:/# schedule:/g' Procfile
