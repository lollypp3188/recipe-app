FROM python:3.11.9-alpine3.20

ENV PYTHONUNBUFFERED=1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app

WORKDIR /app
EXPOSE 8000

ARG DEV=false

# Create a virtual environment
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip

# Install PostgreSQL client
RUN apk add --update --no-cache postgresql-client jpeg-dev zlib-dev

# Install build dependencies
RUN apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev zlib-dev jpeg-dev

# Install Python dependencies
RUN /py/bin/pip install -r /tmp/requirements.txt

# Install development dependencies if in DEV mode
RUN if [ "$DEV" = "true" ]; then /py/bin/pip install -r /tmp/requirements.dev.txt; fi

# Clean up
RUN rm -rf /tmp && \
    apk del .tmp-build-deps

# Add a new user
RUN adduser \
    --disabled-password \
    --no-create-home \
    django-user && \
    mkdir -p /vol/web/media && \
    mkdir -p /vol/web/static && \
    chown -R django-user:django-user /vol && \
    chmod -R 755 /vol

ENV PATH="/py/bin:$PATH"

USER django-user
