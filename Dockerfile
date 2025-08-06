FROM nvidia/cuda:12.8.1-cudnn-runtime-ubuntu22.04

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install Python dependencies
# Install base dependencies first
RUN pip3 install --upgrade transformers accelerate kernels huggingface-hub

# Install PyTorch 2.8.0 with CUDA 12.8
RUN pip3 install torch==2.8.0 --index-url https://download.pytorch.org/whl/test/cu128

# Install triton kernels for mxfp4 support (last)
RUN pip3 install git+https://github.com/triton-lang/triton.git@main#subdirectory=python/triton_kernels

RUN pip3 install --force-reinstall -v "hf_xet==1.1.4-rc3"
RUN ulimit -Sn 4096
ENV HF_XET_MAX_CONCURRENT_DOWNLOADS=2

# Create cache directory
RUN mkdir -p /app/cache

# Set Hugging Face cache directory
ENV HF_HOME=/app/cache

# Download model during build using huggingface_hub
RUN python3 -c "from huggingface_hub import snapshot_download; \
    import os; \
    os.environ['HF_HOME'] = '/app/cache'; \
    print('Downloading model openai/gpt-oss-20b...'); \
    snapshot_download( \
    repo_id='openai/gpt-oss-20b', \
    cache_dir='/app/cache', \
    revision='main' \
    ); \
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
ENV CUDA_VISIBLE_DEVICES=0

# Entry point
CMD ["python3", "main.py"]