---
name: docker-dev-compose
description: Guidelines to create a docker compose for local development
---

Si se pide un docker compose es para desarrollo, entonces:

- Verifica primero si el servicio ya está corriendo con `docker ps`.
- Si el puerto está ocupado por otro servicio, cambia al siguiente puerto disponible.
- No es necesario usar volumes.
- Usa siempre la imagen `latest` del servicio.
