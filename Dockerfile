# Base COM CUDA + cuDNN (é o que faz o rembg usar a GPU em vez da CPU)
FROM nvidia/cuda:12.4.1-cudnn-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    python3 python3-pip libgl1 libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# Baixa o modelo no build (cold start menor)
ENV U2NET_HOME=/app/models
COPY handler.py .
RUN python3 -c "from rembg import new_session; new_session('birefnet-general')"

CMD ["python3", "-u", "handler.py"]
