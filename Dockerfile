FROM nvidia/cuda:12.6.2-cudnn9-runtime-ubuntu22.04

# Install Python and system dependencies
RUN apt-get update && apt-get install -y \
    python3.11 \
    python3.11-dev \
    python3.11-venv \
    python3.11-distutils \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install pip for Python 3.11
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11

# Set working directory
WORKDIR /app

# Install Python dependencies
# Install PyTorch 2.8.0 with CUDA 12.8
RUN python3.11 -m pip install torch==2.8.0 --index-url https://download.pytorch.org/whl/test/cu128

# Install triton kernels for mxfp4 support
RUN python3.11 -m pip install git+https://github.com/triton-lang/triton.git@main#subdirectory=python/triton_kernels

# Install other dependencies
RUN python3.11 -m pip install transformers>=4.46.3 accelerate>=1.2.1 safetensors>=0.4.5

# Create cache directory
RUN mkdir -p /app/cache

# Download model during build
RUN python3.11 -c "from transformers import AutoModelForCausalLM, AutoTokenizer; \
    print('Downloading model...'); \
    model = AutoModelForCausalLM.from_pretrained('openai/gpt-oss-20b', \
        cache_dir='/app/cache', \
        torch_dtype='auto'); \
    tokenizer = AutoTokenizer.from_pretrained('openai/gpt-oss-20b', \
        cache_dir='/app/cache'); \
    print('Model downloaded successfully!')"

# Copy main application
COPY main.py .

# Create non-root user
RUN useradd -m -u 1000 appuser && \
    chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Environment variables
ENV PYTHONUNBUFFERED=1
ENV MODEL_CACHE_DIR=/app/cache
ENV CUDA_VISIBLE_DEVICES=0

# Entry point
CMD ["python3.11", "main.py"]