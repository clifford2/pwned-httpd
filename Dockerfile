# Docker image to run web service that will search a local copy of
# Troy Hunt's [Pwned Passwords](https://haveibeenpwned.com/Passwords).
#
# Build with:
#   docker build --pull -t cliffordw/pwned-httpd .
#
# Based on [Lighttpd docker image](https://github.com/spujadas/lighttpd-docker)
# and Stefan Scherer's CLI [pwned-passwords](https://github.com/StefanScherer/pwned-passwords).
# Uses [sgrep](https://github.com/colinscape/sgrep) to search.

#--------------------------------------------------------------------#                                                              
#-# Stage 1: Build sgrep
FROM docker.io/alpine:3.12.3 AS build
RUN apk update && apk add git make gcc musl-dev
RUN git clone https://github.com/colinscape/sgrep
RUN mkdir sgrep/bin && cd sgrep/src && make

#--------------------------------------------------------------------#                                                              
#-# Stage 2: Build final image
FROM docker.io/alpine:3.12.3

# Image MAINTAINER
LABEL maintainer="Clifford Weinmann <clifford@weinmann.co.za>"
# How to run this image
## label-schema.org format
LABEL org.label-schema.docker.cmd="docker run -d --rm -p 8080:80 -v $PWD:/data cliffordw/pwned-httpd"
## `atomic run` format
LABEL RUN="docker run -d --rm -v $PWD:/data cliffordw/pwned-httpd"
# label-schema.org labels
LABEL org.label-schema.vendor="Clifford Weinmann" \
  org.label-schema.name="Have I Been Pwned Password Lookup" \
  org.label-schema.docker.schema-version="1.0"

RUN apk update && apk add openssl p7zip \
	lighttpd \
	lighttpd-mod_auth \
	curl \
	&& rm -rf /var/cache/apk/* \
	&& sed -i -e 's/^root::/root:!:/' /etc/shadow
# Last step is to remove null root password if present (CVE-2019-5021)

## workaround for bug preventing sync between VirtualBox and host
# http://serverfault.com/questions/240038/lighttpd-broken-when-serving-from-virtualbox-shared-folder
RUN echo 'server.network-backend = "writev"' >> /etc/lighttpd/lighttpd.conf

COPY --from=build /sgrep/bin/sgrep /usr/local/bin/sgrep

COPY lighttpd-conf/* /etc/lighttpd/
COPY bin/start.sh /usr/local/bin/
COPY cgi-bin/* /var/www/localhost/cgi-bin/

EXPOSE 80

VOLUME /data

ENTRYPOINT ["/usr/local/bin/start.sh"]

HEALTHCHECK CMD curl --fail http://localhost/status || exit 1
