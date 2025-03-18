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

# Instalación de dependencias actualizadas y optimizadas
RUN pip3 install \
    vllm==0.3.2 \  # Se bajó de 0.4.1 a 0.3.2 por estabilidad
    huggingface_hub==0.22.2 \
    accelerate==0.29.3 \
    ninja==1.11.1.1 \
    "ray[default]==2.9.0" \  # Se especificó versión estable de Ray
    flash-attn --no-build-isolation  # Mejora en rendimiento

COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Configuraciones de entorno
ENV CUDA_LAUNCH_BLOCKING=1
ENV NCCL_IGNORE_DISABLED_P2P=1
ENV RAY_DISABLE_CUSTOM_ALL_REDUCE=True
ENV MAX_CONCURRENT_WORKERS=1

WORKDIR /app
CMD ["/app/start.sh"]
