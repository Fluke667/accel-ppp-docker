FROM debian:stretch-slim

ENV LINUX_HEADERS_VERSION 4.9.0-9

RUN set -x \
    && apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y curl wget ca-certificates git sudo linux-headers-4.9.0-9-amd64 nano build-essential kmod apt-utils gcc g++ make cmake pkg-config libnl-3-dev libnl-utils libssl-dev libpcre3-dev libsnmp-dev libnet-snmp-perl libtritonus-bin lua5.1 liblua5.1-0-dev snmp libhiredis-dev libjson-c-dev ppp pppoe 

RUN set -x \
    && build_dir="/opt/accel-ppp" \
    && mkdir "$build_dir" \
    && cd "$build_dir" \
    && git clone https://github.com/xebd/accel-ppp.git . \
    && mkdir "$build_dir/build" \
    && cd "build" \
    && cmake -DRADIUS=TRUE -DNETSNMP=TRUE -DLUA=TRUE -DBUILD_IPOE_DRIVER=TRUE -DBUILD_VLAN_MON_DRIVER=TRUE -DCMAKE_INSTALL_PREFIX=/usr -DKDIR=/usr/src/linux-headers-4.9.0-9-amd64 -DCPACK_TYPE=Debian9 .. \
    && make \
    && cpack -G DEB \
    && dpkg -i accel-ppp.deb \
#    && modprobe vlan_mon ipoe pptp \
    && echo "username * password *" > /etc/ppp/chap-secrets
    && echo "username * password *" > /etc/ppp/pap-secrets
    && echo "1" > /proc/sys/net/ipv4/ip_forward # same as sysctl -w net.ipv4.ip_forward=1 command
    && echo "1" > /proc/sys/net/ipv4/ip_dynaddr # same as sysctl -w net.ipv4.ip_dynaddr=1 command

COPY accel-ppp.conf /etc/

EXPOSE 2000-2001/tcp

# RUN set -x \
#     && service accel-ppp start
