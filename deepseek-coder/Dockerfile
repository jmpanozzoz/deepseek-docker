FROM nvidia/cuda:12.2.2-runtime-ubuntu22.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.10 \
    python3-pip \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --upgrade pip && \
    pip3 install torch==2.3.0+cu121 --extra-index-url https://download.pytorch.org/whl/cu121

# Instalación de NumPy 1.x para evitar problemas de compatibilidad
RUN pip3 install "numpy<2"

RUN pip3 install \
    vllm==0.4.1 \
    huggingface_hub==0.22.2 \
    accelerate==0.29.3 \
    ninja==1.11.1.1

COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

ENV CUDA_LAUNCH_BLOCKING=1
ENV NCCL_IGNORE_DISABLED_P2P=1

WORKDIR /app
CMD ["/app/start.sh"]
