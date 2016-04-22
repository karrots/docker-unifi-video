FROM debian
MAINTAINER Jonathan Karras <jkarras@karras.net>

ENV UNIFI_VERSION 3.2.2
ENV DEBIAN_FRONTEND noninteractive


RUN apt-get update \
	&& apt-get -y dist-upgrade \
	&& apt-get -y install \
        binutils \
        gdebi \
        jsvc \
        libtcnative-1 \
        mongodb-server \
        openjdk-7-jre-headless \
        wget
	&& apt-get -y clean

RUN cd /tmp \
	&& wget "http://dl.ubnt.com/firmwares/unifi-video/${UNIFI_VERSION}/unifi-video_${UNIFI_VERSION}~Debian7_amd64.deb" \
	&& gdebi --n unifi-video_${UNIFI_VERSION}~Debian7_amd64.deb \
	&& rm -rf /var/lib/unifi-video/*
    && rm -rf unifi-video_${UNIFI_VERSION}~Debian7_amd64.deb

# The following ports are used on UniFi Video hosts:

# 1935 – RTMP streaming video to web UI & accepting gen1 camera video
# 1935, by user (RTMP video)

# 7443 – Controller web UI
# 7443, by user (HTTPS), by camera (HTTPS)

# 7080 – HTTP communication with cameras
# 7080, by user (HTTP), by camera (HTTP)

# 6666 – Live FLV for incoming gen2 camera streams
# 6666, by camera (video push)

# 7447 – RTSP re-streaming via controller

# The following ports are used on cameras:

# HTTP/HTTPS ports to access web interface (optional)
# SSH to facilitate adoption by the controller on LAN (optional)
# 554 RTSP server (mandatory only on gen1)


EXPOSE  7447 7446 1935 7443 7080 6666 80 443

VOLUME /var/lib/unifi-video
VOLUME /var/log/unifi-video

WORKDIR /var/lib/unifi-video

CMD ["java", "-cp", "/usr/share/java/commons-daemon.jar:/usr/lib/unifi-video/lib/airvision.jar", "-Dav.tempdir=/var/cache/unifi-video", "-Djava.security.egd=file:/dev/./urandom", "-Djava.awt.headless=true", "-Dfile.encoding=UTF-8", "-Xmx1024M", "com.ubnt.airvision.Main", "start"]
