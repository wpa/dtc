FROM buildpack-deps:jessie

RUN apt-get update
RUN apt-get -y install ant
RUN apt-get -y install openjdk-7-jdk
RUN apt-get -y install libmicrohttpd-dev libjansson-dev libcurl4-gnutls-dev libgnutls28-dev libgcrypt20-dev
RUN mkdir -p /datacollector

COPY ./configure.ac.patch /datacollector

WORKDIR /datacollector

RUN wget https://github.com/apache/zookeeper/archive/release-3.4.7.tar.gz

RUN tar -xzvf release-3.4.7.tar.gz
RUN rm release-3.4.7.tar.gz
RUN cp configure.ac.patch /datacollector/zookeeper-release-3.4.7/src/c
WORKDIR /datacollector/zookeeper-release-3.4.7/src/c
RUN patch -t < configure.ac.patch


WORKDIR /datacollector/zookeeper-release-3.4.7
RUN ant compile_jute
WORKDIR src/c
RUN autoreconf -if
RUN ./configure --prefix=/usr
RUN make install

WORKDIR /datacollector/
RUN rm -rf zookeeper-release-3.4.7




RUN wget https://github.com/edenhill/librdkafka/archive/v0.9.5.tar.gz

RUN tar -xzvf v0.9.5.tar.gz

RUN rm v0.9.5.tar.gz

WORKDIR librdkafka-0.9.5
RUN ./configure --prefix=/usr
RUN make
RUN make install
WORKDIR ..

RUN rm -rf librdkafka-0.9.5

RUN git clone https://github.com/babelouest/ulfius.git
WORKDIR ulfius/
RUN git submodule update --init
RUN make
RUN make install
WORKDIR ..
RUN rm configure.ac.patch
RUN rm -rf ulfius/

RUN apt-get -y remove ant
RUN apt-get -y remove openjdk-7-jdk
RUN apt-get -y autoremove

