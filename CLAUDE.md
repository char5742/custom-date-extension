# CLAUDE.md

このファイルは、Claude Code (claude.ai/code) がこのリポジトリでコードを操作する際のガイダンスを提供します。

## プロジェクト概要

これは`custom_date`と呼ばれるDuckDB拡張機能で、YYYY.MM.DD形式の日付解析をサポートします。この拡張機能は、VARCHARからDATEへの変換をインターセプトし、標準のDuckDB日付解析にフォールバックする前にカスタム形式を処理するカスタムキャスト関数を登録します。

## アーキテクチャ

- **コア実装**: `src/custom_date_extension.cpp` - カスタムキャスト関数`CustomDateCast`とフォーマットパーサー`TryParseCustomDate`を含むメイン拡張ロジック
- **拡張機能登録**: `casts.RegisterCastFunction()`を使用したDuckDBのキャスト関数システム（優先度100）
- **ビルドシステム**: CMake + Makeラッパーを使用したDuckDBのextension-templateベース
- **テスト**: `test/sql/`内のDuckDBのsqllogictestフォーマットを使用したSQLベーステスト

拡張機能の動作：
1. 高優先度でカスタムVARCHAR→DATEキャスト関数を登録
2. 正規表現検証を使用してYYYY.MM.DD形式の解析を最初に試行
3. カスタム形式が失敗した場合、DuckDBの標準日付パーサーにフォールバック
4. 無効な日付にはNULLを設定

## 共通開発コマンド

### ビルド
```bash
# 標準ビルド（リリースモード）
make

# デバッグビルド
make debug

# Ninjaを使用した高速ビルド
GEN=ninja make

# クリーンビルド
make clean
```

### テスト
```bash
# 全ての拡張機能テストを実行
make test

# カスタムテストターゲットを実行
make test-all          # カスタムテストランナー
make test-mixed        # 混合フォーマットテストのみ
make test-verbose      # 詳細テスト出力

# 特定のテストグループを手動実行
./build/release/test/unittest --test-dir . "[custom_date]"

# 特定のテストファイルを実行
./build/release/test/unittest --test-dir . test/sql/custom_date.test
```

### 使用方法
```bash
# 拡張機能がロードされた組み込みDuckDBシェルを使用
./build/release/duckdb

# 既存のDuckDBで拡張機能をロード
# LOAD 'build/release/extension/custom_date/custom_date.duckdb_extension';
```

## 主要ファイルとディレクトリ

- `src/custom_date_extension.cpp` - メイン拡張機能実装
- `src/include/custom_date_extension.hpp` - 拡張機能ヘッダー
- `test/sql/custom_date.test` - メインテストスイート
- `test/data/test_custom_date.csv` - YYYY.MM.DD日付を含むテストデータ
- `extension_config.cmake` - DuckDBビルドシステム用拡張機能設定
- `Makefile.test` - 追加テストターゲット
- `example_usage.sql` - 使用例

## テストデータ形式

テストCSVファイルは日付列でYYYY.MM.DD形式を使用します。拡張機能は以下の方法でこれらの読み込みをサポートします：
1. `read_csv()`の`dateformat='%Y.%m.%d'`パラメータ
2. VARCHARとして読み込み、DATEにキャスト（カスタムキャスト関数を使用）

## 拡張機能開発ノート

- 拡張機能はベクトル化処理のためにDuckDBの`UnaryExecutor::ExecuteWithNulls`を使用
- 日付検証はDuckDBの組み込み`Date::IsValid()`と`Date::FromDate()`を使用
- キャスト関数登録には優先度パラメータが必要（デフォルトをオーバーライドするため100を使用）
- 拡張機能はDuckDBの標準拡張テンプレート構造に従う
- テストは拡張機能がロードされていることを確認するため`require custom_date`ディレクティブを使用

## ビルド依存関係

- C++コンパイラ（g++/clang++）
- CMake 3.5+
- Git（サブモジュール用）
- Python3
- オプション: 高速ビルド用Ninja