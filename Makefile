# SPDX-FileCopyrightText: © 2026 Clifford Weinmann <https://www.cliffordweinmann.com/>
# SPDX-License-Identifier: MIT

# Use podman or docker?
ifeq ($(shell command -v podman 2> /dev/null),)
    CONTAINER_ENGINE := docker
else
    CONTAINER_ENGINE := podman
endif

.PHONY: all
all:
	$(CONTAINER_ENGINE) build -t pwned-httpd:beta .
	cd test && CONTAINER_ENGINE=$(CONTAINER_ENGINE) IMAGE=pwned-httpd:beta bash ./run-tests.sh
	$(CONTAINER_ENGINE) tag pwned-httpd:beta pwned-httpd:latest
	$(CONTAINER_ENGINE) rmi pwned-httpd:beta
