# Start first stage
FROM python:3.11-buster AS builder
# Set working directory
WORKDIR /app
# build stage (install and upgrade pip)
RUN pip install --upgrade pip && pip install poetry
# Copy files into the builder stage
COPY pyproject.toml poetry.lock ./
# Build the application using poetry
RUN poetry config virtualenvs.create false && poetry install --no-root --no-interaction --no-ansi

# Start second stage
FROM python:3.11-buster AS app
# Set working directory
WORKDIR /app
# Copy the code from the /app directory in builder stage to the /app stage
COPY --from=builder /usr /usr
COPY --from=builder /app /app
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
# Expose port 8000 for FastAPI to be accessible
EXPOSE 8000
# Entrypoint
ENTRYPOINT ["/entrypoint.sh"]
# Set the CMD parameter to run the FastAPI application
CMD ["uvicorn","cc_compose.server:app","--reload","--host","0.0.0.0","--port","8000"]