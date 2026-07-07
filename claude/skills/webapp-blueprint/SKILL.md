---
name: webapp-blueprint
description: Blueprint and guidelines for building web applications (auth, user management, landing pages, ui, basic features and so on)
---

# General Considerations

- Zod para validación (backend y frontend).
- Para email transaccional usar Resend.
- Para subir archivos usar Digitalocean Spaces.
- Dashboard y landing soportan tema claro/oscuro.

# Auth considerations

Las páginas de auth deben estar conformadas por:

- Login con email/password.
- Página de forgot-password.
- Página de reset-password.

# Dashboard considerations

- Crear un command palette para navegar entre todas las páginas.
- Crear una página de perfil donde el usuario pueda:
    - Actualizar su información.
    - Cambiar la contraseña.
    - Cambiar avatar (si la plataforma soporta subir archivos).

# Single Dashboard Page

- Toda página CRUD del dashboard debe estar conformada por:
    - Una página con tabla y un botón que redirige a la página de creación, con:
      - Búsqueda.
      - Filtro por columna.
      - Paginación.
      - La columna de email debe tener un ícono de papel para copiar el email al portapapeles.
    - La página de creación tiene un formulario, reusable para crear y editar.

Página de administración (tabla CRUD con búsqueda, filtros por columna, paginación, y copiar-email-al-portapapeles). Pregunta qué plataformas usar antes de empezar.

## API

- Validar los endpoints de la API con Zod.
- Usar principios de diseño REST para crear las URLs.
