# HIBP Web Service

## Introduction

The NIST's Digital Identity Guidelines requires passwords to be compared to passwords obtained from previous breaches.
The best way to do that is with Troy Hunt's [Have I Been Pwned](https://haveibeenpwned.com/)
service, which offers an [online password search](https://haveibeenpwned.com/Passwords)
as well as an [API](https://haveibeenpwned.com/API/v3).

The code in this repository offers a simple container image to run web service
that will search a local copy of the HIBP password hashes.
It predates the online HIBP API, which is the best way to search for breached
passwords, but this may still be useful to anyone that prefers a local service.

## How To Use

### Downloading the Pwned Passwords list

To use this image, you need a downloaded copy of Troy's Pwned Password list
from <https://haveibeenpwned.com/Passwords>. This contains ordered lists
of SHA-1 or NTLM hashes and a count of occurences for breached passwords.

As of May 2022, the best way to get the most up to date passwords is to use
[the Pwned Passwords downloader](https://github.com/HaveIBeenPwned/PwnedPasswordsDownloader).
You can download this as a single file or as smaller individual `.txt` files.

### Running the container image

You can provide either SHA-1 or NTLM hashes, or both. Obviously only the
functions for which you provide data will work ;-)

If using the individual hash `.txt` files, you need to mount the directory
containing the files to `/data/sha1` and/or `/data/ntlm` in the container.
Assuming you're in a directory containing a `sha1` and/or `ntlm` subdirectory,
you can run:

```sh
podman run --rm -t \
	-v $PWD:/data \
	-p 2080:8080 \
	pwned-httpd
```

If you downloaded the hashes into a single file, you also need to provide
the file name in the `$FILENAME` environment variable, for example:

```sh
podman run --rm -t \
	-v $PWD:/data \
	-p 2080:8080 \
	-e SHA1_FILENAME=sha1.txt \
	-e NTLM_FILENAME=ntlm.txt \
	pwned-httpd
```

## Exposed URLs

It exposes 3 URLs, namely:

### `/sha1hash`

`/sha1hash/{password}` returns the SHA1 hash of a password.

Example:

```
$ curl http://0.0.0.0:2080/sha1hash/abcde
03DE6C570BFE24BFC328CCD7CA46B76EADAF4334
```

This is for convenience / testing only. It would be safer to do this offline :-)
Many options exist for doing this. One example is this Python snippet:

```sh
python -c 'import hashlib; print(hashlib.sha1("Password".encode()).hexdigest());'
```

### `/pwnedsha1`

`/pwnedsha1/{sha1hash}` checks if the password with this SHA1 hash has been breached.

The HTTP status code indicates whether a match is found. Possible status codes are:

- 400 Bad Request: returned if we can't find the data file, or you don't specify a hash
- 202 OK: we found the hash - the response body contains the match count
- 404 Not found: No match found in breach database

Example 1 - weak password "abcde" has 51725 matches:

```
$ curl -v http://0.0.0.0:2080/pwnedsha1/03DE6C570BFE24BFC328CCD7CA46B76EADAF4334
*   Trying 0.0.0.0:2080...
* Connected to 0.0.0.0 (127.0.0.1) port 2080
> GET /pwnedsha1/03DE6C570BFE24BFC328CCD7CA46B76EADAF4334 HTTP/1.1
> Host: 0.0.0.0:2080
> User-Agent: curl/8.5.0
> Accept: */*
> 
< HTTP/1.1 200 OK
< Content-type: text/plain; charset=utf-8
< Accept-Ranges: bytes
< Content-Length: 6
< Date: Fri, 13 Dec 2024 09:40:19 GMT
< Server: lighttpd/1.4.76
< 
51725
* Connection #0 to host 0.0.0.0 left intact
```

Example 2 - random password "EffAjcadigucGeys" isn't in the list (note 404 status code):

```
$ curl http://0.0.0.0:2080/sha1hash/EffAjcadigucGeys
76A09C6B1E7DF82E2AC8227F92F4FA7054B8DEE2
$ curl -v http://0.0.0.0:2080/pwnedsha1/76A09C6B1E7DF82E2AC8227F92F4FA7054B8DEE2
*   Trying 0.0.0.0:2080...
* TCP_NODELAY set
* Connected to 0.0.0.0 (127.0.0.1) port 2080 (#0)
> GET /pwnedsha1/76A09C6B1E7DF82E2AC8227F92F4FA7054B8DEE2 HTTP/1.1
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

### `/pwnedntlm`

`/pwnedntlm/{ntlmhash}` checks if the password with this NTLM hash has been breached.

The HTTP status code indicates whether a match is found. Possible status codes are:

- 400 Bad Request: returned if we can't find the data file, or you don't specify a hash
- 202 OK: we found the hash - the response body contains the match count
- 404 Not found: No match found in breach database

### `/healthz`

Reports on the status of the container, for healthchecks.

## Copyright

This software is based on the following contributions:

- [Alpine Linux](https://alpinelinux.org/)
- [Lighttpd](https://www.lighttpd.net/)
	- [Revised BSD license](http://www.lighttpd.net/assets/COPYING)
- Docker image based on Sébastien Pujadas' [lighttpd Docker image](https://github.com/spujadas/lighttpd-docker)
	- [MIT License](https://github.com/spujadas/lighttpd-docker/blob/master/LICENSE)
- Search script based on Stefan Scherer's CLI [pwned-passwords](https://github.com/StefanScherer/pwned-passwords)
	- [GNU General Public License v3.0](https://github.com/StefanScherer/pwned-passwords/blob/master/LICENSE)
- Uses [sgrep](https://sourceforge.net/projects/sgrep/) to do the search
	- [GNU General Public License v3.0](https://github.com/colinscape/sgrep/blob/master/COPYING)

All content is copyrighted by the original authors.

I dedicate any and all copyright interest in my own
contributions to this software to the public domain.
