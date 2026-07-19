# Use Python 3.11 slim image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install uv for faster dependency management
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Copy project files
COPY pyproject.toml uv.lock README.md ./
COPY src ./src
COPY data ./data
COPY .env.example .env.example

# Install dependencies (EXTRAS: comma-separated optional groups, e.g. "trafilatura,twitter")
ARG EXTRAS=""
RUN uv sync --frozen --no-dev \
    $([ -n "$EXTRAS" ] && echo "$EXTRAS" | tr ',' '\n' | sed 's/^/--extra /' | tr '\n' ' ')

# Runtime data is mounted here; keep the image and process unprivileged.
RUN useradd --create-home --uid 10001 horizon \
    && chown -R horizon:horizon /app

# Create volume mount points
VOLUME ["/app/data"]

# Set environment variables
ENV PYTHONUNBUFFERED=1
USER horizon

# Run the application
ENTRYPOINT ["uv", "run", "horizon"]
CMD []
