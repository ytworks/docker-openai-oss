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
RUN pip install -U git+https://github.com/Tsumugii24/transformers
RUN pip install -U accelerate kernels
RUN pip install -U triton==3.4
RUN pip install -U "huggingface_hub[cli]"
RUN pip install torch==2.8.0 --index-url https://download.pytorch.org/whl/test/cu128

# Install Triton kernels from GitHub
# Note: This is necessary for the Triton kernels to be available in the environment
# The subdirectory is specified to point to the correct location of the Triton kernels
RUN pip3 install git+https://github.com/triton-lang/triton.git@main#subdirectory=python/triton_kernels
ENV HF_HOME=/app/cache

# Install Pillow and rich for transformers chat command
RUN pip3 install Pillow rich

# Create cache directory
RUN mkdir -p /app/cache
RUN pip list

ENV TRITON_ALWAYS_COMPILE=1

# Model will be downloaded separately after build

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

# Expose port for API server
EXPOSE 8000

# Entry point for transformers chat API server
# Using serve command with force_model to use local model
CMD ["transformers", "serve", "--host", "0.0.0.0", "--port", "8000", "--force_model", "/app/cache/models/openai/gpt-oss-20b", "--trust_remote_code"]