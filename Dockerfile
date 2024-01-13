# Use Debian as the base image
FROM debian:bookworm-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    libdbd-pg-perl \
    libtemplate-perl \
    libdatetime-perl \
    libdbi-perl \
    libtext-csv-xs-perl \
    cpanminus \
    starman \
    # Add other necessary packages here
    && rm -rf /var/lib/apt/lists/*

# Set environment variables for PostgreSQL (to be provided by Railway)
ARG PGHOST
ARG PGPORT
ARG PGDATABASE
ARG PGUSER
ARG PGPASSWORD

ENV POSTGRES_HOST=$PGHOST
ENV POSTGRES_PORT=$PGPORT
ENV POSTGRES_DATABASE=$PGDATABASE
ENV POSTGRES_USER=$PGUSER
ENV POSTGRES_PASSWORD=$PGPASSWORD

# Download and setup LedgerSMB
ARG LSMB_VERSION="1.11.7"
ARG ARTIFACT_LOCATION="https://download.ledgersmb.org/f/Releases/$LSMB_VERSION/ledgersmb-$LSMB_VERSION.tar.gz"

RUN wget -O /tmp/ledgersmb.tar.gz "$ARTIFACT_LOCATION" \
    && tar -xzf /tmp/ledgersmb.tar.gz -C /opt \
    && rm /tmp/ledgersmb.tar.gz

WORKDIR /opt/ledgersmb

# Install Perl dependencies
RUN cpanm --installdeps .

# Copy your start script into the container
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Expose the port that LedgerSMB will run on
EXPOSE 5762

# Set the user and start command
USER www-data
CMD ["start.sh"]
