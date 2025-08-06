# Docker化されたGPT OSS CLI - 技術設計書

## 1. システム概要

Dockerコンテナ内で動作する単一ファイルのCLIアプリケーション。GPT-OSSモデルをMXFP4量子化して対話型インターフェースを提供。

## 2. アーキテクチャ

```
Docker Container
├── main.py (全機能を含む)
└── cache/ (モデルキャッシュ)
```

## 3. ファイル構成

```
docker-openai-oss/
├── Dockerfile
├── pyproject.toml
├── main.py        # 単一のPythonファイル
├── README.md
├── scripts/       # スクリプトディレクトリ
│   ├── build.sh   # ビルドスクリプト
│   └── run.sh     # 起動スクリプト
└── cache/
```

## 4. main.py の機能

1. **GPU確認**
   - NVIDIA GPUの利用可能性チェック

2. **モデル管理**
   - モデルのダウンロード
   - MXFP4量子化（Tritonカーネル含む）
   - キャッシュ管理

3. **対話処理**
   - ユーザー入力受付
   - 推論実行
   - 応答表示

## 5. 処理フロー

```
起動
├── GPU確認
├── キャッシュ確認
│   ├── あり → キャッシュから読み込み
│   └── なし → ダウンロード → 量子化 → キャッシュ保存
└── 対話ループ開始
```

## 6. 技術スタック

- **Python**: 3.11+
- **パッケージ管理**: uv
- **主要ライブラリ**:
  - torch (GPU対応)
  - transformers
  - triton
  - accelerate

## 7. Docker設計

- ベースイメージ: `nvidia/cuda:12.3-runtime-ubuntu22.04`
- マルチステージビルドは使わない（シンプルさ優先）
- 非rootユーザーで実行

## 8. 実行方法

```bash
./scripts/build.sh
./scripts/run.sh
```

## 9. 設計の特徴

- **単一ファイル**: 全ロジックを`main.py`に集約
- **最小構成**: 必要最小限のファイルのみ
- **キャッシュ**: 量子化済みモデルを保存して高速化
- **エラー処理**: シンプルなtry-except
- **スクリプト**: ビルドと起動を簡単にする`build.sh`と`run.sh`

## 10. スクリプト設計

### 10.1 build.sh
- Dockerイメージのビルド
- ビルド進捗の表示
- エラー時の適切な終了

### 10.2 run.sh
- GPUの自動検出と設定
- コンテナの起動
- 既存コンテナの処理