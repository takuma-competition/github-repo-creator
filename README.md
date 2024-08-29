# github-repo-creator
Automate the creation of GitHub repositories with a set of shell scripts and tools.





SourceTreeのパスを確認するには、以下の手順を試してみてください。
ターミナルを開きます。
以下のコマンドを入力して、SourceTreeのインストール場所を検索します。
Bash
"
上記のコマンドを実行すると、SourceTreeアプリケーションのパスが表示されるはずです。例えば、以下のようなパスが表示されるかもしれません。
app
表示されたパスを使って、以下のコマンドでSourceTreeのシンボリックリンクを作成します。
Bash
stree
シンボリックリンクを作成したら、以下のコマンドでパスが通っているか確認します。
Bash
stree
正しくパスが通っていれば、/usr/local/bin/streeのようなパスが表示されるはずです。
これで、シェルスクリプトからSourceTreeを呼び出せるようになります。パスが通っていない場合は、シンボリックリンクの作成が正しく行われているか、再度確認してみてください。