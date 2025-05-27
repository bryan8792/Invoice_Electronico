# Imagen base ligera con Python 3.11
FROM python:3.11-slim

# Configuraciones globales para Python y APT
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    DEBIAN_FRONTEND=noninteractive \
    POETRY_NO_INTERACTION=1

# Establecer directorio de trabajo
WORKDIR /app

# -----------------------------
# 1. Instalación de dependencias del sistema
# -----------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    netcat-openbsd \
    curl \
    gcc \
    build-essential \
    python3-dev \
    libffi-dev \
    libssl-dev \
    libjpeg-dev \
    zlib1g-dev \
    libpng-dev \
    libfreetype6-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libxml2-dev \
    libxslt1-dev \
    postgresql-client \
    && apt-get purge -y --auto-remove \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------
# 2. Instalación de dependencias Python
# -----------------------------
COPY requirements/ ./requirements/
RUN python -m pip install --upgrade pip \
    && pip install --no-cache-dir -r requirements/base.txt

# -----------------------------
# 3. Copiar la aplicación
# -----------------------------
COPY . .

# -----------------------------
# 4. Crear usuario sin privilegios
# -----------------------------
RUN adduser --disabled-password --gecos "" appuser \
    && chown -R appuser:appuser /app
USER appuser

# -----------------------------
# 5. Configuración final
# -----------------------------
ENV DJANGO_SETTINGS_MODULE=miapp.settings \
    PYTHONPATH=/app

EXPOSE 8000

# CMD por defecto (puede ser sobrescrito en docker-compose)
CMD ["gunicorn", "miapp.wsgi:application", "--bind", "0.0.0.0:8000"]

# Healthcheck para la aplicación web (opcional)
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/ || exit 1
