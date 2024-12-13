#!/bin/sh

# This launcher script tails the lighttpd access and error logs
# to the stdout and stderr, so that `podman logs -f pwned-httpd` works.

DATADIR=${DATADIR:-/data}
echo "DATADIR = [${DATADIR}]"
echo "FILENAME = [${FILENAME}]"

# Validate setup
if [ ! -d "${DATADIR}" ]; then
	echo "Please run this container with the password hash directory mounted at ${DATADIR}."
	# echo "podman run --rm -v \$(pwd):${DATADIR} pwned-httpd"
	exit 1
fi

cd "${DATADIR}"
if [ $? -ne 0 ]
then
	echo "Could not access ${DATADIR}"
	exit 1
fi

# Link single file in $FILENAME to known name for CGI script to find
if [ ! -z "${FILENAME}" -a -f "${FILENAME}" ]
then
	ln -s "${DATADIR}/${FILENAME}" /tmp/.hibp.single.txt
	echo "Found ${FILENAME}:"
	ls -l /tmp/.hibp.single.txt
fi

tail -F /var/log/lighttpd/access.log 2>/dev/null &
tail -F /var/log/lighttpd/error.log 2>/dev/null 1>&2 &
exec lighttpd -D -f /etc/lighttpd/lighttpd.conf
