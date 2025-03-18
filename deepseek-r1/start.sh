#!/bin/bash

export HF_TOKEN=$HUGGING_FACE_TOKEN
QUANTIZATION=${QUANTIZATION:-None}  # Usar None si no está definido

echo "🔹 Usando QUANTIZATION: $QUANTIZATION"
echo "🔹 Descargando modelo: $MODEL_NAME"

# Verificar si `QUANTIZATION` es válido
VALID_QUANTIZATIONS=("aqlm" "awq" "fp8" "gptq" "squeezellm" "marlin" "None")
if [[ ! " ${VALID_QUANTIZATIONS[@]} " =~ " ${QUANTIZATION} " ]]; then
    echo "⚠️ Error: Valor inválido para QUANTIZATION (${QUANTIZATION})"
    echo "   Opciones válidas: ${VALID_QUANTIZATIONS[*]}"
    exit 1
fi

# Descargar modelo sin aplicar cuantización si es "None"
if [[ "$QUANTIZATION" == "None" ]]; then
    QUANTIZATION_ARG=""
else
    QUANTIZATION_ARG="revision='${QUANTIZATION}',"
fi

python3 -c "
from huggingface_hub import snapshot_download
snapshot_download(
    '${MODEL_NAME}',
    ${QUANTIZATION_ARG}
    cache_dir='/root/.cache/huggingface/hub',
    ignore_patterns=['*.safetensors', '*.bin']
)
"

# Detectar Compute Capability (aún no se usa, pero puede ser útil)
COMPUTE_CAP=$(nvidia-smi --query-gpu=compute_cap --format=csv,noheader | head -1 | tr -d '.')

echo "🚀 Iniciando vLLM"

# Iniciar servidor
exec python3 -m vllm.entrypoints.api_server \
    --model "${MODEL_NAME}" \
    --quantization "${QUANTIZATION}" \
    --tensor-parallel-size 2 \
    --gpu-memory-utilization 0.97 \
    --max-model-len 8192 \
    --max-num-batched-tokens 7168 \
    --max-parallel-loading-workers 4
