FROM debian:jessie
# based on blacktop bro
MAINTAINER danielguerra, https://github.com/danielguerra

#Prevent daemon start during install
RUN echo '#!/bin/sh\nexit 101' > /usr/sbin/policy-rc.d && \
chmod +x /usr/sbin/policy-rc.d

# Install Bro Required Dependencies
RUN \
apt-get -qq update && \
apt-get install -yq libgoogle-perftools-dev \
build-essential \
libcurl4-gnutls-dev \
libgeoip-dev \
libpcap-dev \
libssl-dev \
python-dev \
zlib1g-dev \
php5-curl \
git-core \
sendmail \
bison \
cmake \
flex \
gawk \
make \
swig \
curl \
g++ \
geoip-database \
geoip-database-extra \
tor-geoipdb \
autoconf \
ca-certificates \
ocl-icd-opencl-dev \
libboost-dev \
doxygen \
openssh-server \
pwgen \
gcc --no-install-recommends && \

#Install actor framework caf to enable broker
cd /tmp && \
git clone --recursive git://github.com/actor-framework/actor-framework && \
cd actor-framework && ./configure && make && make install && rm -rf /tmp/actor-framework && \

# Install Bro and remove install dir after to conserve space
cd /tmp && \
git clone --recursive git://git.bro.org/bro && \
cd bro && ./configure --prefix=/nsm/bro --enable-broker && \
make && \
make install && \
cd aux/plugins/elasticsearch && \
./configure && make && make install && rm -rf /tmp/bro && \
  apt-get -y remove \
    build-essential \
    git-core \
    bison \
    cmake \
    flex \
    gawk \
    make \
    swig \
    g++ \
    autoconf \
    doxygen \
    gcc && \
  apt-get -y autoremove && apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

RUN \
apt-get -qq update && \
apt-get install -y openssh-server && \
apt-get clean && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN \
mkdir /var/run/sshd && \
chown root:root /var/run/sshd

ENV PATH /nsm/bro/bin:$PATH

EXPOSE 22 22/tcp
#start sshd
ENTRYPOINT [ "exec","/usr/sbin/sshd", "-D" ]
