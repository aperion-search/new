FROM diegosouzapw/omniroute:latest

USER root

# Install Python and huggingface_hub
RUN apt-get update && apt-get install -y --no-install-recommends python3 python3-pip && \
    pip3 install --no-cache-dir --break-system-packages huggingface_hub && \
    rm -rf /var/lib/apt/lists/*

# Copy scripts to root directory to avoid changing WORKDIR
COPY sync.py /sync.py
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh /sync.py

ENV DATA_DIR=/data
ENTRYPOINT ["/entrypoint.sh"]
CMD ["npm", "start"]
