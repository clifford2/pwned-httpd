# Introduction

Docker image to run web service that will search a local copy of
Troy Hunt's [Pwned Passwords](https://haveibeenpwned.com/Passwords).

# How To Use

To use this image, download a copy of version 3 of Troy Hunt's SHA-1 Pwned
Password list, ordered by hash, from <https://haveibeenpwned.com/Passwords>,
and uncompress it.

From the directory containing the `pwned-passwords-v3-ordered-by-hash.txt`
file, run:

```
docker run --rm -t \
	-v $PWD:/data \
	-p 2080:80 pwned-httpd
```

# URLs

It exposes 3 URLs, namely:

## hash

`/hash/{password}` returns the SHA1 hash of a password.

## pwnedpassword

`/pwnedpassword/{sha1hash}` checks if the password with this hash has been breached.

The HTTP status code indicates whether a match is found. Possible status codes are:

- 400 Bad Request: returned if we can't find the data file, or you don't specify a hash
- 202 OK: we found the hash. Message body contains the count.
- 404 Not found: No match found in breach database

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
