FROM debian:wheezy

MAINTAINER blacktop, https://github.com/blacktop

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
gcc --no-install-recommends && \
apt-get clean && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install the GeoIPLite Database
ADD /geoip /usr/share/GeoIP/
RUN \
gunzip /usr/share/GeoIP/GeoLiteCityv6.dat.gz && \
gunzip /usr/share/GeoIP/GeoLiteCity.dat.gz && \
rm -f /usr/share/GeoIP/GeoLiteCityv6.dat.gz && \
rm -f /usr/share/GeoIP/GeoLiteCity.dat.gz && \
ln -s /usr/share/GeoIP/GeoLiteCityv6.dat /usr/share/GeoIP/GeoIPCityv6.dat && \
ln -s /usr/share/GeoIP/GeoLiteCity.dat /usr/share/GeoIP/GeoIPCity.dat

# ipsumdump
WORKDIR /tmp
RUN git clone --recursive https://github.com/kohler/ipsumdump.git
WORKDIR /tmp/ipsumdump
RUN ./configure
RUN make
RUN make install

#actor framework caf to enable broker
WORKDIR /tmp
RUN git clone --recursive https://github.com/actor-framework/actor-framework.git
WORKDIR /tmp/actor-framework
RUN ./configure
RUN make
RUN make install

WORKDIR /tmp
# Install Bro and remove install dir after to conserve space
RUN  \
git clone --recursive git://git.bro.org/bro && \
cd bro && ./configure --prefix=/nsm/bro --enable-broker && \
make && \
make install && \
cd aux\plugins\elasticsearch && \
./configure && make && make install && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV PATH /nsm/bro/bin:$PATH


ENTRYPOINT ["bro"]

CMD ["-h"]
