ARG CADDY_VERSION=2.11.7
ARG CLOUDFLARE_VERSION=v0.2.4
ARG CROWDSEC_VERSION=v0.14.1

FROM caddy:${CADDY_VERSION}-builder AS builder

ARG CLOUDFLARE_VERSION
ARG CROWDSEC_VERSION

RUN xcaddy build \
    --with github.com/caddy-dns/cloudflare@${CLOUDFLARE_VERSION} \
    --with github.com/hslatman/caddy-crowdsec-bouncer@${CROWDSEC_VERSION}

FROM caddy:${CADDY_VERSION}

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
