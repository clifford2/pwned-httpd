# Introduction

Simple docker image to run web service that will search a local copy of
Troy Hunt's [Pwned Passwords](https://haveibeenpwned.com/Passwords),
using `sgrep` in a CGI script.

# How To Use

To use this image, download a copy of Troy Hunt's SHA-1 Pwned Password list,
*ordered by hash*, from <https://haveibeenpwned.com/Passwords>,
and uncompress it.

From the directory containing the `pwned-passwords-sha1-ordered-by-hash-v?.txt`
file, run:

```
docker run --rm -t \
	-v $PWD:/data \
	-p 2080:80 cliffordw/pwned-httpd
```

# URLs

It exposes 3 URLs, namely:

## hash

`/hash/{password}` returns the SHA1 hash of a password.

Example:

```
$ curl http://0.0.0.0:2080/hash/Password
8BE3C943B1609FFFBFC51AAD666D0A04ADF83C9D
```

## pwnedpassword

`/pwnedpassword/{sha1hash}` checks if the password with this hash has been breached.

The HTTP status code indicates whether a match is found. Possible status codes are:

- 400 Bad Request: returned if we can't find the data file, or you don't specify a hash
- 202 OK: we found the hash. Message body contains the count.
- 404 Not found: No match found in breach database

Example 1 - weak password "Password" has 132408 matches:

```
$ curl -v http://0.0.0.0:2080/pwnedpassword/8BE3C943B1609FFFBFC51AAD666D0A04ADF83C9D
*   Trying 0.0.0.0:2080...
* TCP_NODELAY set
* Connected to 0.0.0.0 (127.0.0.1) port 2080 (#0)
> GET /pwnedpassword/8BE3C943B1609FFFBFC51AAD666D0A04ADF83C9D HTTP/1.1
> Host: 0.0.0.0:2080
> User-Agent: curl/7.68.0
> Accept: */*
> 
* Mark bundle as not supporting multiuse
< HTTP/1.1 200 OK
< Content-type: text/plain; charset=utf-8
< Content-Length: 7
< Date: Sun, 16 Aug 2020 14:29:09 GMT
< Server: lighttpd/1.4.55
< 
132408
* Connection #0 to host 0.0.0.0 left intact
```

Example 2 - random password "EffAjcadigucGeys" isn't in the list (note 404 status code):

```
$ curl http://0.0.0.0:2080/hash/EffAjcadigucGeys
76A09C6B1E7DF82E2AC8227F92F4FA7054B8DEE2
$ curl -v http://0.0.0.0:2080/pwnedpassword/76A09C6B1E7DF82E2AC8227F92F4FA7054B8DEE2
*   Trying 0.0.0.0:2080...
* TCP_NODELAY set
* Connected to 0.0.0.0 (127.0.0.1) port 2080 (#0)
> GET /pwnedpassword/76A09C6B1E7DF82E2AC8227F92F4FA7054B8DEE2 HTTP/1.1
> Host: 0.0.0.0:2080
> User-Agent: curl/7.68.0
> Accept: */*
> 
* Mark bundle as not supporting multiuse
< HTTP/1.1 404 Not Found
< Content-type: text/plain; charset=utf-8
< Content-Length: 0
< Date: Sun, 16 Aug 2020 14:30:44 GMT
< Server: lighttpd/1.4.55
< 
* Connection #0 to host 0.0.0.0 left intact
```

## status

Reports on the status of the container, for Docker healthchecks.

# Copyright

This software is based on the following contributions:

- [Alpine Linux](https://alpinelinux.org/)
- [Lighttpd](https://www.lighttpd.net/)
	- [Revised BSD license](http://www.lighttpd.net/assets/COPYING)
- Docker image based on Sébastien Pujadas' [lighttpd Docker image](https://github.com/spujadas/lighttpd-docker)
	- [MIT License](https://github.com/spujadas/lighttpd-docker/blob/master/LICENSE)
- Search script based on Stefan Scherer's CLI [pwned-passwords](https://github.com/StefanScherer/pwned-passwords)
	- [GNU General Public License v3.0](https://github.com/StefanScherer/pwned-passwords/blob/master/LICENSE)
- Uses [sgrep](https://github.com/colinscape/sgrep) to do the search
	- [GNU General Public License v3.0](https://github.com/colinscape/sgrep/blob/master/COPYING)

All content is copyrighted by the original authors.

I dedicate any and all copyright interest in my own
contributions to this software to the public domain.
