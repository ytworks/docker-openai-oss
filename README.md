# Docker GPT-OSS CLI

Dockerコンテナ内で動作するGPT-OSSモデル（openai/gpt-oss-20b）のCLIツール。

## 要件

- NVIDIA GPU（RTX 5090推奨）
- Docker with NVIDIA Container Toolkit
- 24GB以上のGPUメモリ

## クイックスタート

```bash
# ビルドと実行
./scripts/build.sh
./scripts/run.sh
```

## セットアップ

### 1. NVIDIA Container Toolkitのインストール

```bash
# Ubuntu/Debian
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker
```

### 2. リポジトリのクローン

```bash
git clone https://github.com/yourusername/docker-openai-oss.git
cd docker-openai-oss
```

### 3. ビルドと実行

#### スクリプトを使用する場合（推奨）

```bash
# Dockerイメージのビルド
./scripts/build.sh

# コンテナの起動
./scripts/run.sh
```

#### Dockerコマンドを直接使用する場合

```bash
# ビルド
docker build -t gpt-oss-cli .

# 実行
docker run --gpus all -it gpt-oss-cli
```

**注意**: 初回ビルド時にモデル（約40GB）がダウンロードされるため、時間がかかります。

## 使用方法

起動後、対話型プロンプトが表示されます：

```
Docker GPT-OSS CLI
==================

GPU: NVIDIA GeForce RTX 5090
Memory: 24.0GB

Loading model...
Model loaded successfully!

==================================================
GPT-OSS CLI Ready!
Type 'exit' to quit
==================================================

>>> こんにちは

こんにちは！何かお手伝いできることがあれば、お気軽にお聞きください。

>>> exit

Goodbye!
```

## 技術仕様

- **モデル**: openai/gpt-oss-20b
- **Python**: 3.11
- **主要ライブラリ**:
  - PyTorch 2.7.0
  - Transformers 4.46.3
  - Triton 3.4.0
- **CUDA**: 12.6.2

## トラブルシューティング

### GPU未検出エラー

```
Error: No NVIDIA GPU detected. Please ensure Docker is running with --gpus flag.
```

解決方法：
- `--gpus all`フラグを付けて実行
- NVIDIA Container Toolkitが正しくインストールされているか確認

### メモリ不足エラー

```
Error: GPU out of memory. Try reducing message history.
```

解決方法：
- 他のGPUプロセスを終了
- より大きなGPUメモリを持つGPUを使用

## スクリプトについて

### scripts/build.sh
- Dockerイメージのビルドを実行
- Dockerの動作確認を自動で行う
- ビルド完了後に次のステップを案内

### scripts/run.sh
- コンテナの起動を実行
- イメージが存在しない場合は自動でビルド
- GPUの自動検出と設定

## ライセンス

MIT License