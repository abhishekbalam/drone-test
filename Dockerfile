FROM ubuntu:bionic

MAINTAINER Abhishek Balam <abhishek@frappe.io>

# Basic Requirements
RUN apt update && apt -y upgrade && \
	apt -y install git vim curl sudo wget \
	python3-pip python3-dev python3-setuptools virtualenv \
	python-pip python-dev python-setuptools \
	software-properties-common redis-server libcups2-dev \
	mysql-client postgresql-client

RUN apt -y install locales

# Nonroot Sudo User
RUN adduser --disabled-password --gecos '' frappe-user
RUN adduser frappe-user sudo
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

USER frappe-user

WORKDIR /home/frappe-user

# Bench Install
#RUN git clone https://github.com/frappe/bench --depth 1
#RUN pip3 install -e ./bench
#RUN sudo cp /home/frappe-user/.local/bin/bench /usr/bin

RUN pip3 install frappe-bench