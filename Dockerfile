# ------------------------------------------------------------------------------
# Insecure Dockerfile (IaC Misconfiguration Benchmark)
# ------------------------------------------------------------------------------

# Misconfiguration: Using ':latest' tag instead of pinning a specific digest/version
FROM alpine:latest

# Misconfiguration: Exposing insecure remote management port (SSH)
EXPOSE 22

# Misconfiguration: Running as root (no non-root USER instruction provided)
# Misconfiguration: Missing HEALTHCHECK instruction

CMD ["/bin/sh"]
