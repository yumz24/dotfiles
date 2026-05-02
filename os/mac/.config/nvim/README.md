# Neovim Configuration (Lua-based)
no pluginsでのnvimの設定(lua)

## ディレクトリ構造

```text
nvim
├── init.lua                # エントリポイント
└── lua
    ├── core                # エディタの基本設定
    │   ├── init.lua
    │   ├── keymaps.lua     # 基本的なキーバインド
    │   └── options.lua     # 基本オプション (行番号、インデント設定等)
    └── modules             # 機能拡張モジュール
        ├── autocmds.lua    # 自動コマンド (FileType別処理等)
        ├── commands.lua    # ユーザーコマンド定義
        ├── ui              # 外観・UI関連
        │   ├── highlights.lua
        │   └── statusline.lua
        └── utils           # 各種ユーティリティ
            ├── lang        # 言語別ロジック
            │   ├── markdown.lua # リアルタイムプレビュー
            │   ├── rust.lua     # Cargo実行ロジック
            │   └── python.lua
            ├── linter.lua  # リンター連携
            └── window.lua  # ウィンドウ操作関連
```

## 主な機能

### Markdown リアルタイムプレビュー (utils/lang/markdown.lua)
外部ツール Glow を使用し、Neovim内で完結するリアルタイムなプレビュー環境を構築しています。
 ライブ更新: 保存操作を介さず、入力中（TextChanged）やカーソル移動中（CursorMoved）に非同期でプレビュー内容を更新します。
スクロール同期: 編集側の行番号に合わせて、プレビュー側のウィンドウ表示位置を自動的に追従させます。
非同期・非ブロッキング: Neovim 0.10以降の vim.system を利用しているため、プレビュー生成中もエディタの操作を妨げません。

### Rust 開発支援 (utils/lang/rust.lua)
Rustの学習や小規模な開発をスムーズに進めるための実行環境を整えています。
F5キーによる実行: 編集中のファイルを自動保存し、即座に下部ターミナルで cargo run を開始します。
インタラクティブ入力対応: 実行ウィンドウを挿入モード（startinsert）で開くため、標準入力を求めるプログラムも即座に操作可能です。
クリーンな出力: 実行前にメッセージエリアをクリア（redraw）し、不要なプロンプトや通知を最小限に抑えています。

## 主要キーバインド

| キー | 機能 | 対象 |
| :--- | :--- | :--- |
| <Leader>p | Markdownプレビューの開始および更新 | Markdown |
| <F5> | cargo run または python 実行 | Rust / Python |
| <Leader>l | リンター（Linter）の実行 | Rust / Python |
| <Leader>f | フォーマッター（Format）の実行 | Rust |

## 必須要件

本設定の機能を十分に利用するには、以下のツールがシステムにインストールされている必要があります。
Glow: Markdownのレンダリングに使用
Rust / Cargo: Rustのビルドおよび実行に使用
Python: Pythonスクリプトの実行に使用

## カスタマイズ方針

新しい言語や機能を追加する場合は、lua/modules/utils/lang/ 内に言語別のロジックを分離して記述し、lua/modules/commands.lua を通じてユーザーコマンドとして登録する構成をとっています。これにより、コア設定を汚さずに機能拡張が可能です。
