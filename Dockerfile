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
RUN pip install -U transformers accelerate torch triton kernels
RUN pip install -U triton kernels
RUN pip install -U "huggingface_hub[cli]"
# Install Triton kernels from GitHub
# Note: This is necessary for the Triton kernels to be available in the environment
# The subdirectory is specified to point to the correct location of the Triton kernels
RUN pip3 install git+https://github.com/triton-lang/triton.git@main#subdirectory=python/triton_kernels
ENV HF_HOME=/app/cache

# Create cache directory
RUN mkdir -p /app/cache



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

# Entry point
CMD ["python3", "main.py"]