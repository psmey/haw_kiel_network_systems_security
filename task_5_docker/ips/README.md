# Docker Security

Start docker compose cleanly inside the dir for the docker compose.

```bash
 docker compose up -d --force-recreate --remove-orphans
```

## Firewall

Docker compose has its own firewall, so through exposed ports this is already given

## Intrusion Prevention System (IPS)

Test connection <https://doc.crowdsec.net/u/getting_started/health_check/>

Create coonection event:

```bash
curl -I http://localhost:8080/crowdsec-test-NtktlJHV4TfBSK3wvlhiOBnl
```

Check for alert event

```bash
docker exec ips-crowdsec-1 cscli alerts list -s crowdsecurity/http-generic-test
```

Show monitoring

```bash
docker exec container-socket-crowdsec-1 cscli metrics show acquisition parsers
```

## Web Application Firewall (WAF)

Test normal request

```bash
curl localhost:8080
```

Test the WAF blocking a potential harmful request

```bash
curl -v 'localhost:8080/?q=<script>alert(1)</script>'
```
