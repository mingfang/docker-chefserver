FROM ubuntu
 
RUN echo 'deb http://archive.ubuntu.com/ubuntu precise main universe' > /etc/apt/sources.list && \
    echo 'deb http://archive.ubuntu.com/ubuntu precise-updates universe' >> /etc/apt/sources.list && \
    apt-get update

#Supervisord
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y supervisor && mkdir -p /var/log/supervisor
CMD ["/usr/bin/supervisord", "-n"]

#SSHD
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server &&	mkdir /var/run/sshd && \
	echo 'root:root' |chpasswd

#Utilities
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y vim less net-tools inetutils-ping curl git telnet nmap socat dnsutils netcat tree htop unzip sudo

#Chef Server
RUN wget https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/chef-server_11.0.11-1.ubuntu.12.04_amd64.deb && \ 
    dpkg -i chef-server*.deb && \
    rm chef-server*.deb

#Docker client only
RUN wget -O /usr/local/bin/docker https://get.docker.io/builds/Linux/x86_64/docker-latest && \
    chmod +x /usr/local/bin/docker

RUN mkdir -p /etc/chef-server &&  \
    echo "nginx['enable_non_ssl']=true" >> /etc/chef-server/chef-server.rb
RUN sysctl -w kernel.shmall=4194304 && \
    sysctl -w kernel.shmmax=17179869184 && \
    /opt/chef-server/embedded/bin/runsvdir-start & \
    chef-server-ctl reconfigure

#Configuration
ADD . /docker
RUN ln -s /docker/supervisord-ssh.conf /etc/supervisor/conf.d/supervisord-ssh.conf

EXPOSE 22
