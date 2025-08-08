#!/usr/bin/env python3
import os
import sys
import torch
from transformers import AutoModelForCausalLM, AutoTokenizer


MODEL_ID = "openai/gpt-oss-20b"


def check_gpu():
    """Check GPU availability"""
    if not torch.cuda.is_available():
        print("Error: No NVIDIA GPU detected. Please ensure Docker is running with --gpus flag.")
        sys.exit(1)
    
    device_name = torch.cuda.get_device_name(0)
    total_memory = torch.cuda.get_device_properties(0).total_memory / 1e9
    print(f"GPU: {device_name}", flush=True)
    print(f"Memory: {total_memory:.1f}GB\n", flush=True)


def load_model():
    """Load model and tokenizer"""    
    print("Loading model...", flush=True)
    
    # Check for local model first
    local_model_path = f"/app/cache/models/{MODEL_ID}"
    print(f"Checking local model path: {local_model_path}", flush=True)
    
    try:
        if os.path.exists(local_model_path):
            print(f"Loading from local path: {local_model_path}", flush=True)
            tokenizer = AutoTokenizer.from_pretrained(local_model_path)
            model = AutoModelForCausalLM.from_pretrained(
                local_model_path,
                device_map="cuda",
                torch_dtype="auto"
            )
        else:
            print(f"Local model not found at {local_model_path}", flush=True)
            print("Attempting to download from Hugging Face...", flush=True)
            tokenizer = AutoTokenizer.from_pretrained(MODEL_ID)
            model = AutoModelForCausalLM.from_pretrained(
                MODEL_ID,
                device_map="cuda",
                torch_dtype="auto"
            )
        
        print("Model loaded successfully!\n")
        return model, tokenizer
    except Exception as e:
        print(f"Error loading model: {e}")
        print("\nNote: This may be due to the model being large (~40GB).")
        print("Please ensure you have enough disk space and memory.")
        print("Try running ./scripts/download_model.sh first.")
        sys.exit(1)


def chat_loop(model, tokenizer):
    """Interactive chat loop"""
    print("="*50)
    print("GPT-OSS CLI Ready!")
    print("Type 'exit' to quit")
    print("="*50 + "\n")
    
    messages = []
    
    while True:
        try:
            # Get user input
            user_input = input(">>> ").strip()
            
            if user_input.lower() in ['exit', 'quit', 'bye']:
                print("\nGoodbye!")
                break
            
            if not user_input:
                continue
            
            # Add user message
            messages.append({"role": "user", "content": user_input})
            
            # Apply chat template
            inputs = tokenizer.apply_chat_template(
                messages,
                add_generation_prompt=True,
                return_tensors="pt",
                return_dict=True,
            ).to(model.device)
            
            # Generate response
            generated = model.generate(**inputs, max_new_tokens=200, temperature=1.0)
            
            # Decode response
            response = tokenizer.decode(generated[0][inputs["input_ids"].shape[-1]:])
            
            print(f"\n{response}\n")
            
            # Add assistant message
            messages.append({"role": "assistant", "content": response})
            
            # Keep only last 10 messages to prevent context overflow
            if len(messages) > 10:
                messages = messages[-10:]
            
        except KeyboardInterrupt:
            print("\n\nInterrupted. Goodbye!")
            break
        except torch.cuda.OutOfMemoryError:
            print("\nError: GPU out of memory. Try reducing message history.")
            messages = messages[-2:]  # Keep only last exchange
        except Exception as e:
            print(f"\nError: {str(e)}\n")


def main():
    """Main entry point"""
    print("\nDocker GPT-OSS CLI")
    print("==================\n")
    
    # Check GPU
    check_gpu()
    
    try:
        # Load model
        model, tokenizer = load_model()
        
        # Start chat
        chat_loop(model, tokenizer)
        
    except Exception as e:
        print(f"\nFatal error: {str(e)}")
        sys.exit(1)


if __name__ == "__main__":
    main()