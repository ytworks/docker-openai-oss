# Design - Transformers Chat API Server

## システム構成

### 1. アーキテクチャ
- Dockerコンテナ内でTransformers Chat APIサーバーを実行
- 既存のローカルモデルファイルをボリュームマウント
- HTTPポート8000でAPI提供

### 2. ファイル構成（既存構成を維持）
```
docker-openai-oss/
├── Dockerfile (修正)
├── scripts/
│   ├── start.sh (新規)
│   ├── stop.sh (新規)
│   └── test_api.sh (新規)
└── cache/models/openai/gpt-oss-20b/ (既存モデル配置場所)
```

### 3. 実装方針

#### Dockerfile修正
- 最終行のCMDコマンドのみ変更
- EXPOSEディレクティブ追加
- 他の部分は一切変更なし

#### scripts/start.sh
- 既存のbuild.shと同様の形式
- MODEL_PATH環境変数対応（デフォルト: ./cache/models/openai/gpt-oss-20b）

#### scripts/stop.sh
- コンテナの適切な停止処理
- オプションでコンテナ削除

#### scripts/test_api.sh
- curlコマンドによるAPIテスト
- JSONレスポンスの整形表示

### 4. 技術仕様
- transformers CLIのchatコマンド使用
- ローカルパス指定でモデル読み込み
- GPUサポート継続（--gpus all）