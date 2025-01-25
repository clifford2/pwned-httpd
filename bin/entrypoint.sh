#!/bin/sh

# SPDX-FileCopyrightText: © 2019 Clifford Weinmann <https://www.cliffordweinmann.com/>
#
# SPDX-License-Identifier: Unlicense

# This launcher script tails the lighttpd access and error logs
# to the stdout and stderr, so that `podman logs -f pwned-httpd` works.

DATADIR=${DATADIR:-/data}
echo "DATADIR = [${DATADIR}]"
echo "SHA1_FILENAME = [${SHA1_FILENAME}]"
echo "NTLM_FILENAME = [${NTLM_FILENAME}]"

# Validate setup
if [ ! -d "${DATADIR}" ]; then
	echo "Error: Please run this container with the password hash directory mounted at ${DATADIR}."
	# echo "podman run --rm -v \$(pwd):${DATADIR} pwned-httpd"
	exit 1
fi

cd "${DATADIR}"
if [ $? -ne 0 ]
then
	echo "Error: Could not access ${DATADIR}"
	exit 1
fi

# Link single files to known names for CGI scripts to find
if [ ! -z "${SHA1_FILENAME}" -a -f "${SHA1_FILENAME}" ]
then
	ln -s "${DATADIR}/${SHA1_FILENAME}" /tmp/.hibp.sha1.txt
	echo "Found ${SHA1_FILENAME}:"
	ls -l /tmp/.hibp.sha1.txt
fi
if [ ! -z "${NTLM_FILENAME}" -a -f "${NTLM_FILENAME}" ]
then
	ln -s "${DATADIR}/${NTLM_FILENAME}" /tmp/.hibp.ntlm.txt
	echo "Found ${NTLM_FILENAME}:"
	ls -l /tmp/.hibp.ntlm.txt
fi

# Validate that we have data to work with
if [ ! -e /tmp/.hibp.sha1.txt -a ! -e /tmp/.hibp.ntlm.txt ]
then
	if [ ! -d "${DATADIR}/sha1" -a ! -d "${DATADIR}/ntlm" ]
	then
		echo 'Error: please provide one of:'
		echo '  $SHA1_FILENAME pointing to a single SHA1 hash list'
		echo '  $NTLM_FILENAME pointing to a single NTLM hash list'
		echo "  A directory containing individual SHA1 hash files, mounted into ${DATADIR}/sha1"
		echo "  A directory containing individual NTLM hash files, mounted into ${DATADIR}/ntlm"
		exit 1
	fi
fi

tail -F /var/log/lighttpd/access.log 2>/dev/null &
tail -F /var/log/lighttpd/error.log 2>/dev/null 1>&2 &
exec lighttpd -D -f /etc/lighttpd/lighttpd.conf
