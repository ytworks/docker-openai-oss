#!/usr/bin/env python3
import os
import sys
import torch
from transformers import AutoModelForCausalLM, AutoTokenizer


MODEL_ID = "openai/gpt-oss-20b"
CACHE_DIR = os.getenv("MODEL_CACHE_DIR", "/app/cache")


def check_gpu():
    """Check GPU availability"""
    if not torch.cuda.is_available():
        print("Error: No NVIDIA GPU detected. Please ensure Docker is running with --gpus flag.")
        sys.exit(1)
    
    device_name = torch.cuda.get_device_name(0)
    total_memory = torch.cuda.get_device_properties(0).total_memory / 1e9
    print(f"GPU: {device_name}")
    print(f"Memory: {total_memory:.1f}GB\n")


def load_model():
    """Load model and tokenizer"""
    print("Loading model...")
    
    try:
        tokenizer = AutoTokenizer.from_pretrained(
            MODEL_ID, 
            cache_dir=CACHE_DIR
        )
        model = AutoModelForCausalLM.from_pretrained(
            MODEL_ID,
            device_map="auto",
            torch_dtype="auto",
            cache_dir=CACHE_DIR
        )
        
        print("Model loaded successfully!\n")
        return model, tokenizer
    except Exception as e:
        print(f"Error loading model: {e}")
        print("\nNote: This may be due to the model being large (~40GB).")
        print("Please ensure you have enough disk space and memory.")
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
            with torch.no_grad():
                generated = model.generate(
                    **inputs,
                    max_new_tokens=256,
                    temperature=0.7,
                    do_sample=True,
                    top_p=0.9,
                )
            
            # Decode response
            response = tokenizer.decode(
                generated[0][inputs["input_ids"].shape[-1]:],
                skip_special_tokens=True
            )
            
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