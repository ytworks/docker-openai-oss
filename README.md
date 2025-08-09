# Docker GPT-OSS API Server

Dockerコンテナ内で動作するGPT-OSSモデル（openai/gpt-oss-20b）のAPIサーバー。OpenAI互換のAPIエンドポイントを提供します。

## 要件

- NVIDIA GPU（RTX 5090推奨）
- Docker with NVIDIA Container Toolkit
- 24GB以上のGPUメモリ

## クイックスタート

```bash
# 1. Dockerイメージのビルド
./scripts/build.sh

# 2. モデルのダウンロード（初回のみ、約40GB）
./scripts/download_model.sh

# 3. APIサーバーの起動
./scripts/start.sh

# 4. APIのテスト
./scripts/test_api.sh
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

```bash
# 1. Dockerイメージのビルド
./scripts/build.sh

# 2. モデルのダウンロード（初回のみ）
./scripts/download_model.sh

# 3. APIサーバーの起動（バックグラウンド）
./scripts/start.sh

# 4. APIサーバーの停止
./scripts/stop.sh

# コンテナの削除も行う場合
./scripts/stop.sh --rm
```

## APIの使用方法

サーバーが起動すると、`http://localhost:8000`でOpenAI互換のAPIエンドポイントが利用可能になります。

### エンドポイント

- `POST /v1/chat/completions` - チャット補完
- `GET /v1/models` - 利用可能なモデル一覧

### テスト実行

```bash
./scripts/test_api.sh
```

このスクリプトは以下のテストを実行します：
1. 利用可能なモデルの確認
2. "hi! What is PAC1"という質問への応答テスト
3. "what is GPR17"という質問への応答テスト

### カスタムモデルパスの指定

デフォルトでは`./cache`ディレクトリのモデルを使用しますが、環境変数で変更可能です：

```bash
MODEL_PATH=/path/to/your/cache ./scripts/start.sh
```

### APIリクエストの例

```bash
curl -X POST http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-oss-20b",
    "messages": [
      {"role": "user", "content": "Hello, how are you?"}
    ],
    "temperature": 0.8,
    "max_tokens": 512
  }'
```

## 技術仕様

- **モデル**: openai/gpt-oss-20b
- **Python**: 3.10 (Ubuntu 22.04 default)
- **主要ライブラリ**:
  - PyTorch 2.8.0 (test版, CUDA 12.8)
  - Transformers 4.46.3+
  - Accelerate 1.2.1+
  - Kernels
  - Triton Kernels (MXFP4サポート)
  - Pillow, rich (transformers serveの依存関係)
- **CUDA**: 12.8.1 (ベースイメージ)
- **APIサーバー**: transformers serve (OpenAI互換)

## スクリプトについて

### scripts/build.sh
- Dockerイメージのビルドを実行
- イメージ名: `gpt-oss-cli`
- Dockerの動作確認を自動で行う

### scripts/download_model.sh
- Hugging Faceからモデルをダウンロード
- `huggingface-cli`を使用してモデルファイルを取得
- プロジェクトの`cache`ディレクトリに保存
- 初回のみ実行が必要（約40GB）

### scripts/start.sh
- APIサーバーをバックグラウンドで起動
- コンテナ名: `transformers-chat-server`
- ポート8000でリッスン
- GPUとDNS設定を自動構成
- カスタムモデルパス対応（`MODEL_PATH`環境変数）

### scripts/stop.sh
- 実行中のAPIサーバーを停止
- `--rm`オプションでコンテナの削除も可能

### scripts/test_api.sh
- APIエンドポイントのテスト
- モデル一覧の確認
- チャット機能のテスト（2つの質問を実行）

## トラブルシューティング

### コンテナが起動しない

```bash
# コンテナのログを確認
docker logs transformers-chat-server
```

### APIに接続できない

- ポート8000が他のプロセスで使用されていないか確認
- ファイアウォール設定を確認
- コンテナが正常に起動しているか確認

### GPU未検出エラー

解決方法：
- NVIDIA Container Toolkitが正しくインストールされているか確認
- `nvidia-smi`コマンドでGPUが認識されているか確認

### メモリ不足エラー

解決方法：
- 他のGPUプロセスを終了
- より大きなGPUメモリを持つGPUを使用

## ライセンス

MIT License