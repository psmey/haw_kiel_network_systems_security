# Task 5 Docker

Simply up

```bash
docker compose up -d
```

Show logs

```bash
docker compose logs -f
```

Stopping containers cleanly and burn everything down

```bash
docker compose down --volumes
```

Clean start

```bash
docker compose up --detach --force-recreate --remove-orphans
```
