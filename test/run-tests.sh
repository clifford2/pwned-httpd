#!/usr/bin/env bash
# Test the container image with some sample hashes

# Start the container
chmod 0755 .
chmod -R a+rX sha1 ntlm
podman run --rm -d --replace \
	-v "${PWD}:/data:ro,Z" \
	-p 2080:8080 \
	--name pwned-httpd \
	pwned-httpd

testcnt=0
errcnt=0

hash=$(curl --silent http://0.0.0.0:2080/sha1hash/abcde)
(( testcnt = testcnt + 1 ))
if [ "$hash" = "03DE6C570BFE24BFC328CCD7CA46B76EADAF4334" ]
then
	res='OK'
else
	res='ERROR'
	(( errcnt = errcnt + 1 ))
fi
echo "Test $testcnt: SHA1 hash calc: $res"

hashcnt=$(curl --silent http://0.0.0.0:2080/pwnedsha1/03DE6C570BFE24BFC328CCD7CA46B76EADAF4334)
(( testcnt = testcnt + 1 ))
if [ ! -z "$hashcnt" -a $hashcnt -gt 0 ]
then
	res='OK'
else
	res='ERROR'
	(( errcnt = errcnt + 1 ))
fi
echo "Test $testcnt: positive SHA1 hash lookup: $res"

httpstatus=$(curl --silent --include http://0.0.0.0:2080/pwnedsha1/03DE6C570BFE24BFC328CCD7CA46B76EADAF4335 | awk '/^HTTP/ {print $2}')
(( testcnt = testcnt + 1 ))
if [ "$httpstatus" = "404" ]
then
	res='OK'
else
	res='ERROR'
	(( errcnt = errcnt + 1 ))
fi
echo "Test $testcnt: negative SHA1 hash lookup: $res"

hashcnt=$(curl --silent http://0.0.0.0:2080/pwnedntlm/00001017667987ADC75481DCCC94E24A)
(( testcnt = testcnt + 1 ))
if [ ! -z "$hashcnt" -a $hashcnt -gt 0 ]
then
	res='OK'
else
	res='ERROR'
	(( errcnt = errcnt + 1 ))
fi
echo "Test $testcnt: positive NTLM hash lookup: $res"

httpstatus=$(curl --silent --include http://0.0.0.0:2080/pwnedntlm/00001017667987ADC75481DCCC94E24B | awk '/^HTTP/ {print $2}')
(( testcnt = testcnt + 1 ))
if [ "$httpstatus" = "404" ]
then
	res='OK'
else
	res='ERROR'
	(( errcnt = errcnt + 1 ))
fi
echo "Test $testcnt: negative NTLM hash lookup: $res"

# Stop the container
podman stop pwned-httpd

# Feedback
if [ $errcnt -gt 0 ]
then
	echo "$errcnt out of $testcnt tests failed"
	exit 1
else
	echo "All $testcnt tests passed"
	exit 0
fi
