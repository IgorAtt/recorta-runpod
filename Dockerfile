FROM python:3.11-slim

# Bibliotecas de sistema que o rembg/PIL precisam
RUN apt-get update && apt-get install -y libgl1 libglib2.0-0 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Baixa o modelo JA no build (fica embutido na imagem = cold start menor)
ENV U2NET_HOME=/app/models
COPY handler.py .
RUN python -c "from rembg import new_session; new_session('birefnet-general')"

CMD ["python", "-u", "handler.py"]
