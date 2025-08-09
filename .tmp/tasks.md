# Tasks - Transformers Chat API Server

## タスクリスト

### 1. Dockerfile修正
- [ ] CMDコマンドを変更
- [ ] EXPOSE 8000を追加

### 2. scripts/start.sh作成
- [ ] Dockerイメージビルド処理
- [ ] 既存コンテナ停止処理
- [ ] MODEL_PATH環境変数対応
- [ ] コンテナ起動処理（バックグラウンド）

### 3. scripts/stop.sh作成
- [ ] コンテナ停止処理
- [ ] コンテナ削除オプション

### 4. scripts/test_api.sh作成
- [ ] curlによるAPIテスト
- [ ] レスポンス整形
- [ ] エラーハンドリング

### 5. テスト
- [ ] 起動・停止の動作確認
- [ ] APIレスポンス確認