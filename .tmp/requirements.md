# Requirements - Transformers Chat API Server

## 概要
既存のDockerfileを最小限の変更で修正し、Transformers Chat APIサーバーとして動作させる。

## 機能要件

### 1. Dockerfile修正
- 既存Dockerfileベースで最小限の変更
- CMDを `transformers chat localhost:8000 --model-name-or-path /app/cache/models/openai/gpt-oss-20b` に変更
- ポート8000を公開
- Pythonパッケージインストール部分は変更なし

### 2. 起動スクリプト (start.sh)
- Dockerイメージのビルド
- 既存コンテナがあれば停止
- ローカルモデルディレクトリをマウント
  - デフォルト: `./model-files` → `/app/cache/models/openai/gpt-oss-20b`
  - 環境変数 `MODEL_PATH` でカスタマイズ可能
- ポート8000をホストにマッピング
- コンテナ名: transformers-chat-server
- バックグラウンド実行

### 3. 停止スクリプト (stop.sh)
- 実行中のコンテナを停止
- コンテナ削除オプション付き

### 4. テストスクリプト (test_api.sh)
- curlでAPIテスト
- エンドポイント: http://localhost:8000
- テストプロンプト: "Please explain how PAC1 receptor works in cell in detail"
- レスポンス整形とエラーハンドリング

## 非機能要件
- ローカルモデル使用（Hugging Faceからのダウンロードなし）
- 既存のPythonパッケージ構成を維持
- GPU対応維持

## 制約事項
- 既存Dockerfileの構造を保持
- transformersコマンドのパスは `/app/cache/models/openai/gpt-oss-20b` 固定