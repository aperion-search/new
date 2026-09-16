FROM diegosouzapw/omniroute:latest

USER root

# Install Python and huggingface_hub client
RUN apt-get update && apt-get install -y --no-install-recommends python3 python3-pip && \
    pip3 install --no-cache-dir --break-system-packages huggingface_hub && \
    rm -rf /var/lib/apt/lists/*

COPY sync.py /app/sync.py
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh /app/sync.py

ENV DATA_DIR=/data
ENV PORT=3000

ENTRYPOINT ["/entrypoint.sh"]
# Notice: CMD is deliberately omitted so it inherits the base image's production startup command
