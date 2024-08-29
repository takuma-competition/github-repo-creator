#!/bin/bash

# Homebrewがインストールされているか確認
if ! command -v brew &> /dev/null
then
    echo "Homebrewがインストールされていません。インストールしてください。"
    echo "インストール方法: https://brew.sh/"
    exit 1
fi

# 関数: ツールのインストールまたは更新
install_or_upgrade() {
    if brew list $1 &>/dev/null; then
        echo "$1 は既にインストールされています。更新を確認します..."
        brew upgrade $1 || echo "$1 は最新版です。"
    else
        echo "$1 をインストールしています..."
        brew install $1
    fi
}

# curlのインストール/更新（通常はmacOSにプリインストールされています）
install_or_upgrade curl

# jqのインストール/更新
install_or_upgrade jq

# Gitのインストール/更新（通常はmacOSにプリインストールされています）
install_or_upgrade git

# SourceTreeのインストール（Homebrewのcaskを使用）
if brew list --cask sourcetree &>/dev/null; then
    echo "SourceTree は既にインストールされています。更新を確認します..."
    brew upgrade --cask sourcetree || echo "SourceTree は最新版です。"
else
    echo "SourceTree をインストールしています..."
    brew install --cask sourcetree
fi

echo "セットアップが完了しました。すべての必要なツールがインストールされているか確認されました。"