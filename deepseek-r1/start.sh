#!/bin/bash

export HF_TOKEN=$HUGGING_FACE_TOKEN
QUANTIZATION=${QUANTIZATION:-None}  # Usar None si no está definido

echo "Usando QUANTIZATION: $QUANTIZATION"
echo "Descargando modelo: $MODEL_NAME"

# Verificar si `QUANTIZATION` es válido
VALID_QUANTIZATIONS=("aqlm" "awq" "fp8" "gptq" "squeezellm" "marlin" "None")
if [[ ! " ${VALID_QUANTIZATIONS[@]} " =~ " ${QUANTIZATION} " ]]; then
    echo "⚠️ Error: Valor inválido para QUANTIZATION (${QUANTIZATION})"
    echo "Opciones válidas: ${VALID_QUANTIZATIONS[*]}"
    exit 1
fi

# Descargar modelo con la cuantización seleccionada
python3 -c "
from huggingface_hub import snapshot_download
snapshot_download(
    '${MODEL_NAME}',
    revision='${QUANTIZATION}',
    cache_dir='/root/.cache/huggingface/hub',
    ignore_patterns=['*.safetensors', '*.bin']
)
"

# Detectar Compute Capability
COMPUTE_CAP=$(nvidia-smi --query-gpu=compute_cap --format=csv,noheader | head -1 | tr -d '.')
EXTRA_ARGS=""

if [[ ${COMPUTE_CAP} -ge 90 ]]; then
    EXTRA_ARGS+=" --block-size 32 --max-paddings 128"
elif [[ ${COMPUTE_CAP} -ge 80 ]]; then
    EXTRA_ARGS+=" --block-size 16 --max-paddings 64"
fi

echo "🚀 Iniciando vLLM con ${EXTRA_ARGS}"

# Iniciar servidor
exec python3 -m vllm.entrypoints.api_server \
    --model ${MODEL_NAME} \
    --quantization ${QUANTIZATION} \
    --tensor-parallel-size 2 \
    --gpu-memory-utilization 0.97 \
    --max-model-len 8192 \
    --max-num-batched-tokens 7168 \
    --max-parallel-loading-workers 4 \
    ${EXTRA_ARGS}
