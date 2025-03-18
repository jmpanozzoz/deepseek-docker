#!/bin/bash

export HF_TOKEN=$HUGGING_FACE_TOKEN

echo "🔹 Descargando modelo: $MODEL_NAME"

# Descargar modelo desde Hugging Face
python3 -c "
from huggingface_hub import snapshot_download
try:
    snapshot_download(
        '${MODEL_NAME}',
        cache_dir='/root/.cache/huggingface/hub',
        ignore_patterns=['*.safetensors', '*.bin']
    )
    print('✅ Modelo descargado con éxito.')
except Exception as e:
    print(f'❌ Error al descargar el modelo: {e}')
    exit(1)
"

# Detectar Compute Capability (opcional, útil para logs o depuración)
COMPUTE_CAP=$(nvidia-smi --query-gpu=compute_cap --format=csv,noheader | head -1 | tr -d '.')

echo "🚀 Iniciando vLLM"

# Iniciar servidor vLLM
exec python3 -m vllm.entrypoints.api_server \
    --model "${MODEL_NAME}" \
    --tensor-parallel-size 2 \
    --gpu-memory-utilization 0.97 \
    --max-model-len 8192 \
    --max-num-batched-tokens 7168 \
    --max-parallel-loading-workers 4
