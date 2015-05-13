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
libcurl3-dev \
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
gcc --no-install-recommends && \
apt-get clean && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#Install  ipsumdump, changed git ?

RUN \
git clone --recursive https://github.com/kohler/ipsumdump.git && \
cd /ipsumdump && ./configure && \
make && make install && rm -rf /ipsumdump

#Install actor framework caf to enable broker
RUN \
git clone --recursive https://github.com/actor-framework/actor-framework.git && \
cd /actor-framework && ./configure && make && make install && rm -rf /actor-framework

# Install Bro and remove install dir after to conserve space
RUN  \
git clone --recursive git://git.bro.org/bro && \
cd /bro && ./configure --prefix=/nsm/bro --enable-broker && \
make && \
make install && \
cd aux/plugins/elasticsearch && \
./configure && make && make install && \
rm -rf /bro /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV PATH /nsm/bro/bin:$PATH


ENTRYPOINT ["bro"]

CMD ["-h"]
