# cccaddy

Caddy with the Cloudflare DNS and CrowdSec bouncer modules.

```sh
docker pull ghcr.io/tiagovla/cccaddy:latest
```

Images are rebuilt automatically when Caddy or either plugin gets a new stable version.

## Example

Set `CROWDSEC_API_KEY` and `CLOUDFLARE_API_TOKEN` in the container environment:

```Caddyfile
{
	order crowdsec first
	crowdsec {
		api_url http://crowdsec:8080
		api_key {$CROWDSEC_API_KEY}
	}
}

example.com {
	log {
		output file /var/log/caddy/access.log
	}
	tls {
		dns cloudflare {env.CLOUDFLARE_API_TOKEN}
	}
	crowdsec
	reverse_proxy example:80
}
```

## Docker Compose

Create a private `.env` file beside `compose.yaml` with `CLOUDFLARE_API_TOKEN` and `CROWDSEC_API_KEY`. Register the CrowdSec key as a bouncer key. Replace `example:80` with a service on the same Compose network.

```yaml
services:
  crowdsec:
    image: crowdsecurity/crowdsec:latest
    environment:
      COLLECTIONS: crowdsecurity/caddy
    volumes:
      - ./crowdsec/config:/etc/crowdsec
      - crowdsec_data:/var/lib/crowdsec/data
      - caddy_logs:/var/log/caddy:ro
    healthcheck:
      test: ["CMD", "cscli", "lapi", "status"]
      interval: 10s
      timeout: 5s
      retries: 10
      start_period: 10s

  caddy:
    image: ghcr.io/tiagovla/cccaddy:latest
    depends_on:
      crowdsec:
        condition: service_healthy
    environment:
      CLOUDFLARE_API_TOKEN: ${CLOUDFLARE_API_TOKEN:?required}
      CROWDSEC_API_KEY: ${CROWDSEC_API_KEY:?required}
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - data:/data
      - config:/config
      - caddy_logs:/var/log/caddy

volumes:
  data:
  config:
  crowdsec_data:
  caddy_logs:
```
