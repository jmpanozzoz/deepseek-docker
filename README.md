# Deepseek Models Deployment

This repository contains the necessary configuration to deploy two Deepseek models (R1 and Coder) using Docker, Nginx, and Certbot. The deployment is optimized to work with NVIDIA cards and includes HTTPS support via Let's Encrypt.

## Requirements

- Docker and Docker Compose installed on your system
- Access to a compatible NVIDIA graphics card
- A Hugging Face account to download the models
- A public domain to configure HTTPS (optional but recommended)

## Project Structure

```bash
deepseek-docker/
├── docker-compose.yml
├── .env
├── nginx/
│   ├── nginx.conf
│   └── ssl_options.conf
├── certbot/
│   └── renew-hook.sh
├── deepseek-r1/
│   ├── Dockerfile
│   └── start.sh
└── deepseek-coder/
    ├── Dockerfile
    └── start.sh

## Initial Configuration

1. Clone the repository:
```bash
git clone [your-repository-url]
cd [repository-name]
```

2. Create a `.env` file in the root directory of the project with the following environment variables:
```bash
R1_API_KEY=your-deepseek-r1-api-key
CODER_API_KEY=your-deepseek-coder-api-key
DOMAIN=your-domain.com
CERTBOT_EMAIL=your-email@example.com
```

## File Description

### `docker-compose.yml`    
Main configuration file defining the services:
- `deepseek-r1`: Server for the Deepseek R1 model
- `deepseek-coder`: Server for the Deepseek Coder model
- `nginx`: Web server acting as a reverse proxy
- `certbot`: Service for obtaining and renewing SSL certificates

### `Dockerfile`
Defines the base image for the Deepseek containers, including:
- CUDA 12.2 for NVIDIA compatibility
- Python 3.10 and necessary dependencies
- PyTorch 2.3.0 with CUDA 12.1 support
- Other libraries like `vllm`, `huggingface_hub`, and `accelerate`

### `nginx.conf`
Nginx configuration for:
- Acting as a reverse proxy for the Deepseek services
- Establishing secure HTTPS connections
- Setting security headers and TLS options

## Deployment

### 1. Build everything
```bash
docker compose build
```

### 2. Obtain SSL certificates (first time only)
```bash
docker compose up -d nginx
docker compose run --rm certbot
```

### 3. Start all services
```bash
docker compose up -d
```

### 4. Check service status
```bash
docker compose ps
```

### 5. Test endpoints
```bash
curl -X POST "https://${DOMAIN}/r1/v1/completions" \
  -H "X-API-Key: ${R1_API_KEY}" \
  -d '{"prompt": "How do transformers work in NLP?", "max_tokens": 500}'

curl -X POST "https://${DOMAIN}/coder/v1/completions" \
  -H "X-API-Key: ${CODER_API_KEY}" \
  -d '{"prompt": "Implement QuickSort in Rust", "max_tokens": 300}'
```

### 6. Stop all services
```bash
docker compose down
```

## Environment Variables

The following variables must be configured in the `.env` file:
- `R1_API_KEY`: API Key for the Deepseek R1 model
- `CODER_API_KEY`: API Key for the Deepseek Coder model
- `DOMAIN`: Public domain to configure HTTPS
- `CERTBOT_EMAIL`: Email address for Let's Encrypt

## Maintenance

### Certificate Renewal
Certbot automatically handles SSL certificate renewal. The `renew-hook.sh` script ensures Nginx restarts with the new configuration.

### Model Updates
Models are automatically downloaded from Hugging Face Hub. To update to a new model version, update the `MODEL_NAME` variable in `docker-compose.yml` and rebuild the containers.

## License

This project is under the MIT License. See the LICENSE file for more details.