# github-repo-creator
Automate the creation of GitHub repositories with a set of shell scripts and tools.
GitHub リポジトリの作成を自動化するシェルスクリプトとツールのセットです。

## 使用方法
1. 以下の手順を実行する前に、`GITHUB_TOKEN` 環境変数に有効な GitHub アクセストークンを設定してください。
    ```bash:
    export GITHUB_TOKEN=your_token
    ```
2. `configs.sample.txt` を `configs.txt` にリネームし、設定を編集します。
   - `INTERACTIVE_MODE`: 対話型モードを使用するかどうかを設定します（`true` または `false`）。
   - 非対話型モード用の設定:
     - `REPO_NAME`: リポジトリ名を設定します。
     - `LOCAL_PATH`: ローカルパスを設定します。
     - `IS_ORG`: 組織アカウントで作成するかどうかを設定します（`true` または `false`）。
     - `ORG_NAME`: 組織名を設定します（`IS_ORG` が `true` の場合）。
     - `IS_PRIVATE`: プライベートリポジトリにするかどうかを設定します（`true` または `false`）。
     - `CREATE_README`: README を作成するかどうかを設定します（`true` または `false`）。
     - `DESCRIPTION`: リポジトリの説明を設定します。
     - `CREATE_GITIGNORE`: .gitignore ファイルを作成するかどうかを設定します（`true` または `false`）。
     - `LICENSE_CHOICE`: ライセンスを選択します（1: MIT, 2: Apache-2.0, 3: GPL-3.0, 4: No license）。

3. `setup_github_repo_tools.sh` を実行して、必要なツールをインストールまたは更新します。
```bash
$ ./setup_github_repo_tools.sh
```

4. `create_github_repo.sh` を実行して、GitHub リポジトリを作成します。
```bash
$ ./create_github_repo.sh
```
- 対話型モードの場合は、プロンプトに従って必要な情報を入力します。
- 非対話型モードの場合は、`configs.txt` で設定した値が使用されます。

5. スクリプトが完了すると、指定したローカルパスにリポジトリがクローンされ、README.md と .gitignore ファイル（設定されている場合）が作成されます。

6. リポジトリが正常に作成されると、SourceTree に自動的に追加されます（SourceTree がインストールされている場合）。

## ファイル構成
- `configs.sample.txt`: 設定ファイルのサンプル
- `create_github_repo.sh`: GitHub リポジトリを作成するメインのシェルスクリプト
- `setup_github_repo_tools.sh`: 必要なツールをインストールまたは更新するシェルスクリプト
- `LICENSE`: MIT ライセンスファイル
- `README.md`: プロジェクトの説明ファイル
- `.gitignore`: 無視するファイルを指定するファイル

## 必要な環境
- macOS
- Homebrew
- GitHub アカウント
- GitHub アクセストークン（`GITHUB_TOKEN` 環境変数に設定）

## 注意事項
- このスクリプトは macOS 環境で動作するように設計されています。
- 完全に空の状態で、`sync`すると初回`push`で`main`ブランチがないというエラーが出る問題がある。