FROM python:3.11.9-alpine3.20

ENV PYTHONUNBUFFERED=1

# Copy necessary files
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
COPY ./scripts /scripts

# Set the working directory
WORKDIR /app

# Expose the application port
EXPOSE 8000

# Argument to toggle development mode
ARG DEV=false

# Create a virtual environment and upgrade pip
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip

# Install system dependencies
RUN apk add --update --no-cache postgresql-client jpeg-dev zlib-dev

# Install build dependencies, including linux-headers
RUN apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev zlib-dev jpeg-dev linux-headers

# Install Python dependencies
RUN /py/bin/pip install -r /tmp/requirements.txt

# Install development dependencies if in DEV mode
RUN if [ "$DEV" = "true" ]; then /py/bin/pip install -r /tmp/requirements.dev.txt; fi

# Clean up temporary files and dependencies
RUN rm -rf /tmp && \
    apk del .tmp-build-deps

# Add a new user and set up directories
RUN adduser \
    --disabled-password \
    --no-create-home \
    django-user && \
    mkdir -p /vol/web/media /vol/web/static && \
    chown -R django-user:django-user /vol && \
    chmod -R 755 /vol && \
    chmod -R +x /scripts

# Set the virtual environment's path
ENV PATH="/scripts:/py/bin:$PATH"

# Switch to non-root user
USER django-user

CMD ["run.sh"]
