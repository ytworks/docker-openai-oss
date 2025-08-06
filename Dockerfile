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
RUN pip3 install --upgrade transformers accelerate kernels

# Install PyTorch 2.8.0 with CUDA 12.8
RUN pip3 install torch==2.8.0 --index-url https://download.pytorch.org/whl/test/cu128

# Install triton kernels for mxfp4 support (last)
RUN pip3 install git+https://github.com/triton-lang/triton.git@main#subdirectory=python/triton_kernels

# Create cache directory
RUN mkdir -p /app/cache

# Set Hugging Face cache directory
ENV HF_HOME=/app/cache

# Skip model download during build - will download on first run
RUN echo "Model will be downloaded on first run"

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