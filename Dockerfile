FROM nvidia/cuda:12.6.2-runtime-ubuntu22.04

# Install Python and system dependencies
RUN apt-get update && apt-get install -y \
    python3.11 \
    python3.11-dev \
    python3-pip \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install uv
RUN pip3 install uv

# Set working directory
WORKDIR /app

# Copy project files
COPY pyproject.toml .

# Install Python dependencies
RUN uv pip install --system --no-cache -r pyproject.toml

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