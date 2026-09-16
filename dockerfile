FROM diegosouzapw/omniroute:latest

USER root

# Install Python and huggingface_hub
RUN apt-get update && apt-get install -y --no-install-recommends python3 python3-pip && \
    pip3 install --no-cache-dir --break-system-packages huggingface_hub && \
    rm -rf /var/lib/apt/lists/*

# Keep OmniRoute's original app path
WORKDIR /app

COPY sync.py /app/sync.py
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh /app/sync.py

ENV DATA_DIR=/data
ENTRYPOINT ["/entrypoint.sh"]
CMD ["npm", "start"]
