#!/bin/bash

# 設定ファイルの読み込み
source configs.txt

# トークンを環境変数から読み込む
token=${GITHUB_TOKEN}

# トークンが空の場合はエラーを表示して終了
if [ -z "$token" ]; then
  echo "エラー: GITHUB_TOKENが設定されていません。環境変数を確認してください。"
  exit 1
fi

# ユーザー名の確認
if [ -z "$USER_NAME" ]; then
  echo "エラー: USER_NAMEが設定されていません。configs.txtファイルを確認してください。"
  exit 1
fi

if [ "$INTERACTIVE_MODE" = true ]; then
    # ユーザー入力を取得
    read -p "リポジトリ名を入力してください: " repo_name
    read -p "ローカルパスを入力してください: " local_path
    read -p "組織アカウントで作成しますか？ (y/n): " is_org
    read -p "プライベートリポジトリにしますか？ (y/n): " is_private
    read -p "READMEを作成しますか？ (y/n): " create_readme
    read -p "リポジトリの説明を入力してください (任意): " description
    read -p ".gitignoreファイルを作成しますか？ (y/n): " create_gitignore
    echo "利用可能なlicenses:"
    echo "1. MIT"
    echo "2. Apache-2.0"
    echo "3. GPL-3.0"
    echo "4. No license"
    read -p "Please select a license (1-4): " license_option

    # 設定された値を表示
    echo "設定された値:"
    echo "トークン: $token"
    echo "リポジトリ名: $repo_name"
    echo "ロールパス: $local_path"
    echo "組織アカウント: $is_org"
    echo "プライベートリポジトリ: $is_private"
    echo "README作成: $create_readme"
    echo "リポジトリの説明: $description"
    echo ".gitignoreファイル作成: $create_gitignore"
    echo "選択されたライセンス: $license_option"
else
    # 非対話モード
    repo_name=$REPO_NAME
    local_path=$LOCAL_PATH
    is_org=$IS_ORG
    is_private=$IS_PRIVATE
    create_readme=$CREATE_README
    description=$DESCRIPTION
    create_gitignore=$CREATE_GITIGNORE
    license_option=$LICENSE_CHOICE
fi

# ローカルパスの存在確認と作成
if [ ! -d "$local_path" ]; then
  read -p "指定されたローカルパス '$local_path' が存在しません。作成しますか？ (y/n): " create_dir
  if [ "$create_dir" = "y" ]; then
    mkdir -p "$local_path"
    echo "ローカルパス '$local_path' を作成しました。"
  else
    echo "エラー: ローカルパスが存在しません。"
    exit 1
  fi
fi


# プライベートリポジトリの設定
if [ "$is_private" = true ] || [ "$is_private" = "y" ]; then
  private=true
else
  private=false
fi

# READMEの設定
if [ "$create_readme" = true ] || [ "$create_readme" = "y" ]; then
  auto_init=true
else
  auto_init=false
fi

# ライセンスの設定
case $license_option in
  1) license="MIT" ;;
  2) license="Apache-2.0" ;;
  3) license="GPL-3.0" ;;
  4) license="" ;;
  *) echo "無効なライセンスオプションです"; exit 1 ;;
esac

# JSONデータの作成
json_data=$(jq -n \
  --arg name "$repo_name" \
  --arg description "$description" \
  --argjson private "$private" \
  --argjson auto_init "$auto_init" \
  --arg license_template "$license" \
  '{
    name: $name,
    description: $description,
    private: $private,
    auto_init: $auto_init,
    license_template: $license_template
  }')

# APIリクエストの送信
if [ "$is_org" = true ] || [ "$is_org" = "y" ] && [ -n "$ORG_NAME" ]; then
  api_url="https://api.github.com/orgs/$ORG_NAME/repos"
else
  api_url="https://api.github.com/user/repos"
fi

response=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
  -H "Authorization: token $token" \
  -H "Content-Type: application/json" \
  -d "$json_data" \
  "$api_url")

# レスポンスの確認
if [ "$response" -eq 201 ]; then
  echo "リポジトリが正常に作成されました。"
else
  echo "エラー: リポジトリの作成に失敗しました。エラーコード: $response"
  exit 1
fi

# ローカルリポジトリの初期化

# Function to handle errors
handle_error() {
    echo "Error: $1"
    read -p "Do you want to continue anyway? (y/n) " choice
    case "$choice" in 
      y|Y ) echo "Continuing...";;
      n|N ) echo "Exiting..."; exit 1;;
      * ) echo "Invalid input. Exiting..."; exit 1;;
    esac
}

# ローカルリポジトリの初期化
echo "ローカルリポジトリの初期化を開始します..."
mkdir -p "$local_path"
cd "$local_path" || handle_error "ディレクトリ $local_path への移動に失敗しました"
if ! git init -b main; then
    handle_error "Gitリポジトリの初期化に失敗しました"
fi
echo "ローカルリポジトリの初期化が完了しました"

# リモートの設定
echo "リモートの設定を開始します..."
if [ "$is_org" = true ] || [ "$is_org" = "y" ] && [ -n "$ORG_NAME" ]; then
    remote_url="https://github.com/$ORG_NAME/$repo_name.git"
else
    remote_url="https://github.com/$USER_NAME/$repo_name.git"
fi

if ! git remote add origin "$remote_url"; then
    handle_error "リモートオリジンの追加に失敗しました"
fi
echo "リモートの設定が完了しました"

# リモートの変更を取得
echo "リモートの変更を取得しています..."
if ! git fetch origin; then
    handle_error "リモートからのフェッチに失敗しました"
fi
echo "リモートの変更の取得が完了しました"

# README.mdの作成
if [ "$create_readme" = true ] || [ "$create_readme" = "y" ]; then
    echo "README.mdの作成を開始します..."
    if ! git pull origin main --allow-unrelated-histories; then
        handle_error "README作成のためのリモートからのプルに失敗しました"
    fi
    echo "# $repo_name" > README.md
    git add README.md
    if ! git commit -m "Initial commit"; then
        handle_error "README.mdのコミットに失敗しました"
    fi
    if ! git push -u origin main; then
        handle_error "README.mdのリモートへのプッシュに失敗しました"
    fi
    echo "README.mdの作成が完了しました"
fi

# .gitignoreの作成
if [ "$create_gitignore" = true ] || [ "$create_gitignore" = "y" ]; then
    echo ".gitignoreの作成を開始します..."
    if ! git pull origin main; then
        handle_error ".gitignore作成のためのリモートからのプルに失敗しました"
    fi
    touch .gitignore
    git add .gitignore
    if ! git commit -m "Add .gitignore"; then
        handle_error ".gitignoreのコミットに失敗しました"
    fi
    if ! git push origin main; then
        handle_error ".gitignoreのリモートへのプッシュに失敗しました"
    fi
    echo ".gitignoreの作成が完了しました"
fi

echo "リポジトリのセットアップが完了しました。"

# SourceTreeに追加
if [ "$ADD_TO_SOURCETREE" = true ]; then
    echo "SourceTreeへの追加を開始します..."
    if command -v stree &> /dev/null; then
        # リモートの変更を取得し、ローカルの変更とマージする
        echo "リモートの変更を取得しています..."
        if ! git fetch origin; then
            handle_error "SourceTree追加のためのリモートからのフェッチに失敗しました"
        fi
        
        echo "リモートの状態を確認しています..."
        if git ls-remote --exit-code --heads origin main &>/dev/null; then
            echo "リモートの変更をマージしています..."
            if ! git merge --no-edit origin/main; then
                handle_error "リモートの変更のマージに失敗しました"
            fi
            
            # マージ後の状態を確認
            if ! git diff --quiet; then
                echo "マージされた変更をコミットしています..."
                git add .
                if ! git commit -m "Merge remote changes"; then
                    handle_error "マージされた変更のコミットに失敗しました"
                fi
            fi

            # 変更をプッシュ
            echo "変更をリモートにプッシュしています..."
            if ! git push origin main; then
                handle_error "変更のリモートへのプッシュに失敗しました"
            fi
        else
            echo "リモートブランチが空のため、マージとプッシュをスキップします"
        fi

        # SourceTreeに追加
        echo "リポジトリをSourceTreeに追加しています..."
        if ! stree add "$local_path"; then
            handle_error "リポジトリのSourceTreeへの追加に失敗しました"
        fi
        echo "リポジトリがSourceTreeに追加されました。"
    else
        echo "警告: SourceTreeがインストールされていないか、パスが通っていません。手動でリポジトリを追加してください。"
    fi
else
    echo "SourceTreeへの追加はスキップされました。"
fi

echo "リポジトリのセットアップが完了しました。"