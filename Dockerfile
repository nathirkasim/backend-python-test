# syntax=docker/dockerfile:1
# ------------------------------------------------------------------------------
# PHP2Shell Vulnerability Detection Test Dockerfile
#
# PURPOSE:
# Builds a minimal, harmless PHP runtime container to validate security scanners
# against CVE-2026-109618 and CVE-2026-109619.
#
# CONFIGURATION:
# Default: PHP 8.3.35 (Vulnerable runtime test case)
# Switchable via build-arg: PHP_VERSION=8.3.36-cli-alpine (Patched control case)
# ------------------------------------------------------------------------------

ARG PHP_VERSION=8.3.35-cli-alpine

FROM php:${PHP_VERSION}

LABEL maintainer="Security Testing Team" \
      org.opencontainers.image.title="php2shell-security-test" \
      org.opencontainers.image.description="Defensive security test image for CVE-2026-109618 and CVE-2026-109619" \
      org.opencontainers.image.source="https://github.com/nathirkasim/backend-python-test" \
      org.opencontainers.image.vendor="Datadog Security Labs Advisory Reference Test"

# Set a non-root app directory
WORKDIR /var/www/html

# Copy repository metadata and application code
COPY composer.json /var/www/html/composer.json
COPY src/ /var/www/html/src/

# Run as non-privileged user (nobody / www-data) where supported
USER nobody

# Expose non-privileged HTTP port
EXPOSE 8080

# Execute minimal built-in web server serving harmless status endpoint
CMD ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/html/src"]
