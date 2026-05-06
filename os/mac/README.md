
brew install fzfを入れた後に以下のコマンドを実行しないとctrl + fとかが使えない

$(brew --prefix)/opt/fzf/install

fzfについては以下の記事がかなり参考になる
<https://namileriblog.com/mac/fzf/#i-7>

brew install lua-language-server

nvm
curl -o- <https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh> | bash

LTS
nvm install 22
nvm install 20

nvm alias default 22
echo "20" > .nvmrc
nvm use
node --version

python pyright
npm install -g pyright

typescript
npm install -g typescript typescript-language-server

html css json
npm install -g vscode-langservers-extracted

markdown
brew install marksman

live-serverは
viteを使用する

vite周りは自分で調べる
npm create vite@latest

Viteの標準構成
.
├── index.html
├── src
│   ├── main.js
│   ├── styles.css

LazyVimのためにインストールしておくといいもの

brew install fd
brew install ripgrep

fd じゃなくて fdfind になることがある
確認：
  which fd
  which fdfind
もし fdfind しかない場合
  ln -s $(which fdfind) /opt/homebrew/bin/fd

echo $PATH
homebrewが入っているのかを確認する
echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

必要であれば、
brew install lazygit
