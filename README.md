# CustomDate DuckDB Extension

DuckDBでYYYY.MM.DD形式の日付を標準CSV自動型検出で自動認識できるようにする拡張機能です。

[![Build Status](https://github.com/char5742/custom-date-extension/workflows/CI/badge.svg)](https://github.com/char5742/custom-date-extension/actions)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

このリポジトリは [DuckDB Extension Template](https://github.com/duckdb/extension-template) をベースにしています。

---

## 🎯 概要

CustomDate拡張機能は、日本でよく使用されるYYYY.MM.DD形式（例：`2023.01.15`）の日付を、DuckDBの標準CSV自動型検出システムに統合します。これにより、`read_csv()`がYYYY.MM.DD形式を自動的にDATE型として認識し、面倒な型指定やフォーマット指定が不要になります。

### 🌟 主な利点

- **完全自動認識**: `SELECT * FROM read_csv('file.csv')` だけでYYYY.MM.DD形式がDATE型に
- **標準機能の拡張**: DuckDBの既存CSV自動型検出システムに統合
- **設定不要**: `dateformat`パラメータや手動キャストが不要
- **既存コードとの互換性**: 標準的な日付形式も引き続き完全動作

## ✨ 機能

### 🚀 標準CSV自動型検出の拡張

**これが最大の特徴です！** 従来のDuckDBでは認識されなかったYYYY.MM.DD形式が、標準のCSV読み込みで自動的にDATE型として検出されます：

```sql
-- 🎯 これだけで完全動作！設定やパラメータ不要
SELECT * FROM read_csv('data.csv');
-- YYYY.MM.DD列が自動的にDATE型として認識される

-- 全ファイルスキャンで確実な型検出
SELECT * FROM read_csv('data.csv', sample_size=-1);
```

**Before（従来のDuckDB）:**
```sql
-- YYYY.MM.DD形式は文字列として読み込まれる
SELECT * FROM read_csv('data.csv');  -- birth_date: VARCHAR '1990.05.15'

-- 手動で変換が必要
SELECT birth_date::DATE FROM read_csv('data.csv', dateformat='%Y.%m.%d');
```

**After（この拡張機能）:**
```sql
-- YYYY.MM.DD形式が自動的にDATE型として認識される！
SELECT * FROM read_csv('data.csv');  -- birth_date: DATE '1990-05-15'
```

### 🔄 フォールバック対応キャスト機能

標準検出に加えて、手動キャストでもYYYY.MM.DD形式をサポート：

```sql
SELECT '2023.01.15'::DATE;              -- ✅ 2023-01-15
SELECT CAST('2024.12.25' AS DATE);      -- ✅ 2024-12-25
```

### 🛡️ 堅牢な検証

無効な日付は適切にNULLを返します：
```sql
SELECT '2023.13.01'::DATE;              -- ❌ NULL（無効な月）
SELECT '2023.02.30'::DATE;              -- ❌ NULL（無効な日）
```

## 🔧 ビルド

### 📋 前提条件

| ツール | バージョン | 用途 |
|--------|------------|------|
| C++コンパイラ | g++ または clang++ | ソースコードのコンパイル |
| CMake | 3.5以上 | ビルドシステム |
| Git | 最新版 | サブモジュール管理 |
| Python3 | 3.6以上 | ビルドスクリプト |
| Ninja | 最新版（オプション） | 高速ビルド |

```bash
# Ubuntu/Debianの場合
sudo apt-get update
sudo apt-get install -y g++ cmake git python3 ninja-build

# macOSの場合
brew install cmake git python3 ninja
```

### 🏗️ ビルド手順

```bash
# 1. リポジトリのクローン（サブモジュール含む）
git clone --recurse-submodules https://github.com/char5742/custom-date-extension.git
cd custom-date-extension

# 2. 標準ビルド（推奨）
make

# 3. 高速ビルド（Ninja使用）
GEN=ninja make

# 4. デバッグビルド（開発時）
make debug

# 5. クリーンビルド
make clean && make
```

### 📦 ビルド成果物

```
build/release/
├── duckdb                              # 拡張機能内蔵DuckDBシェル
├── test/unittest                       # テストランナー
└── extension/custom_date/
    └── custom_date.duckdb_extension    # 配布可能な拡張機能ファイル
```

## 🚀 使用方法

### 💻 DuckDBシェルでの使用

#### 方法1: ビルド済みDuckDBシェルを使用（推奨）
```bash
# 拡張機能が自動的にロードされます
./build/release/duckdb
```

#### 方法2: 既存のDuckDBで拡張機能をロード
```sql
LOAD 'build/release/extension/custom_date/custom_date.duckdb_extension';
```

### 📊 メイン機能：標準CSV自動型検出

**この拡張機能の真価はここにあります！**

#### 🎯 基本的な使用（設定不要）

```sql
-- サンプルCSVファイル: employees.csv
-- id,name,birth_date,hire_date
-- 1,Alice,1990.05.15,2020.01.10
-- 2,Bob,1985.12.03,2019.06.25

-- 🚀 これだけでYYYY.MM.DD形式がDATE型に自動認識される！
SELECT * FROM read_csv('employees.csv');
```

**結果:**
```
┌───────┬─────────┬────────────┬────────────┐
│  id   │  name   │ birth_date │ hire_date  │
│ int64 │ varchar │    date    │    date    │
├───────┼─────────┼────────────┼────────────┤
│     1 │ Alice   │ 1990-05-15 │ 2020-01-10 │
│     2 │ Bob     │ 1985-12-03 │ 2019-06-25 │
└───────┴─────────┴────────────┴────────────┘
```

#### 🔍 確実な型検出（推奨）

```sql
-- ファイル全体をスキャンして確実に型検出
SELECT * FROM read_csv('employees.csv', sample_size=-1);

-- 型が正しく検出されていることを確認
SELECT 
    typeof(id) as id_type,
    typeof(name) as name_type, 
    typeof(birth_date) as birth_date_type,
    typeof(hire_date) as hire_date_type
FROM read_csv('employees.csv') LIMIT 1;
```

#### 💡 実践的な活用

```sql
-- 日付範囲でのフィルタリング（設定不要で動作）
SELECT * FROM read_csv('employees.csv')
WHERE birth_date BETWEEN '1980-01-01' AND '1995-12-31';

-- 日付計算（自動的にDATE型なので計算可能）
SELECT 
    name,
    birth_date,
    hire_date,
    hire_date - birth_date as days_between_birth_and_hire,
    date_part('year', age(hire_date, birth_date)) as age_at_hire
FROM read_csv('employees.csv');

-- 集計処理
SELECT 
    date_part('year', birth_date) as birth_year,
    count(*) as employee_count
FROM read_csv('employees.csv')
GROUP BY date_part('year', birth_date)
ORDER BY birth_year;
```

### 🔧 手動キャスト機能（補助的）

標準自動検出に加えて、手動キャストでもYYYY.MM.DD形式をサポート：

```sql
-- 文字列からの変換
SELECT '2023.01.15'::DATE;              -- ✅ 2023-01-15
SELECT CAST('2024.12.25' AS DATE);      -- ✅ 2024-12-25

-- 無効な日付はNULLを返す
SELECT '2023.13.01'::DATE;              -- ❌ NULL（無効な月）
SELECT '2023.02.30'::DATE;              -- ❌ NULL（無効な日）

-- 標準形式も引き続き動作
SELECT '2023-01-15'::DATE;              -- ✅ 2023-01-15
SELECT '01/15/2023'::DATE;              -- ✅ 2023-01-15
```

## 🧪 テスト

### 基本テスト実行
```bash
# 全テスト実行
make test

# 詳細出力付きテスト  
make test-verbose

# 標準CSV自動検出テスト
./build/release/test/unittest --test-dir . test/sql/standard_auto_detect.test
```

### テストデータ
- `test/data/clean_auto_detect_test.csv` - クリーンなYYYY.MM.DD形式データ
- `test/data/auto_detect_test.csv` - 無効データを含むテストケース

## 🛠️ 技術的詳細

### アーキテクチャ

この拡張機能は2つの主要コンポーネントで構成されています：

#### 1. CSV Sniffer拡張（メイン機能）
DuckDBのCSV自動型検出システム（sniffer）を直接拡張し、YYYY.MM.DD形式を認識可能にします：

- **実装箇所**: `duckdb/src/include/duckdb/execution/operator/csv_scanner/sniffer/csv_sniffer.hpp`
- **変更内容**: `format_template_candidates`でYYYY-MM-DD形式を最優先に設定
- **動作**: セパレータ「.」が検出されると、自動的にYYYY.MM.DD形式として処理

#### 2. カスタムキャスト関数（フォールバック）
手動キャスト時のYYYY.MM.DD形式サポート：

- **優先度**: 100（標準より高い）
- **フォールバック**: カスタム形式に合致しない場合、標準DuckDB日付パーサーへ
- **エラーハンドリング**: 無効な日付は適切にNULL設定

### ファイル構成
```
src/
├── custom_date_extension.cpp           # メイン実装
├── include/
│   └── custom_date_extension.hpp       # ヘッダーファイル
duckdb/src/include/duckdb/execution/operator/csv_scanner/sniffer/
└── csv_sniffer.hpp                     # CSV型検出システム（修正済み）
test/
├── sql/standard_auto_detect.test       # 標準自動検出テスト
├── sql/custom_date.test                # キャスト機能テスト  
└── data/                               # テストデータ
```

### 実装の流れ

1. **CSV読み込み開始**: `read_csv()`が呼び出される
2. **自動型検出**: CSV snifferがYYYY.MM.DD形式を検出
3. **DATE型認識**: `%Y-%m-%d`フォーマットテンプレートで処理
4. **自動変換**: YYYY.MM.DD → YYYY-MM-DD形式で格納
5. **利用可能**: 標準DATE型として使用可能

## ⚠️ 注意事項

### データ品質について
- **クリーンデータ推奨**: 無効な日付が含まれる列は文字列型として扱われる場合があります
- **sample_size=-1推奨**: 大きなファイルでは全体スキャンで確実な型検出を

### 互換性
- DuckDB v1.2.0以降でテスト済み
- 既存の日付形式との完全な互換性
- 標準のCSV機能への影響なし

## 📄 ライセンス

このプロジェクトはMITライセンスの下で配布されています。詳細は[LICENSE](LICENSE)ファイルを参照してください。

## 🤝 コントリビューション

コントリビューションを歓迎します！

1. このリポジトリをフォーク
2. 機能ブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'Add amazing feature'`)
4. ブランチにプッシュ (`git push origin feature/amazing-feature`)
5. プルリクエストを作成

## 📞 サポート

- **Issues**: [GitHub Issues](https://github.com/char5742/custom-date-extension/issues)
- **Discussions**: [GitHub Discussions](https://github.com/char5742/custom-date-extension/discussions)
- **DuckDB公式**: [DuckDB Documentation](https://duckdb.org/docs/)