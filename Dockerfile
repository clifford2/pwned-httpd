# Docker image to run web service that will search a local copy of
# Troy Hunt's [Pwned Passwords](https://haveibeenpwned.com/Passwords).
#
# Build with:
#   podman build --pull -t pwned-httpd .
#
# Based on [Lighttpd docker image](https://github.com/spujadas/lighttpd-docker)
# and Stefan Scherer's CLI [pwned-passwords](https://github.com/StefanScherer/pwned-passwords).
# Uses [sgrep](https://github.com/colinscape/sgrep) to search.

#--------------------------------------------------------------------#                                                              
#-# Stage 1: Build sgrep
FROM docker.io/library/alpine:3.21.0 AS build
ENV LC_ALL=C
RUN apk update && apk add gcc musl-dev && mkdir /src
COPY src/sgrep.c /src/sgrep.c
RUN gcc -o /src/sgrep /src/sgrep.c

#--------------------------------------------------------------------#                                                              
#-# Stage 2: Build final image
FROM docker.io/library/alpine:3.21.0

# Image MAINTAINER
LABEL maintainer="Clifford Weinmann <clifford@weinmann.africa>"

ENV LC_ALL=C
RUN apk update && apk add openssl p7zip \
	lighttpd \
	lighttpd-mod_auth \
	curl \
	&& rm -rf /var/cache/apk/* \
	&& sed -i -e 's/^root::/root:!:/' /etc/shadow
# Last step is to remove null root password if present (CVE-2019-5021)

COPY --from=build --chmod=0755 /src/sgrep /usr/local/bin/sgrep
COPY --chmod=0644 lighttpd-conf/* /etc/lighttpd/
COPY --chmod=0755 bin/entrypoint.sh /usr/local/bin/
COPY --chmod=0755  cgi-bin/* /var/www/localhost/cgi-bin/

EXPOSE 8080
VOLUME /data
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Not supported for OCI image format and will be ignored. Must use `docker` format
# HEALTHCHECK CMD curl --fail http://localhost/status || exit 1
