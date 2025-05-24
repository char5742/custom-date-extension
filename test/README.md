# Testing the custom_date Extension

このディレクトリには、custom_date拡張機能のすべてのテストが含まれています。テストは[SQLLogicTest](https://duckdb.org/dev/sqllogictest/intro.html)形式で記述されており、DuckDBの標準的なテスト手法に従っています。

## ディレクトリ構造

### `sql/` - SQLLogicTestファイル
- **`custom_date.test`** - メインテストスイート（46アサーション）
  - YYYY.MM.DD形式の日付キャスト機能のテスト
  - 無効な日付のNULL処理テスト
  - CSV読み込み（dateformatパラメータおよび自動キャスト）のテスト
  - 標準日付フォーマットとの互換性テスト

- **`mixed_formats.test`** - 混合フォーマットテスト（127アサーション）
  - YYYY.MM.DDとYYYY-MM-DDの混合データ処理テスト
  - 複数の日付列を持つCSVファイルのテスト
  - 日付演算と集約関数のテスト
  - フィルタリングとソート操作のテスト

### `data/` - テストデータファイル
- **`test_custom_date.csv`** - YYYY.MM.DD形式の日付を含む基本テストデータ
  - id, name, date_of_birth, amountの列を含む
  - 5行のサンプルデータ

- **`test_mixed_formats.csv`** - 混合日付フォーマットのテストデータ
  - YYYY.MM.DDとYYYY-MM-DDフォーマットが混在する複数の日付列
  - registration_date, last_login, birth_dateの3つの日付列
  - 8行のサンプルデータ

### テスト実行スクリプト
- **`run_tests.sh`** - 全テストの実行スクリプト
  - custom_date.testとmixed_formats.testの両方を実行
  - カラフルな出力とエラーハンドリング
- **`run_mixed_format_test.sh`** - 混合フォーマットテスト専用スクリプト
  - テストデータのプレビュー表示
  - mixed_formats.testのみを実行

## テスト実行方法

### メイクファイルターゲット
```bash
# 全ての拡張機能テストを実行
make test

# デバッグモードでテスト実行
make test_debug

# カスタムテストターゲット（Makefile.test定義）
make test-all          # カスタムテストランナー
make test-mixed        # 混合フォーマットテストのみ
make test-verbose      # 詳細テスト出力
```

### 手動実行
```bash
# テストスクリプトを使用
./test/run_tests.sh           # 全テスト実行
./test/run_mixed_format_test.sh  # 混合フォーマットテストのみ

# 直接unittest実行
./build/release/test/unittest --test-dir . test/sql/custom_date.test
./build/release/test/unittest --test-dir . test/sql/mixed_formats.test

# 全テストを一括実行
./build/release/test/unittest --test-dir . "test/sql/*"
```

## テストの特徴

- すべてのテストは`require custom_date`ディレクティブを使用して拡張機能の読み込みを確認
- 拡張機能読み込み前後の動作の違いをテスト
- YYYY.MM.DD形式の有効性検証とエラーハンドリング
- 標準DuckDB日付機能との互換性確保
- CSVファイル読み込み時の自動型検出と明示的キャスト両方をサポート
- 日付演算、集約関数、フィルタリング操作の包括的テスト