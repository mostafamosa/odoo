# Use Debian as the base image
FROM debian:bookworm-slim

# Set environment variables for the LedgerSMB version and download URL
ARG LSMB_VERSION="1.11.7"
ARG LSMB_DL_DIR="Releases"
ARG ARTIFACT_LOCATION="https://download.ledgersmb.org/f/$LSMB_DL_DIR/$LSMB_VERSION/ledgersmb-$LSMB_VERSION.tar.gz"

# Install required packages
RUN apt-get update && apt-get install -y \
    wget \
    libdbd-pg-perl \
    libtemplate-perl \
    libdatetime-perl \
    libdbi-perl \
    libtext-csv-xs-perl \
    cpanminus \
    # Add other necessary packages here
    && rm -rf /var/lib/apt/lists/*

# Download and extract LedgerSMB
RUN wget -O /tmp/ledgersmb.tar.gz "$ARTIFACT_LOCATION" \
    && tar -xzf /tmp/ledgersmb.tar.gz -C /opt \
    && rm /tmp/ledgersmb.tar.gz

# Set the working directory
WORKDIR /opt/ledgersmb

# Install Perl dependencies
RUN cpanm --installdeps .

# Copy the start script into the container
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Set up environment variables for LedgerSMB
ENV LSMB_MAIL_SMTPHOST 172.17.0.1
ENV POSTGRES_HOST postgres
ENV POSTGRES_PORT 5432
ENV DEFAULT_DB lsmb

# Expose the port LedgerSMB will run on
EXPOSE 5762

# Run the start script
USER www-data
CMD ["start.sh"]
